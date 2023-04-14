

eventsLabels={'cue_start', 'cue_end', 'center_in', 'center_out', 'right_in', 'right_out', 'left_in', 'left_out', 'right_lick', 'left_lick', 'manipulation_1_start', 'manipulation_1_end'};
eventsChannels={12, 12, 7, 7, 8, 8, 9, 9, 11, 10, 14, 14};
eventsTypes={'rising', 'falling', 'rising', 'falling', 'rising', 'falling', 'rising', 'falling', 'rising', 'rising', 'rising', 'falling'};
events=cell(1, length(eventsLabels));

downSample=1;
original_dt=1/2000;
offset_dt=0;
%%
%
saveAtOriginalResolution=true;
searchFolders=false;
skipIfExists=false;

% saveFolder='/Users/bernardosabatini/Dropbox (HMS)/2ABT_data_bernardo/test'
% photomFolder='/Users/bernardosabatini/Dropbox (HMS)/2ABT_data_bernardo/photometry'
dateList={'12162021'}
mouseList={'S1262'}

saveFolder='/Volumes/BS Office/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';
%saveFolder='/Users/bernardosabatini/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';
photomFolder='/Volumes/Neurobio/MICROSCOPE/Lynne/2ABT/1_photom';

%% if searchFolders is set, then move through the directory structure and analyze everything
%   start at the levels of the date folders
if searchFolders
    cd(photomFolder)
    D=flip(dir()); % this is where you can select dates.  Enter dir('01282021*'), for example

    dCounter=1;
    dateList={};
    for dfCounter=1:length(D)
        if length(D(dfCounter).name)==8
            dateList{dCounter}=D(dfCounter).name;
            dCounter=dCounter+1;
        end
    end
end

%% Loop through all the dates
for dateC=dateList
    date=dateC{1};
    %    dateFolder=sprintf('/Volumes/BS Office/Dropbox (HMS)/2ABT_data_bernardo/simultaneous recordings/photometry recording/%s/', date);

    %% If searchFolders is set, now gather all the mouse by mouse folders
    if searchFolders
        dateFolder=sprintf('/Volumes/Neurobio/MICROSCOPE/Lynne/2ABT/1_photom/%s/', date);
        cd(dateFolder)
        disp(['Scanning ' dateFolder])
        D=dir(); %[dir('WT54*')' dir('WT55*')' dir('WT56*')']';     % this is where you can select mice.  Enter dir('WT63*'), for example
        dCounter=1;
        mouseList={};
        for dfCounter=1:length(D)
            if length(D(dfCounter).name)>2 && ~any(strcmp(D(dfCounter).name, skipMiceList))
                mouseList{dCounter}=D(dfCounter).name;
                dCounter=dCounter+1;
            end
        end
    end

    %% Loop through all the mice
    for mouseC=mouseList
        mouse=mouseC{1};

        cd(saveFolder)

        disp(' ')

        if skipIfExists && exist(['processed_' mouse '_' date '.mat'], 'file')
            disp([mouse ' ' date ' already analyzed. Skipping. Change flag skipIfExists to reanalyze'])
        else
            if exist(['processed_' mouse '_' date '.mat'], 'file') % reload it get useful stuff
                disp('RELOADING')
                temp= load(['processed_' mouse '_' date '.mat']);
                processed=temp.(['processed_' mouse '_' date]);
                clear temp
                params=processed.params;
                folder1=params.photometry_folder;
                folder2=params.behavior_folder;
                reloaded=1;
                overwriteParameters
            end

            if ~reloaded
            disp(['Working on ' mouse ' ' date ]);
            folder1 = sprintf('/Volumes/Neurobio/MICROSCOPE/Lynne/2ABT/1_photom/%s/%s', date, mouse); %photometry
            folder2 = sprintf('/Volumes/Neurobio/MICROSCOPE/Lynne/2ABT/1_behavior/%s/%s', date, mouse); %behavior

            if ~exist(folder1, 'dir') || ~exist(folder2, 'dir')
                disp('   A data folder is missing. Skipping...');
            else

                reloaded=true;
                reAnalyzeBehavaiorIfExists_table=true;
                reAnalyzeBehavaiorIfExists_matrices=false;
                
                %% check if the behavior data exists before progressing
                pokeFile='';
                statsFile='';
                cd(folder2);
                files = dir('.');
                for i=1:length(files)
                    if contains(files(i).name, 'pokeHistory')
                        pokeFile = files(i).name;
                    elseif regexp(files(i).name, 'stats.*\.mat')
                        statsFile = files(i).name;
                    end
                end

                if exist(pokeFile, 'file') && exist(statsFile, 'file')
                    %% Concatenate data files into an array
                    %data array has the info for each channel that was collected
                    cd(folder1);

                    D=dir('Raw_*.mat');
                    if ~isempty(D)
                        filename={D.name};
                        load(filename{1});
                        nPtsPerTemp=length(temp);
                        disp(['   Loaded first section.  # data points: ' num2str(nPtsPerTemp)]);

                        is9ChanData=0;
                        is13ChanData=0;
                        if nPtsPerTemp==18000
                            disp('   Seems like 9 channel data')
                            is9ChanData=1;
                        elseif nPtsPerTemp==26000
                            disp('   Seems like 13 channel data')
                            is13ChanData=1;
                        elseif nPtsPerTemp==28000
                            disp('   Seems like 14 channel data')
                        else
                            disp('   Channel structure is unknown')
                        end

                        output=zeros(1,(length(filename)*(nPtsPerTemp)));

                        nChansAssume=       floor(original_dt*nPtsPerTemp);
                        if nChansAssume==original_dt*nPtsPerTemp
                            params.notes=statusUpdate(params.notes, ...
                                ['Structuring as ' num2str(nChansAssume) ' channels']);
                            for i=1:length(D)
                                if i>1
                                    load(filename{i});
                                end
                                output(((i-1)*(nPtsPerTemp)+1):(i*(nPtsPerTemp)))=temp;
                            end
                            if (length(output)-floor(length(output)/nChansAssume)*nChansAssume)>eps
                                params.notes=statusUpdate(params.notes, ...
                                    'WARNING: output is not integer multiple of channel length. TRIMMING...');
                            end
                            clear temp
                        end
                        params.samplesPerChannel=floor(length(output)/nChansAssume);
                        output=reshape(output(1:(params.samplesPerChannel*nChansAssume)), nChansAssume, params.samplesPerChannel);
                    end
                end
            end
        end

        processBehavior

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

            centerPortChannel=7;

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
            center=output(centerPortChannel, :);
            d_center_times=diff(center)>0; % take derivative. >0 is an entry
            num_center_pokes_p = sum(d_center_times);
            center_port_indices_p = find(d_center_times);
            center_port_times_p = center_port_indices_p/params.rawSampleFreq;

            clear center

            oldTrialTable = extractTrials_dataTable(stats, pokeHistory);
            %% massage the block table

            blockTable=table;
            % find block transitions
            startTemp=[1; find(oldTrialTable.leftRewardProb(1:end-1)~=oldTrialTable.leftRewardProb(2:end))+1];
            nBlocks=length(startTemp);
            blockTable.block_number=(1:nBlocks)';
            blockTable.start_trial=startTemp;
            blockTable.end_trial=[blockTable.start_trial(2:end)-1; length(oldTrialTable.leftRewardProb)];
            blockTable.reward_prob_left=oldTrialTable.leftRewardProb(blockTable.start_trial);
            blockTable.reward_prob_right=oldTrialTable.rightRewardProb(blockTable.start_trial);
            blockTable.aversive_prob_left=zeros(nBlocks, 1);
            blockTable.aversive_prob_right=zeros(nBlocks, 1);

            %% massage the trial table

            trialTable=table;
            nTrials=length(oldTrialTable.centerInTime);

            trialTable.block=zeros(nTrials, 1);
            trialTable.block_position=zeros(nTrials, 1);

            trialTable.trial_number=(1:nTrials)';
            trialTable.choice=strings(nTrials, 1);
            trialTable.choice(oldTrialTable.choseLeft==1)='left';
            trialTable.choice(oldTrialTable.choseRight==1)='right';
            trialTable.switch=[0; oldTrialTable.choseRight(1:end-1)~=oldTrialTable.choseRight(2:end)];
            trialTable.rewarded=oldTrialTable.wasRewarded;
            trialTable.reaction_time=oldTrialTable.sideInTime-oldTrialTable.centerInTime;
            trialTable.ITI=[nan; oldTrialTable.centerInTime(2:end)-oldTrialTable.centerInTime(1:end-1)];
            trialTable.num_licks_left=zeros(nTrials, 1);
            trialTable.num_licks_right=zeros(nTrials, 1);

            trialTable.ENL_duration=nan(nTrials, 1);
            trialTable.solenoid_open_time=nan(nTrials, 1);
            trialTable.reward_size=nan(nTrials, 1);

            trialTable.punished=zeros(nTrials, 1);
            trialTable.punishment_size=nan(nTrials, 1);
            trialTable.uncued=zeros(nTrials, 1);
            trialTable.manipulation_1=zeros(nTrials, 1);
            trialTable.manipulation_2=zeros(nTrials, 1);
            trialTable.manipulation_3=zeros(nTrials, 1);
            trialTable.manipulation_4=zeros(nTrials, 1);

            for blockNum=1:nBlocks
                trialTable.block(blockTable.start_trial(blockNum):blockTable.end_trial(blockNum))=blockNum;
                trialTable.block_position(blockTable.start_trial(blockNum):blockTable.end_trial(blockNum))=...
                    1:(blockTable.end_trial(blockNum)-blockTable.start_trial(blockNum)+1);

            end


            %% make the events list
            keepRangeSize=floor(size(output, 2)/downSample)*downSample;

            totalSize=0;

            if oldTrialTable.centerInPokeIndex(1)>1
                output(:, 1:(oldTrialTable.centerInPokeIndex(1)-1))=0;
            end

            for eventCounter=1:length(events)

                disp(eventsLabels{eventCounter});
                eventType=eventsTypes{eventCounter};
                eventChannel=eventsChannels{eventCounter};

                switch eventType
                    case 'rising'
                        events{eventCounter}=original_dt*downSample*find(...
                            squeeze(any(...
                            reshape(...
                            [diff(output(eventChannel, 1:keepRangeSize), 1, 2)==1 0], ...
                            downSample, keepRangeSize/downSample), ...
                            1)));

                    case 'falling'
                        events{eventCounter}=original_dt*downSample*find(...
                            squeeze(any(...
                            reshape(...
                            [diff(-output(eventChannel, 1:keepRangeSize), 1, 2)==1 0], ...
                            downSample, keepRangeSize/downSample), ...
                            1)));

                    case 'high'
                        events{eventCounter}=original_dt*downSample*find(...
                            squeeze(any(...
                            reshape(...
                            output(eventChannel, 1:keepRangeSize)==1, ...
                            downSample, keepRangeSize/downSample), ...
                            1)));

                    case 'low'
                        events{eventCounter}=original_dt*downSample*find(...
                            squeeze(any(...
                            reshape(...
                            output(eventChannel, 1:keepRangeSize)==0, ...
                            downSample, keepRangeSize/downSample), ...
                            1)));

                end
                totalSize=totalSize+length(events{eventCounter});
            end

            startEvent=1;
            totalEventLabels=zeros(1, totalSize);
            totalEvents=zeros(1, totalSize);
            for eventCounter=1:length(events)
                theseEvents=events{eventCounter};
                if theseEvents>0
                    totalEventLabels(startEvent:(startEvent+length(theseEvents)-1))=eventCounter;
                    totalEvents(startEvent:(startEvent+length(theseEvents)-1))=theseEvents;
                    startEvent=startEvent+length(theseEvents);
                end
            end

            %% go back and fill in the number of right and left licks
            right_lick_index=find(strcmp(eventsLabels, 'right_lick'));
            left_lick_index=find(strcmp(eventsLabels, 'left_lick'));
            right_out_index=find(strcmp(eventsLabels, 'right_out'));
            left_out_index=find(strcmp(eventsLabels, 'left_out'));

            for trialCounter=1:nTrials
                startTime=oldTrialTable.sideInTime(trialCounter);
                if oldTrialTable.choseLeft(trialCounter)
                    fff=find(events{left_out_index}>startTime);
                    endTime=events{left_out_index}(fff(1));
                else
                    fff=find(events{right_out_index}>startTime);
                    endTime=events{right_out_index}(fff(1));
                end

              %  [startTime endTime]
                trialTable.num_licks_left(trialCounter)=length(find(events{left_lick_index}>=startTime & events{left_lick_index}<endTime));
                trialTable.num_licks_right(trialCounter)=length(find(events{right_lick_index}>=startTime & events{right_lick_index}<endTime));
            end
    
            %% end thtat

        end

    end
end

