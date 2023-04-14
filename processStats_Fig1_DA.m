%% Setup analysis
testFraction=0.3;
trainFraction=1-testFraction;

nModels=100;
alphaForTTest=0.05;
rerunOldAnalysisSet=false;

randomShuffle=false;  % set to true for label shuffle control
zScoreAllData=false; % normalize the data acorss all sessions before doing analysis.  Doesn't seem to affect LDA/SVM performance at all so leave it off to have summary statistics in natural units

runSVMhyp=false;
runLDAhyp=true;

channelList=1;

saveName='Figure1_DA_Fig1_LR_RewNoRew';
if ~rerunOldAnalysisSet
    groupsToAnalyze=who('processed_WT*')';
else
    neededToReload=false;
    for gCounter=1:length(groupsToAnalyze)
        if ~exist(groupsToAnalyze{gCounter}, "var")
            disp([groupsToAnalyze{gCounter} ' not found in memory'])
            if exist([groupsToAnalyze{gCounter} '.mat'], "file")
                disp('   loading from disk')
                load([groupsToAnalyze{gCounter} '.mat'])
                neededToReload=true;
            else
                error('   file not found')
            end
        end
    end
    if neededToReload
        processCeliaWord
    end
end


%% setup special mice
ABT_virusCode;

defaultChannelMatching=[1 2 0 0 5 6]; % this is how to use the channels. Here we just map 1 to 2 etc...
channelSwaps=[5 6 0 0 1 2]; % this is how to rearrange them for a subset of mice
swappedChannelMice={...  % which mice should have the channels swapped?
    'WT63', 'WT64', 'WT65', 'WT66', 'WT67', 'WT68', 'WT69' 
    };

mouseViruses={...
    'ALL'  [277 0       0 0     279.4 333.3]; ...
    'WT53' [279.4 335   0 0     279.4 333.3]; ...
    'WT54' [279.4 335   0 0     279.4 333.3]; ...
    'WT55' [279.4 335   0 0     279.4 333.3]; ...
    'WT56' [279.4 335   0 0     279.4 333.3]; ...
    'WT57' [0 0         0 0     279.4 335]; ...
    'WT58' [279.4 333.3 0 0     279.4 333.3]; ...
    'WT59' [0 0         0 0     279.4 335]; ...
    'WT60' [279.4 333.3 0 0     279.4 333.3]; ...
    'WT61' [279.4 333.3 0 0     279.4 333.3]; ...
    'WT62' [277 0       0 0     279.4 333.3]; ...
    'WT63' [277 0       0 0     279.4 333.3]; ...
    'WT64' [277 0       0 0     279.4 333.3]; ...
    'WT65' [277 0       0 0     279.4 333.3]; ...
    'WT66' [277 0       0 0     277.1 0];...
    'WT67' [277 0       0 0     277.1 0];...
    'WT68' [277.1 0     0 0     277.1 0];...
    'WT69' [277.1 0     0 0     277.1 0];...
    };
%% set up the definitions of the conditions to compare

% {groupingCode : all mouse theseSessions
%               all - take all the sessions that match in "groupsToAnalyze"
%                   below and mix all the data across them
%               mouse - take all the sessions for a particular mouse and
%                   mix across them
%               theseSessions - take only the seesions that are addded
%                   as an extra parameter 4 in the condition def
%       active : true false
%       analysisMode : trials or means
%       nCondition x {condition, event, [pointsBeforeEvent pointsAfterEvent]}


preN=10;
rewN=18;
norewN=10;

conditionSets={};
% conditionSets{end+1}={'NoLed/LED' 'theseSessions' 'trials'    {'Rew', 'SI', [0 20], 'processed_WT62_11222021'}   {'Rew', 'SI', [0 20], 'processed_WT63_11082021'}};
% conditionSets{end+1}={'NoLed/LED' 'theseSessions' 'trials'    {'Rew', 'SI', [0 20], 'processed_WT63_11222021'}   {'Rew', 'SI', [0 20], 'processed_WT63_11102021'}};
% conditionSets{end+1}={'NoLed/LED' 'theseSessions' 'trials'    {'Rew', 'SI', [0 20], 'processed_WT64_11222021'}   {'Rew', 'SI', [0 20], 'processed_WT64_11082021'}};
% conditionSets{end+1}={'NoLed/LED' 'theseSessions' 'trials'    {'Rew', 'SI', [0 20], 'processed_WT65_11222021'}   {'Rew', 'SI', [0 20], 'processed_WT65_11082021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'NoRew', 'SI', [0 10], 'processed_WT60_10182021'}   {'NoRew', 'SI', [0 10], 'processed_WT60_10132021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'NoRew', 'SI', [0 10], 'processed_WT61_10182021'}   {'NoRew', 'SI', [0 10], 'processed_WT61_10132021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'NoRew', 'SI', [0 10], 'processed_WT63_11222021'}   {'NoRew', 'SI', [0 10], 'processed_WT63_11182021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'NoRew', 'SI', [0 10], 'processed_WT64_11222021'}   {'NoRew', 'SI', [0 10], 'processed_WT64_11182021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'NoRew', 'SI', [0 10], 'processed_WT65_11222021'}   {'NoRew', 'SI', [0 10], 'processed_WT65_11182021'}};
% conditionSets{end+1}={true 'all' 'means'     {'Rew', 'SI', [10 10]}   {'NoRew', 'SI', [10 10]}};
% conditionSets{end+1}={true 'all' 'means'     {'Rew', 'SI', [0 10]}   {'NoRew', 'SI', [0 10]}};
% conditionSets{end+1}={true 'all' 'means'     {'Rew', 'SI', [10 0]}   {'NoRew', 'SI', [10 0]}};

% %R vs L no reward
% conditionSets{end+1}={'r/l' 'all' 'trials'                  {'w_r', 'SI', [0 norewN]}   {'w_l', 'SI', [0 norewN]}};
 conditionSets{end+1}={'r/l' 'mouse' 'trials'                {'RNR', 'SI', [0 norewN]}   {'LNR', 'SI', [0 norewN]}};
% conditionSets{end+1}={'r/l(Pre)' 'all' 'trials'             {'w_r', 'SI', [preN 0]}   {'w_l', 'SI', [preN 0]}};
 conditionSets{end+1}={'r/l(Pre)' 'mouse' 'trials'           {'RNR', 'SI', [preN 0]}   {'LNR', 'SI', [preN 0]}};

% R vs L reward
%conditionSets{end+1}={'R/L' 'all' 'trials'                  {'w_R', 'SI', [0 rewN]}   {'w_L', 'SI', [0 rewN]}};
conditionSets{end+1}={'R/L' 'mouse' 'trials'                {'RR', 'SI', [0 rewN]}   {'RR', 'SI', [0 rewN]}};
%conditionSets{end+1}={'R/L(Pre)' 'all' 'trials'             {'w_R', 'SI', [preN 0]}   {'w_L', 'SI', [preN 0]}};
conditionSets{end+1}={'R/L(Pre)' 'mouse' 'trials'           {'RR', 'SI', [preN 0]}   {'RR', 'SI', [preN 0]}};

% are reward and no reward different before and after the SI
%conditionSets{end+1}={'Rew/NoRew' 'all' 'trials'            {'Rew', 'SI', [0 norewN]}   {'NoRew', 'SI', [0 norewN]}};
conditionSets{end+1}={'Rew/NoRew' 'mouse' 'trials'          {'Rew', 'SI', [0 norewN]}   {'NoRew', 'SI', [0 norewN]}}; % done
%conditionSets{end+1}={'Rew/NoRew(Pre)' 'all' 'trials'       {'Rew', 'SI', [preN 0]}   {'NoRew', 'SI', [preN 0]}};
conditionSets{end+1}={'Rew/NoRew(Pre)' 'mouse' 'trials'     {'Rew', 'SI', [preN 0]}   {'NoRew', 'SI', [preN 0]}}; % done

% % Aa vs aa
% %conditionSets{end+1}={'Aa/aa' 'all' 'trials'                {'w_Aa', 'SI', [0 norewN]}  {'w_aa', 'SI', [0 norewN]}};
% conditionSets{end+1}={'Aa/aa' 'mouse' 'trials'              {'w_Aa', 'SI', [0 norewN]}  {'w_aa', 'SI', [0 norewN]}}; % done
% %conditionSets{end+1}={'Aa/aa(Pre)' 'all' 'trials'           {'w_Aa', 'SI', [preN 0]}  {'w_aa', 'SI', [preN 0]}};
% conditionSets{end+1}={'Aa/aa(Pre)' 'mouse' 'trials'         {'w_Aa', 'SI', [preN 0]}  {'w_aa', 'SI', [preN 0]}}; % done
% 
% % Ab vs ab
% %conditionSets{end+1}={'Ab/ab' 'all' 'trials'                {'w_Ab', 'SI', [0 norewN]}  {'w_ab', 'SI', [0 norewN]}};
% conditionSets{end+1}={'Ab/ab' 'mouse' 'trials'              {'w_Ab', 'SI', [0 norewN]}  {'w_ab', 'SI', [0 norewN]}}; % done
% %conditionSets{end+1}={'Ab/ab(Pre)' 'all' 'trials'           {'w_Ab', 'SI', [preN 0]}  {'w_ab', 'SI', [preN 0]}};
% conditionSets{end+1}={'Ab/ab(Pre)' 'mouse' 'trials'         {'w_Ab', 'SI', [preN 0]}  {'w_ab', 'SI', [preN 0]}}; % done
% 
% % AA vs aA
% %conditionSets{end+1}={'AA/aA' 'all' 'trials'                {'w_AA', 'SI', [0 rewN]}  {'w_aA', 'SI', [0 rewN]}};
% conditionSets{end+1}={'AA/aA' 'mouse' 'trials'              {'w_AA', 'SI', [0 rewN]}  {'w_aA', 'SI', [0 rewN]}}; % done
% %conditionSets{end+1}={'AA/aA(Pre)' 'all' 'trials'           {'w_AA', 'SI', [preN 0]}  {'w_aA', 'SI', [preN 0]}};
% conditionSets{end+1}={'AA/aA(Pre)' 'mouse' 'trials'         {'w_AA', 'SI', [preN 0]}  {'w_aA', 'SI', [preN 0]}}; % done
% 
% % AB vs aB
% %conditionSets{end+1}={'AA/aB' 'all' 'trials'                {'w_AB', 'SI', [0 rewN]}  {'w_aB', 'SI', [0 rewN]}};
% conditionSets{end+1}={'AB/aB' 'mouse' 'trials'              {'w_AB', 'SI', [0 rewN]}  {'w_aB', 'SI', [0 rewN]}}; % done
% %conditionSets{end+1}={'AA/aB(Pre)' 'all' 'trials'           {'w_AB', 'SI', [preN 0]}  {'w_aB', 'SI', [preN 0]}};
% conditionSets{end+1}={'AB/aB(Pre)' 'mouse' 'trials'         {'w_AB', 'SI', [preN 0]}  {'w_aB', 'SI', [preN 0]}}; % done

%% set up the tables
statsTable=table;
statsTable.mouseID=strings(0,1);
statsTable.condition=zeros(0,1);
statsTable.conditionString=strings(0,1);
statsTable.channel=zeros(0,1);
statsTable.channelVirus=strings(0,1);
statsTable.channelSwapped=false(0,1);
statsTable.analysisMode=strings(0,1);
statsTable.modelType=strings(0,1);
statsTable.randomShuffle=false(0,1);
statsTable.testFraction=zeros(0,1);
statsTable.trainFraction=zeros(0,1);
statsTable.LDA_nModels=zeros(0,1);
statsTable.LDA_trainPred_avg=zeros(0,1);
statsTable.LDA_trainPred_sd=zeros(0,1);
statsTable.LDA_testPred_avg=zeros(0,1);
statsTable.LDA_testPred_sd=zeros(0,1);
statsTable.LDA_hyp_trainPred=zeros(0,1);
statsTable.LDA_hyp_testPred=zeros(0,1);
statsTable.SVM_hyp_trainPred=zeros(0,1);
statsTable.SVM_hyp_testPred=zeros(0,1);
statsTable.moment1_p_avg=zeros(0,1);
statsTable.moment1_p_sd=zeros(0,1);
statsTable.moment2_p_avg=zeros(0,1);
statsTable.moment2_p_sd=zeros(0,1);
statsTable.moment3_p_avg=zeros(0,1);
statsTable.moment3_p_sd=zeros(0,1);
statsTable.moment4_p_avg=zeros(0,1);
statsTable.moment4_p_sd=zeros(0,1);
statsTable.moment1_H_avg=zeros(0,1);
statsTable.moment1_H_sd=zeros(0,1);
statsTable.moment2_H_avg=zeros(0,1);
statsTable.moment2_H_sd=zeros(0,1);
statsTable.moment3_H_avg=zeros(0,1);
statsTable.moment3_H_sd=zeros(0,1);
statsTable.moment4_H_avg=zeros(0,1);
statsTable.moment4_H_sd=zeros(0,1);

%% find the maximum number of conditions to set up the tables
maxConditions=0;
for sCounter=1:length(conditionSets)
    conditionDefs=conditionSets{sCounter};
    maxConditions=max(maxConditions, length(conditionDefs)-3);
end

%% Set up the statsTable to hold results
dummyFill={'' 0 '' 0 '' false '' '' false 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0};

for sCounter=1:maxConditions
    statsTable.(['cond' num2str(sCounter)])=strings(0,1); % the name of the condition
    statsTable.(['moment1_train_cond' num2str(sCounter) '_avg'])=zeros(0,1); % the average and SD of the first 4 moments of all the random train data sets
    statsTable.(['moment1_train_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['moment2_train_cond' num2str(sCounter) '_avg'])=zeros(0,1);
    statsTable.(['moment2_train_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['moment3_train_cond' num2str(sCounter) '_avg'])=zeros(0,1);
    statsTable.(['moment3_train_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['moment4_train_cond' num2str(sCounter) '_avg'])=zeros(0,1);
    statsTable.(['moment4_train_cond' num2str(sCounter) '_sd'])=zeros(0,1);

    dummyFill=[dummyFill {'' 0 0 0 0 0 0 0 0 }];
end

%% start at begining of table

tableCounter=0;
%% loop through all the conditions to test
for conditionCounter=1:length(conditionSets)
    conditionDefs=conditionSets{conditionCounter}(4:end);

    disp(conditionSets{conditionCounter}{1});
    groupBy=conditionSets{conditionCounter}{2};
    analysisMode=conditionSets{conditionCounter}{3};
    nConditions=length(conditionDefs);

    %% init
    allData=cell(1, nConditions);
    dataLabel=cell(1, nConditions);
    labelCount=zeros(1, nConditions);
    nDataPoints=zeros(1, nConditions);

    %% Break up sessions into animal groups
    if ~strcmp(groupBy, 'mouse')
        mouseIDs={'all'};
    else
        mouseIDs=unique(cellfun(@(x) betweenDashes(x), groupsToAnalyze, 'UniformOutput', false));
    end

    for mouseCounter=1:length(mouseIDs)
        switch groupBy
            case'mouse'
                mouseID=mouseIDs{mouseCounter};
                disp(['Gathering ' mouseID]);
                sessionsToAnalyze=who(['processed_' mouseID '*'])';
            case 'all'
                mouseID='ALL';
                disp('Gathering ALL');
                sessionsToAnalyze=groupsToAnalyze;
            case 'theseSessions'
                mouseID='session';
                disp('Comparing by session');
                sessionsToAnalyze={''};
        end

        %% loops to gather data
        for channelIndex=channelList
            disp(['Processing channel index ' num2str(channelIndex)]);
            for sessionCountner=1:length(sessionsToAnalyze)

                if ~strcmp(groupBy, 'theseSessions')
                    assignin('base', 'processed', eval(sessionsToAnalyze{sessionCountner}));
                    disp(['   Loaded ' sessionsToAnalyze{sessionCountner}]);
                    params=processed.params;

                    % add trials since last switch and until next switch to the trial Table
                    nTrials=size(processed.trialTable, 1);
                end

                conditionStrings=cell(nConditions, 1);
                conditionDescriptor='';
                for sCounter=1:nConditions
                    condDef=conditionDefs{sCounter};
                    alignment=condDef{2};
                    condition=condDef{1};
                    startPt=condDef{3}(1);
                    endPt=condDef{3}(2);

                    if sCounter==1
                        conditionStrings{sCounter}=[alignment ' ['...
                            num2str(startPt) ' ' num2str(endPt) '] cond=' condition ' '];
                    else
                        conditionStrings{sCounter}=[condition ' '];
                    end
                    conditionDescriptor=[conditionDescriptor conditionStrings{sCounter}];

                    %           disp(conditionStrings{sCounter})

                    if strcmp(groupBy, 'theseSessions')
                        assignin('base', 'processed', eval(condDef{4}));
                        disp(['   Loaded ' condDef{4}]);
                        params=processed.params;

                        % add trials since last switch and until next switch to the trial Table
                        nTrials=size(processed.trialTable, 1);
                        conditionStrings{sCounter}=[condDef{4} ' ' ...
                            conditionStrings{sCounter}];
                    end

                    if contains(swappedChannelMice, params.mouse)% search if it is a swapped mouse
                        channel=channelSwaps(channelIndex); % do the swap
                        swappedChannels=true; % store swap
                    else
                        channel=defaultChannelMatching(channelIndex); % don't swap.  Use default
                        swappedChannels=false; % store swap
                    end

                    newData=[];
                    if ~isempty(processed.signals{channel})
                        switch analysisMode
                            case 'trials' % all trials
                                newData=extractMatrix(processed.signals{channel}, processed.ph.(alignment).(condition).eventIndices,    ...
                                    startPt, endPt);
                            case 'means'
                                newData=processed.ph.(alignment).(condition).photometry_mean{channel}(1+params.ptsKeep_before+(-startPt:endPt));
                        end
                    end

                    if ~isempty(newData)
                        if isempty(allData{sCounter})
                            allData{sCounter}=newData;
                            dataLabel{sCounter}=repmat(sCounter, size(newData,1), 1);
                            nDataPoints(sCounter)=size(newData,2);
                        else
                            allData{sCounter}=cat(1, allData{sCounter},  newData);
                            dataLabel{sCounter}=cat(1, dataLabel{sCounter},  repmat(sCounter, size(newData,1), 1));
                        end
                    end
                end
            end

            if var(nDataPoints)~=0
                error('WARNING: different number of data points per condition')
            else
                nDataPoints=nDataPoints(1);
            end

            %% merge both conditions and z-score together
            mergedAllData=[];
            figure; hold on
            [h,p,ci]=ttest2(mean(allData{1}'), mean(allData{2}'))

            for sCounter=1:nConditions
                newData=allData{sCounter};
                histogram(mean(allData{sCounter}'))

                if isempty(mergedAllData)
                    mergedAllData=newData;
                    mergedDataLabels=dataLabel{sCounter};
                else
                    mergedAllData=cat(1, mergedAllData, newData);
                    mergedDataLabels=cat(1, mergedDataLabels, dataLabel{sCounter});
                end
                labelCount(sCounter)=size(allData{sCounter},1);
            end

            if numel(mergedAllData)>0
                % basics
                dataSize=size(mergedAllData);
                endCol=dataSize(2);

                % linear and z-score
                dataSize=size(mergedAllData);
                if zScoreAllData
                    mergedAllData=reshape(mergedAllData, 1, numel(mergedAllData)); % linearize
                    mergedAllData=normalize(mergedAllData); % z-score
                    mergedAllData=reshape(mergedAllData, dataSize);
                end

                %% set up analysis
                minTrainSize=min(floor(trainFraction * labelCount));
                minTestSize=min(floor(testFraction * labelCount));

                trainSets=zeros(nConditions, minTrainSize);
                testSets=zeros(nConditions, minTestSize);

                trainPred=zeros(nModels, 1);
                testPred=zeros(nModels, 1);
                testPredHyp=zeros(nModels, 1);

                trainMoments=zeros(nConditions, 4, nModels);

                %% run through real data and then shuffled
                for randCounter=1:2
                    drawnow

                    if randCounter==1
                        randomShuffle=false;
                    else
                        randomShuffle=true;
                    end
                    tableCounter=tableCounter+1;

                    statsTable(tableCounter,:)=dummyFill;
                    statsTable.condition(tableCounter)=conditionCounter;
                    statsTable.conditionString(tableCounter)=conditionDescriptor;
                    if strcmp(mouseID, 'session')
                        statsTable.mouseID(tableCounter)=params.mouse;
                    else
                        statsTable.mouseID(tableCounter)=mouseID;
                    end
                    statsTable.analysisMode(tableCounter)=analysisMode;
                    statsTable.randomShuffle(tableCounter)=randomShuffle;
                    statsTable.testFraction(tableCounter)=testFraction;
                    statsTable.trainFraction(tableCounter)=trainFraction;
                    statsTable.channel(tableCounter)=channel;
                    statsTable.LDA_nModels(tableCounter)=nModels;
                    statsTable.channelSwapped(tableCounter)=swappedChannels;

                    disp(' ')
                    disp(['Running models Channel ' num2str(channel) ' rand ' num2str(randCounter-1)])

                    if randomShuffle
                        disp('   with random shuffling');
                    end

                    momentsP=zeros(nModels, 4);
                    momentsH=zeros(nModels, 4);
                    for mCounter=1:nModels
                        %          close all
                        if nModels>100 && mCounter/(nModels/10)==floor(mCounter/(nModels/10))
                            disp(mCounter)
                        end

                        %% set up indices of each test/train set
                        for sCounter=1:nConditions
                            sIndices=find(mergedDataLabels==sCounter);

                            nIndices=length(sIndices);
                            testII=randperm(nIndices, minTestSize);
                            testI=sort(sIndices(testII));
                            testSets(sCounter,:)=testI;

                            nonTestIndices=setdiff(sIndices, testI);
                            trainII=randperm(length(nonTestIndices), minTrainSize);
                            trainSets(sCounter,:)=sort(nonTestIndices(trainII));
                        end

                        testIndices=reshape(testSets', numel(testSets), 1);
                        trainIndices=reshape(trainSets', numel(trainSets), 1);

                        % pull data - not really necessary but makes it easier
                        mergedTestData=mergedAllData(testIndices,:);
                        mergedTrainData=mergedAllData(trainIndices,:);
                        mergedTestLabels=mergedDataLabels(testIndices);
                        mergedTrainLabels=mergedDataLabels(trainIndices);

                        % randomize labels and data on this balanced set
                        if randomShuffle % shuffle the labels maintaining balance
                            mergedTestLabels=mergedTestLabels(randperm(length(mergedTestLabels), length(mergedTestLabels)));
                            mergedTrainLabels=mergedTrainLabels(randperm(length(mergedTrainLabels), length(mergedTrainLabels)));
                        end

                        %% run LDA model
                        % with default - may overfit and reduce fit quality on test data
                        mdoelWorked=true;
                        try
                            modelType='quadratic'; % linear may be better for the means (vs. all)
                            Mdl = fitcdiscr(mergedTrainData, mergedTrainLabels, 'DiscrimType', modelType);
                        catch
                            modelType='pseudoQuadratic'; % linear may be better for the means (vs. all)
                            Mdl = fitcdiscr(mergedTrainData, mergedTrainLabels, 'DiscrimType', modelType);
                        end

                        yy=predict(Mdl, mergedTrainData);
                        trainPred(mCounter)=mean((mergedTrainLabels==yy));
                        yy=predict(Mdl, mergedTestData);
                        testPred(mCounter)=mean((mergedTestLabels==yy));

                        %% comparisons to means and calc moments
                        cTrainData={};
                        for sCounter=1:nConditions
                            cTrainData{sCounter}=mergedTrainData(mergedTrainLabels==sCounter, 1:endCol);

                            % moments
                            trainMoments(sCounter, 1, mCounter)=mean(mean(cTrainData{sCounter}, 2));
                            trainMoments(sCounter, 2, mCounter)=mean(var(cTrainData{sCounter}, 0, 2));
                            trainMoments(sCounter, 3, mCounter)=mean(skewness(cTrainData{sCounter}, 1, 2));
                            trainMoments(sCounter, 4, mCounter)=mean(kurtosis(cTrainData{sCounter}, 1, 2));
                        end
                        [h,p]=ttest2(mean(cTrainData{1}, 2), mean(cTrainData{2}, 2), 'alpha', alphaForTTest);
                        momentsP(mCounter, 1)=p;
                        momentsH(mCounter, 1)=h;
                        [h,p]=ttest2(var(cTrainData{1}, 0, 2), var(cTrainData{2}, 0, 2), 'alpha', alphaForTTest);
                        momentsP(mCounter, 2)=p;
                        momentsH(mCounter, 2)=h;
                        [h,p]=ttest2(skewness(cTrainData{1}, 1, 2), skewness(cTrainData{2}, 1, 2), 'alpha', alphaForTTest);
                        momentsP(mCounter, 3)=p;
                        momentsH(mCounter, 3)=h;
                        [h,p]=ttest2(kurtosis(cTrainData{1}, 1, 2), kurtosis(cTrainData{2}, 1, 2), 'alpha', alphaForTTest);
                        momentsP(mCounter, 4)=p;
                        momentsH(mCounter, 4)=h;
                    end


                    virusName='';
                    mouseVirusIndex=find(strcmp(params.mouse, mouseViruses(:,1)));
                    if ~isempty(mouseVirusIndex)
                        vList=mouseViruses{mouseVirusIndex(1),2};
                        virusToFind=num2str(vList(channel));
                        getVirusName
                    end
                    statsTable.channelVirus(tableCounter)=virusName;

                    statsTable.modelType(tableCounter)=modelType;
                    statsTable.LDA_trainPred_avg(tableCounter)=mean(trainPred);
                    statsTable.LDA_trainPred_sd(tableCounter)=std(trainPred);
                    disp(['OVERALL train set accuracy: ' ...
                        num2str(statsTable.LDA_trainPred_avg(tableCounter))...
                        ' +/- ' num2str(statsTable.LDA_trainPred_sd(tableCounter)) ])

                    statsTable.LDA_testPred_avg(tableCounter)=mean(testPred);
                    statsTable.LDA_testPred_sd(tableCounter)=std(testPred);
                    disp(['OVERALL test set accuracy: '  ...
                        num2str(statsTable.LDA_testPred_avg(tableCounter))...
                        ' +/- ' num2str(statsTable.LDA_testPred_sd(tableCounter)) ])

                    if runLDAhyp
                        %   with LDA hyper parameter sweep and cross-validation - better fits
                        Mdl = fitcdiscr(mergedTrainData,mergedTrainLabels, ...
                            'OptimizeHyperparameters', 'auto',...
                            'HyperparameterOptimizationOptions', ...
                            struct('ShowPlots', false, 'Verbose', 0, ...
                            'Repartition', true, ...
                            'AcquisitionFunctionName','expected-improvement-plus'));
                        %    close all
                        yy=predict(Mdl, mergedTestData);
                        testPredHyp=mean((mergedTestLabels==yy));
                        yy=predict(Mdl, mergedTrainData);
                        trainPredHyp=mean((mergedTrainLabels==yy));
                        disp(['OVERALL hyp test set accuracy: '  num2str(testPredHyp) ' train ' num2str(trainPredHyp)])
                        statsTable.LDA_hyp_trainPred(tableCounter)=trainPredHyp;
                        statsTable.LDA_hyp_testPred(tableCounter)=testPredHyp;
                    end

                    if runSVMhyp
                        %   with SVM hyper parameter sweep and cross-validation - better fits
                        Mdl = fitcsvm(mergedTrainData,mergedTrainLabels, ...
                            'OptimizeHyperparameters', 'auto',...
                            'HyperparameterOptimizationOptions', ...
                            struct('ShowPlots', false, 'Verbose', 0, ...
                            'Repartition', true, ...
                            'AcquisitionFunctionName','expected-improvement-plus'));
                        %    close all
                        yy=predict(Mdl, mergedTestData);
                        testPredHyp=mean((mergedTestLabels==yy));
                        yy=predict(Mdl, mergedTrainData);
                        trainPredHyp=mean((mergedTrainLabels==yy));

                        disp(['OVERALL SVM hyp test set accuracy: '  num2str(testPredHyp) ' train ' num2str(trainPredHyp)])
                        statsTable.SVM_hyp_trainPred(tableCounter)=trainPredHyp;
                        statsTable.SVM_hyp_testPred(tableCounter)=testPredHyp;
                    end

                    for sCounter=1:nConditions
                        statsTable.(['cond' num2str(sCounter)])(tableCounter)=conditionStrings{sCounter};

                        for momentCounter=1:4
                            statsTable.(['moment' num2str(momentCounter) '_train_cond' num2str(sCounter) '_avg'])(tableCounter)=...
                                mean(squeeze(trainMoments(sCounter, momentCounter, :)));
                            statsTable.(['moment' num2str(momentCounter) '_train_cond' num2str(sCounter) '_sd'])(tableCounter)=...
                                std(squeeze(trainMoments(sCounter, momentCounter, :)));
                        end
                    end

                    for momentCounter=1:4
                        mString=num2str(momentCounter);
                        statsTable.(['moment' mString '_p_avg'])(tableCounter)=mean(momentsP(:,momentCounter));
                        statsTable.(['moment' mString '_p_sd'])(tableCounter)=std(momentsP(:,momentCounter));
                        statsTable.(['moment' mString '_H_avg'])(tableCounter)=mean(momentsH(:,momentCounter));
                    end
                end
            end
        end
    end
end

%% calcalate dPrimes
dPrimeTable=table;
dPrimeTable.mouseID=statsTable.mouseID(1:2:end);
dPrimeTable.condition=statsTable.condition(1:2:end);
dPrimeTable.channel=statsTable.channel(1:2:end);

colNames=statsTable.Properties.VariableNames;
avgColumns=find(contains(colNames, '_avg'));

for cCounter=1:nConditions
    dPrimeTable.(['cond' num2str(cCounter)])=statsTable.(['cond' num2str(cCounter)])(1:2:end);
end

dPrimeArray=zeros(size(dPrimeTable, 1), 0);
dPrimeNames={};

for cCounter=avgColumns
    cName=statsTable.Properties.VariableNames{cCounter};
    cNameDash=strfind(cName, '_avg');
    cNameStub=cName(1:cNameDash(end)-1);
    cNameDP=[cNameStub '_dp'];
    a1=statsTable{1:2:end, cCounter};
    a2=statsTable{2:2:end, cCounter};
    s1=statsTable{1:2:end, cCounter+1};
    s2=statsTable{2:2:end, cCounter+1};
    dPrimeTable.(cNameDP)=abs(a1-a2)./(((s1.^2+s2.^2)/2).^0.5);
    dPrimeNames{end+1}=removeDash(cNameStub);
end

dPrimeTable.mean=abs(statsTable.moment1_train_cond1_avg(1:2:end)-statsTable.moment1_train_cond2_avg(1:2:end))./ ...
    (((statsTable.moment1_train_cond1_sd(1:2:end).^2+statsTable.moment1_train_cond2_sd(1:2:end).^2)/2).^0.5);
dPrimeNames{end+1}='mean';


dPrimeTable.var=abs(statsTable.moment2_train_cond1_avg(1:2:end)-statsTable.moment2_train_cond2_avg(1:2:end))./ ...
    (((statsTable.moment2_train_cond1_sd(1:2:end).^2+statsTable.moment2_train_cond2_sd(1:2:end).^2)/2).^0.5);
dPrimeNames{end+1}='var';


dPrimeTable.skew=abs(statsTable.moment3_train_cond1_avg(1:2:end)-statsTable.moment3_train_cond2_avg(1:2:end))./ ...
    (((statsTable.moment3_train_cond1_sd(1:2:end).^2+statsTable.moment3_train_cond2_sd(1:2:end).^2)/2).^0.5);
dPrimeNames{end+1}='skew';


dPrimeTable.kurtosis=abs(statsTable.moment4_train_cond1_avg(1:2:end)-statsTable.moment4_train_cond2_avg(1:2:end))./ ...
    (((statsTable.moment4_train_cond1_sd(1:2:end).^2+statsTable.moment4_train_cond2_sd(1:2:end).^2)/2).^0.5);
dPrimeNames{end+1}='kurtosis';

save(['statsAndMore ' datestr(clock) '.mat'],   'statsTable','dPrimeTable', 'dPrimeNames', 'conditionSets', 'mouseViruses', 'saveName', 'groupsToAnalyze')
save(['statsAndMore ' saveName '.mat'],         'statsTable','dPrimeTable', 'dPrimeNames', 'conditionSets', 'mouseViruses', 'saveName', 'groupsToAnalyze')



