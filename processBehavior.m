if ~exist('keepAllLicks', 'var')
    keepAllLicks=false;
end

if ~reloaded || (reloaded && reAnalyzeBehavaiorIfExists_table)
    %% Find behavior data
    cd(folder2);

    %% Load stats and pokehistory files
    % pokeHistory has fields:
    % timeStamp, portPoked, isTRIAL, REWARD, trialTime, leftPortStats
    % rightPortStats, laser
    % stats has fields:
    % times: [1×1001 double]
    % params.trialData: [1×1 struct]
    % rewards: [1×1 struct]
    % errors: [1×1 struct]
    % sync_frame: [1×1001 double]

    pokeFile='';
    statsFile='';
    files = dir('.');
    for i=1:length(files)
        if contains(files(i).name, 'pokeHistory')
            params.pokeFile = files(i).name;
        elseif regexp(files(i).name, 'stats.*\.mat')
            params.statsFile = files(i).name;
        end
    end

    behaviorErrorFlag=false;

    if exist(params.pokeFile, 'file') && exist(params.statsFile, 'file')
        load(params.pokeFile);
        load(params.statsFile);

        if isempty(pokeHistory) || isempty(stats) || ~isfield(pokeHistory(1), 'timeStamp') || ...
                ~isfield(stats, 'trials') || isempty(stats(1).trials)
            params.notes=statusUpdate(params.notes, ...
                'WARNING: pokeHistory or stats file is corrupted. Skippping');
            behaviorErrorFlag=true;
            return
        end
    else
        params.notes=statusUpdate(params.notes, 'WARNING - POKE FILE OR STATS FILE MISSING. Skipping...');
        if ~exist(pokeFile, 'file')
            params.notes=statusUpdate(params.notes, 'POKE missing');
        end
        if ~exist(statsFile, 'file')
            params.notes=statusUpdate(params.notes, 'STATS missing');
        end
        behaviorErrorFlag=true;
        return
    end

    cd ~

    %% Make list to times of all pokes (timePoked) for entire session relative to first poke

    %this info from Arduino. figuring out when all pokes occur, not their identity.
    numPokes = length(pokeHistory);
    timePoked = zeros(1,numPokes);
    firstPoke = datevec(pokeHistory(1).timeStamp);

    % calculate the time of time poke relative to the first one
    for i = 1:numPokes
        timePoked(i) = etime(datevec(pokeHistory(i).timeStamp),firstPoke);
    end

    % get the names of the poked ports in order
    port_names = {pokeHistory(:).portPoked};

    % find the center pokes and their times in the behavior data
    centerIdx = cellfun(@(c) contains(c,'center'), port_names, 'uniform',1);
    num_center_pokes_b = sum(centerIdx);
    center_port_indices_b = find(centerIdx);
    center_port_times_b=timePoked(center_port_indices_b);

    % find the center pokes and their times in the photometry data
    centerPortChannel=find(strcmp(params.channelDefs, 'Centerport'));
    center=output(centerPortChannel, outputSignalRange);
    d_center_times=diff(center)>0; % take derivative. >0 is an entry
    num_center_pokes_p = sum(d_center_times);
    center_port_indices_p = find(d_center_times);
    center_port_times_p = center_port_indices_p/params.rawSampleFreq;

    clear center

    %% find the time shifts between photometry and behavior

    % find the time between pokes.  The cross-correlation of these will be the
    % shift
    center_point_dt_p=center_port_times_p(2:end) - center_port_times_p(1:end-1);
    center_point_dt_b=center_port_times_b(2:end) - center_port_times_b(1:end-1);
    xxx=xcorr(center_point_dt_b, center_point_dt_p, 100);
    [maxval, maxloc]=max(xxx);
    maxval=maxval/(sqrt(sum(center_point_dt_b.^2))*sqrt(sum(center_point_dt_p.^2)));
    params.notes=statusUpdate(params.notes, ...
        ['Aligning behavior to photometry.  Normalized XCORR max value is ' num2str(maxval)]);

    p_to_b_dIndex=maxloc-1-100;
    if maxval<0.5 % some cut off threshold for a good match in timing
        params.notes=statusUpdate(params.notes, ...
            'WARNING: Unable to align photometry and behavioral data. Skipping...');
        behaviorErrorFlag=true;
    else
        if p_to_b_dIndex>=0
            if doPlot
                figure; hold on;
                plot(center_point_dt_p)
                plot(center_point_dt_b((p_to_b_dIndex+1):end))
            end
            pN=length(center_point_dt_p)+1;
            bN=length(center_point_dt_b)-p_to_b_dIndex+1;
            NN=min(pN, bN);
            center_port_times_p_adj=center_port_times_p(1:NN);
            center_port_times_b_adj=center_port_times_b(p_to_b_dIndex+(1:NN));
            first_p_center_index=1;
        else
            if doPlot
                figure; hold on;
                plot(center_point_dt_p((abs(p_to_b_dIndex)+1):end))
                plot(center_point_dt_b)
            end
            pN=length(center_point_dt_p)+p_to_b_dIndex+1;
            bN=length(center_point_dt_b);

            NN=min(pN, bN);
            center_port_times_p_adj=center_port_times_p(abs(p_to_b_dIndex)+(1:NN));
            center_port_times_b_adj=center_port_times_b(1:NN);
            first_p_center_index=abs(p_to_b_dIndex)+1;
        end

        if maxloc==1 || ...
                isempty(center_port_times_b_adj) || ...
                isempty(center_port_times_p_adj)
            params.notes=statusUpdate(params.notes, 'WARNING: Process behavior: Cannot align photometry and behavior data');
            behaviorErrorFlag=true;
            processed.trialTable=[];
        else
            [mm,~]=xcorr(diff(center_port_times_p_adj), diff(center_port_times_b_adj), 'normalized');
            disp(['    After alignment XCORR value of times is ' num2str(max(mm)) ]);
            
            first_b_poke_index=find(timePoked==center_port_times_b_adj(1));
            last_b_poke_index=find(timePoked==center_port_times_b_adj(end));

            dTs=center_port_times_p_adj-center_port_times_b_adj;
            dT=mean(dTs);
            dtStd=std(dTs);
            params.notes=statusUpdate(params.notes, ['    found index shift of ' num2str(p_to_b_dIndex) ' and time shift of ' ...
                num2str(dT) ' with std of ' num2str(dtStd)]);
            params.notes=statusUpdate(params.notes, ['    using behavior data from trial ' num2str(first_b_poke_index) ...
                ' to ' num2str(last_b_poke_index)]);

            %% get behavior table aligned to photometry

            processed.trialTable = extractTrials_dataTable(stats, pokeHistory, first_b_poke_index, last_b_poke_index);
        end
    end

    if ~isfield(processed, 'trialTable') || isempty(processed.trialTable)
        params.notes=statusUpdate(params.notes, ...
            'WARNING: unable to extract trial information');
        behaviorErrorFlag=true;
        return
    end

    numTableTrials=size(processed.trialTable, 1);

    processed.trialTable.matchedSideInIndex=zeros(numTableTrials, 1);
    processed.trialTable.matchedCenterInIndex=zeros(numTableTrials, 1);
    processed.trialTable.photometryCenterInIndex=zeros(numTableTrials, 1);
    processed.trialTable.photometryCenterOutIndex=zeros(numTableTrials, 1);
    processed.trialTable.photometrySideInIndex=zeros(numTableTrials, 1);
    processed.trialTable.photometrySideOutIndex=zeros(numTableTrials, 1);
    processed.trialTable.photometryFirstLickIndex=zeros(numTableTrials, 1);
    processed.trialTable.photometryNumLicks=zeros(numTableTrials, 1);
    processed.trialTable.hasAllPhotometryData=false(numTableTrials, 1);

    % calculate the point in flourescence corresponding to the side port entry
    % time
    params.timeShift=center_port_times_p_adj(1);
    processed.trialTable.matchedCenterInIndex=...
        (1+floor((processed.trialTable.centerInTime+center_port_times_p_adj(1))/params.finalTimeStep));
    processed.trialTable.matchedSideInIndex=...
        (1+floor((processed.trialTable.sideInTime+center_port_times_p_adj(1))/params.finalTimeStep));

    %% Search for matched port withdrawal times and extract number of licks
    centerPortChannel=find(strcmp(params.channelDefs, 'Centerport'));
    cPortChannel=1;
    rPortChannel=find(strcmp(params.channelDefs, 'Rightport')) - centerPortChannel + 1;
    lPortChannel=find(strcmp(params.channelDefs, 'Leftport')) - centerPortChannel + 1;
    rLickChannel=find(strcmp(params.channelDefs, 'Right Lick')) - centerPortChannel + 1;
    lLickChannel=find(strcmp(params.channelDefs, 'Left Lick')) - centerPortChannel + 1;

    outCenterIndices=find(processed.behavior.fallingEdge(cPortChannel,:));
    outSideIndices=find(processed.behavior.fallingEdge(rPortChannel,:) | processed.behavior.fallingEdge(lPortChannel,:));

    rightSideInIndices=find(processed.behavior.risingEdge(rPortChannel,:));
    leftSideInIndices=find(processed.behavior.risingEdge(lPortChannel, :));
    centerInIndices=find(processed.behavior.risingEdge(cPortChannel, :));

    if isempty(rightSideInIndices) && ~isempty(find(processed.trialTable.choseRight, 1))
        params.notes=statusUpdate(params.notes, ...
            '*** right port entries missing');
        behaviorErrorFlag=true;
        return
    end

    if isempty(leftSideInIndices) && ~isempty(find(processed.trialTable.choseLeft, 1))
        params.notes=statusUpdate(params.notes, ...
            '*** left port entries missing');
        behaviorErrorFlag=true;
        return
    end

    for trialIndex=1:numTableTrials
        if keepAllLicks || processed.trialTable.isPhotometryTrial(trialIndex)
            % adjust timing a bit
            if processed.trialTable.choseRight(trialIndex) 
                processed.trialTable.photometrySideInIndex(trialIndex)= ...
                    rightSideInIndices(closest(rightSideInIndices, processed.trialTable.matchedSideInIndex(trialIndex)));
            elseif processed.trialTable.choseLeft(trialIndex)
                processed.trialTable.photometrySideInIndex(trialIndex)= ...
                    leftSideInIndices(closest(leftSideInIndices, processed.trialTable.matchedSideInIndex(trialIndex)));
            else
                params.notes=statusUpdate(params.notes, ...
                    ['WARNING: trial # ' num2str(trialIndex) ' is neither left nor right']);
            end
            processed.trialTable.photometryCenterInIndex(trialIndex)= ...
                centerInIndices(closest(centerInIndices, processed.trialTable.matchedCenterInIndex(trialIndex)));

            % find the centerOut that occurs after the current
            % center in
            fff=find(outCenterIndices>=processed.trialTable.photometryCenterInIndex(trialIndex));
            if isempty(fff)
                params.notes=statusUpdate(params.notes, ...
                    ['WARNING: unable to find center out for trial #' num2str(trialIndex)]);
                processed.trialTable.isPhotometryTrial(trialIndex)=false;
            else
                processed.trialTable.photometryCenterOutIndex(trialIndex)=outCenterIndices(fff(1));
            end

            % find next side out and process licks
            fff=find(outSideIndices>=processed.trialTable.photometryCenterInIndex(trialIndex));
            if isempty(fff)
                params.notes=statusUpdate(params.notes, ...
                    ['WARNING: unable to find side out for trial #' num2str(trialIndex)]);
                processed.trialTable.isPhotometryTrial(trialIndex)=false;
            else
                processed.trialTable.photometrySideOutIndex(trialIndex)=outSideIndices(fff(1));
                lickPeriod=processed.behavior.risingEdge(rLickChannel,...
                    processed.trialTable.photometrySideInIndex(trialIndex):processed.trialTable.photometrySideOutIndex(trialIndex)) ...
                    + ...
                    processed.behavior.risingEdge(lLickChannel,...
                    processed.trialTable.photometrySideInIndex(trialIndex):processed.trialTable.photometrySideOutIndex(trialIndex));
                processed.trialTable.photometryNumLicks(trialIndex)=...
                    sum(lickPeriod);

                fff=find(lickPeriod>0);
                if ~isempty(fff) % there was a lick
                    processed.trialTable.photometryFirstLickIndex(trialIndex)=...
                        processed.trialTable.photometrySideInIndex(trialIndex)+fff(1)-1;
                end
            end
        end
    end
    % fix an error in the center out times
    dupInd=1+find(processed.trialTable.photometryCenterOutIndex(1:end-1)==processed.trialTable.photometryCenterOutIndex(2:end));
    dupInd=intersect(dupInd, find(processed.trialTable.photometryCenterInIndex>0));
    
    if ~isempty(dupInd)
        processed.trialTable.photometryCenterOutIndex(dupInd)=processed.trialTable.photometryCenterInIndex(dupInd);
    end

end

if ~reloaded || (reloaded && reAnalyzeBehavaiorIfExists_matrices)

    if reloaded
        overwriteParameters;
    end

    % if dropFirstDetrendWindow==true, then get rid of the data at
    % the beginning of the trial before the detrending window fully
    % kicks in.  It's a good idea to have this set to true.
    if params.dropFirstDetrendWindow
        minPtsOffset=params.signalDetrendWindow;
    else
        minPtsOffset=0;
    end

    %% Clean up trials
    % label the trials that have enough data to cover a full trial as well
    % as all the points necessary before and after the trials
    % boundaries
    processed.trialTable.hasAllPhotometryData=...
        processed.trialTable.isPhotometryTrial ...
        & (processed.trialTable.photometryCenterInIndex>(params.ptsKeep_before+minPtsOffset)) ...
        & (processed.trialTable.photometrySideOutIndex<(params.finalSamples-params.ptsKeep_after));

    % erase entries of trials that don't have enough data
    processed.trialTable.photometryCenterInIndex(~processed.trialTable.hasAllPhotometryData)=0;
    processed.trialTable.photometryCenterOutIndex(~processed.trialTable.hasAllPhotometryData)=0;
    processed.trialTable.photometrySideInIndex(~processed.trialTable.hasAllPhotometryData)=0;
    processed.trialTable.photometrySideOutIndex(~processed.trialTable.hasAllPhotometryData)=0;
    processed.trialTable.photometryFirstLickIndex(~processed.trialTable.hasAllPhotometryData)=0;
    processed.trialTable.photometryNumLicks(~processed.trialTable.hasAllPhotometryData)=0;

    %% break up params.trialData
    % use the information in the trial table to group trials for
    % analysis into different bins

    % Left and Right crossed with Reward and No Reward
    RR=find(processed.trialTable.hasAllPhotometryData & processed.trialTable.choseRight & processed.trialTable.wasRewarded);
    RNR=find(processed.trialTable.hasAllPhotometryData & processed.trialTable.choseRight & ~processed.trialTable.wasRewarded);
    LR=find(processed.trialTable.hasAllPhotometryData & processed.trialTable.choseLeft & processed.trialTable.wasRewarded);
    LNR=find(processed.trialTable.hasAllPhotometryData & processed.trialTable.choseLeft & ~processed.trialTable.wasRewarded);

    % Left vs. right
    R=find(processed.trialTable.hasAllPhotometryData & processed.trialTable.choseRight);
    L=find(processed.trialTable.hasAllPhotometryData & processed.trialTable.choseLeft);

    % Rew vs. No reward
    Rew=find(processed.trialTable.hasAllPhotometryData & processed.trialTable.wasRewarded);
    NoRew=find(processed.trialTable.hasAllPhotometryData & ~processed.trialTable.wasRewarded);

    % R or L and High Reward Port
    HiR=find(processed.trialTable.rightRewardProb>processed.trialTable.leftRewardProb);
    HiL=find(processed.trialTable.rightRewardProb<=processed.trialTable.leftRewardProb);

    % To the High Reward Port vs. to the Low Reward Port
    Hi=union(   intersect(R, HiR),  intersect(L, HiL));
    Low=union(  intersect(R, HiL),  intersect(L, HiR));

    % Cross High and Low Reward port with Reward and No Reward
    Hi_Rew=     intersect(Hi, Rew);
    Low_Rew=    intersect(Low, Rew);
    Hi_NoRew=   intersect(Hi, NoRew);
    Low_NoRew=  intersect(Low, NoRew);

    % Get the conditions and alignments to calculate and store
    conditionsList={'RR', 'RNR', 'LR', 'LNR', 'R', 'L', 'Rew', 'NoRew', 'Hi', 'Low', 'Hi_NoRew', 'Low_NoRew', 'Hi_Rew', 'Low_Rew'};

    alignmentCodeList={'SI', 'SO', 'CI', 'CO', 'FL'};
    aligmentColumn={ ...
        'photometrySideInIndex', ...
        'photometrySideOutIndex', ...
        'photometryCenterInIndex', ...
        'photometryCenterOutIndex', ...
        'photometryFirstLickIndex' ...
        };

    imTimes=params.finalTimeStep*(-params.ptsKeep_before:params.ptsKeep_after);
    totalPointsToKeep=params.ptsKeep_before+params.ptsKeep_after+1;

    %% Call sub routine to process each condition and alignment point
    % save the trials and event times for each condition and type of alignment
    % extract the fluorescence and calcualate means, std, z-scores
    % run through the behavior data.  Keep only the means and std
    processConditions;
    
end

