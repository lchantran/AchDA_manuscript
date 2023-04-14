%% reload data, if needed

if ~rerunOldAnalysisSet
    groupsToAnalyze=who('processed_*')';
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
    %         if neededToReload
    %             processCeliaWord
    %         end
end


%% setup special mice
ABT_virusCode;

defaultChannelMatching=[1 2 0 0 5 6]; % this is how to use the channels. Here we just map 1 to 2 etc...
channelSwaps=[5 6 0 0 1 2]; % this is how to rearrange them for a subset of mice

mouseViruses={...
    'WT8'  [277   0     0 0     277   0]; ...
    'WT9'  [277   0     0 0     277   0]; ...
    'WT10'  [277   0     0 0     277   0]; ...
    'WT11'  [277   0     0 0     277   0]; ...
    'WT21'  [277   0     0 0     277   0]; ...
    'WT22'  [277   0     0 0     277   0]; ...
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
statsTable.mean=zeros(0,1);
statsTable.var=zeros(0,1);
statsTable.skew=zeros(0,1);
statsTable.kurtosis=zeros(0,1);
statsTable.anovan=cell(0,1);
statsTable.session_p=zeros(0,1);
statsTable.condition_p=zeros(0,1);
statsTable.session_F=zeros(0,1);
statsTable.condition_F=zeros(0,1);
statsTable.ttest_mean_p=zeros(0,1);
statsTable.ttest_max_p=zeros(0,1);
statsTable.ttest_min_p=zeros(0,1);
statsTable.ttest_delta_p=zeros(0,1);
statsTable.LDA_hyp_trainPred=zeros(0,1);
statsTable.LDA_hyp_testPred=zeros(0,1);

%% find the maximum number of conditions to set up the tables
maxConditions=0;
for sCounter=1:length(conditionSets)
    conditionDefs=conditionSets{sCounter};
    maxConditions=max(maxConditions, length(conditionDefs)-3);
end

%% Set up the statsTable to hold results
dummyFill={'' 0 '' 0 '' false '' '' false 0 0 0 0 0 0 {} 0 0 0 0 0 0 0 0 0 0};

allValues={};
for sCounter=1:maxConditions
    statsTable.(['cond' num2str(sCounter)])=strings(0,1); % the name of the condition

    statsTable.(['moment1_bootstrap_cond' num2str(sCounter) '_avg'])=zeros(0,1); % the average and SD of the first 4 moments of all the random train data sets
    statsTable.(['moment1_bootstrap_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['moment2_bootstrap_cond' num2str(sCounter) '_avg'])=zeros(0,1);
    statsTable.(['moment2_bootstrap_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['moment3_bootstrap_cond' num2str(sCounter) '_avg'])=zeros(0,1);
    statsTable.(['moment3_bootstrap_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['moment4_bootstrap_cond' num2str(sCounter) '_avg'])=zeros(0,1);
    statsTable.(['moment4_bootstrap_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['mean_cond' num2str(sCounter) '_avg'])=zeros(0,1);
    statsTable.(['mean_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['max_cond' num2str(sCounter) '_avg'])=zeros(0,1);
    statsTable.(['max_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['min_cond' num2str(sCounter) '_avg'])=zeros(0,1);
    statsTable.(['min_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['delta_cond' num2str(sCounter) '_avg'])=zeros(0,1);
    statsTable.(['delta_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['var_cond' num2str(sCounter) '_avg'])=zeros(0,1);
    statsTable.(['var_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    dummyFill=[dummyFill {'' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}];
end

%% start at begining of table

tableCounter=0;


for channelToAnalyze=channelsToAnalyze
    %% loop through all the conditions to test
    for conditionCounter=1:length(conditionSets)
        conditionDefs=conditionSets{conditionCounter}(4:end);

        disp(conditionSets{conditionCounter}{1});
        groupBy=conditionSets{conditionCounter}{2};
        analysisMode=conditionSets{conditionCounter}{3};
        nConditions=length(conditionDefs);

        % init
        %     allData=cell(1, nConditions);
        %     conditionLabel=cell(1, nConditions);
        %     labelCount=zeros(1, nConditions);

        %% Break up sessions into animal groups
        if ~strcmp(groupBy, 'mouse')
            mouseIDs={'all'};
        else
            mouseIDs=unique(cellfun(@(x) betweenDashes(x), groupsToAnalyze, 'UniformOutput', false));
        end
        allMice=unique(cellfun(@(x) betweenDashes(x), groupsToAnalyze, 'UniformOutput', false));

        %    mouseIDs=[mouseIDs flip(mouseIDs)]; %flip(mouseIDs);

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


            %% init
            allData=cell(1, nConditions);
            mouseLabel=cell(1, nConditions);
            sessionLabel=cell(1, nConditions);
            conditionLabel=cell(1, nConditions);
            nestedLabel=cell(1, nConditions);

            nestedConditionCounter=0;
            labelCount=zeros(1, nConditions);

            %% loops to gather data
            disp(['Processing channel index ' num2str(channelToAnalyze)]);
            for sessionCountner=1:length(sessionsToAnalyze)
                if ~strcmp(groupBy, 'theseSessions')
                    assignin('base', 'processed', eval(sessionsToAnalyze{sessionCountner}));
                    disp(['   Loaded ' sessionsToAnalyze{sessionCountner}]);
                    params=processed.params;
                    mouse=params.mouse;
                    % add trials since last switch and until next switch to the trial Table
                    nTrials=size(processed.trialTable, 1);
                end

                conditionStrings=cell(nConditions, 1);
                conditionDescriptor='';
                for sCounter=1:nConditions
                    nestedConditionCounter=nestedConditionCounter+1;
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
                        mouse=params.mouse;

                        % add trials since last switch and until next switch to the trial Table
                        nTrials=size(processed.trialTable, 1);
                        conditionStrings{sCounter}=[condDef{4} ' ' ...
                            conditionStrings{sCounter}];
                    end

                    mouseLabelNum=find(strcmp(allMice, params.mouse));

                    if any(contains(swappedChannelMice, params.mouse))% search if it is a swapped mouse
                        channel=channelSwaps(channelToAnalyze); % do the swap
                        swappedChannels=true; % store swap
                    else
                        channel=defaultChannelMatching(channelToAnalyze); % don't swap.  Use default
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
                            nestedLabel{sCounter}=repmat(nestedConditionCounter, size(newData,1), 1);
                            conditionLabel{sCounter}=repmat(sCounter, size(newData,1), 1);
                            sessionLabel{sCounter}=repmat(sessionCountner, size(newData,1), 1);
                            mouseLabel{sCounter}=repmat(mouseLabelNum, size(newData,1), 1);
                        else
                            allData{sCounter}=cat(1, allData{sCounter},  newData);
                            nestedLabel{sCounter}=cat(1, nestedLabel{sCounter},  repmat(nestedConditionCounter, size(newData,1), 1));
                            conditionLabel{sCounter}=cat(1, conditionLabel{sCounter},  repmat(sCounter, size(newData,1), 1));
                            sessionLabel{sCounter}=cat(1, sessionLabel{sCounter},  repmat(sessionCountner, size(newData,1), 1));
                            mouseLabel{sCounter}=cat(1, mouseLabel{sCounter},  repmat(mouseLabelNum, size(newData,1), 1));
                        end
                    else
                        disp('no new data')
                    end
                end
            end

            %% merge both conditions and z-score together
            mergedAllData=[];

            for sCounter=1:nConditions
                newData=allData{sCounter};

                if isempty(mergedAllData)
                    mergedAllData=newData;
                    mergedNestedLabels=nestedLabel{sCounter};
                    mergedConditionLabels=conditionLabel{sCounter};
                    mergedSessionLabels=sessionLabel{sCounter};
                    mergedMouseLabels=mouseLabel{sCounter};
                else
                    mergedAllData=cat(1, mergedAllData, newData);
                    mergedNestedLabels=cat(1, mergedNestedLabels, nestedLabel{sCounter});
                    mergedConditionLabels=cat(1, mergedConditionLabels, conditionLabel{sCounter});
                    mergedSessionLabels=cat(1, mergedSessionLabels, sessionLabel{sCounter});
                    mergedMouseLabels=cat(1, mergedMouseLabels, mouseLabel{sCounter});
                end
                labelCount(sCounter)=size(allData{sCounter},1);
            end

            if numel(mergedAllData)>0
                % basics
                dataSize=size(mergedAllData);
                endCol=dataSize(2);

                % linear and z-score
                dataSize=size(mergedAllData);
                mergedAllData=reshape(mergedAllData, 1, numel(mergedAllData)); % linearize
                allDataMoments=zeros(1,4);
                allDataMoments(1)=mean(mergedAllData);
                allDataMoments(2)=var(mergedAllData);
                allDataMoments(3)=skewness(mergedAllData);
                allDataMoments(4)=kurtosis(mergedAllData);
                if zScoreAllData
                    mergedAllData=normalize(mergedAllData); % z-score
                end
                mergedAllData=reshape(mergedAllData, dataSize);
            end

            anovaTable={};
            if conditionCounter>0 %==1
                % extraSavePrefix=[mouse '_'];
                % varSearchList={{[mouse '*']}}; % what subset of mice to analyze.  Leave at '' to get all the ones in memory
                % sumAll;
                %                pGraphSummary(processed_sum.ph.SI, {[mouse '_RR'], [mouse '_LR'], [mouse '_RNR'], [mouse '_LNR'], }, [1 5], tRange=[-41 0.054]);


                %mergedData=max(mergedAllData, [], 2);
                %mergedData=mean(mergedAllData, 2);
                %mergedData=max(mergedAllData, [], 2)-min(mergedAllData, [], 2);
                mergedData=var(mergedAllData, [], 2);
                varnames={'mouse', 'session', 'condition'};
                [p,anovaTable,stats,terms]=anovan(mergedData, {mergedSessionLabels mergedConditionLabels}, 'varnames', varnames(2:3));%, 'model', 'interaction');
                %                [p,anovaTable,stats,terms]=anovan(mergedMaxs, {mergedSessionLabels mergedNestedLabels}, 'varnames', varnames(2:3), 'model', 'interaction', 'nested', [0 0; 1 0]);
                %[p,anovaTable,stats,terms]=anovan(mergedMeans, {mergedSessionLabels mergedNestedLabels}, 'varnames', varnames(2:3), 'model', 'interaction', 'nested', [0 0; 1 0]);
                fp=[anovaTable{2,7} anovaTable{3,7} anovaTable{2,6} anovaTable{3,6}];

                d1=mean(allData{1}, 2);
                d2=mean(allData{2}, 2);

                [tth,ttp_mean,ttci]=ttest2(d1, d2);
                if exist('keepAllValues') && keepAllValues
                    allValues{tableCounter+1, 1}={allData{1}, allData{2}};
                    allValues{tableCounter+1, 2}={d1, d2};
                end

                d1=max(allData{1}, [], 2);
                d2=max(allData{2}, [], 2);
                [tth,ttp_max,ttci]=ttest2(d1, d2);
                if exist('keepAllValues') && keepAllValues
                    allValues{tableCounter+1, 3}={d1, d2};
                end

                d1=min(allData{1}, [], 2);
                d2=min(allData{2}, [], 2);
                [tth,ttp_min,ttci]=ttest2(d1, d2);
                if exist('keepAllValues') && keepAllValues
                    allValues{tableCounter+1, 4}={d1, d2};
                end

                d1=max(allData{1}, [], 2)-min(allData{1}, [], 2);
                d2=max(allData{2}, [], 2)-min(allData{2}, [], 2);
                [tth,ttp_delta,ttci]=ttest2(d1, d2);
                if exist('keepAllValues') && keepAllValues
                    allValues{tableCounter+1, 5}={d1, d2};
                end
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
            peaks=zeros(nConditions, 3, nModels);

            %% run through real data and then shuffled
            for randCounter=1%1:2
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
                statsTable.channelSwapped(tableCounter)=swappedChannels;

                disp(' ')
                disp(['Running models Channel ' num2str(channel) ' rand ' num2str(randCounter-1)])

                if randomShuffle
                    disp('   with random shuffling');
                end

                for sCounter=1:nConditions
                    statsTable.(['mean_cond' num2str(sCounter) '_avg'])(tableCounter)=mean(mean(allData{sCounter}, 2));
                    statsTable.(['mean_cond' num2str(sCounter) '_sd'])(tableCounter)=std(mean(allData{sCounter}, 2));
                    statsTable.(['max_cond' num2str(sCounter) '_avg'])(tableCounter)=mean(max(allData{sCounter}, [], 2));
                    statsTable.(['max_cond' num2str(sCounter) '_sd'])(tableCounter)=std(max(allData{sCounter}, [], 2));
                    statsTable.(['min_cond' num2str(sCounter) '_avg'])(tableCounter)=mean(min(allData{sCounter}, [], 2));
                    statsTable.(['min_cond' num2str(sCounter) '_sd'])(tableCounter)=std(min(allData{sCounter}, [], 2));
                    statsTable.(['delta_cond' num2str(sCounter) '_avg'])(tableCounter)=mean(...
                        max(allData{sCounter}, [], 2)-min(allData{sCounter}, [], 2));
                    statsTable.(['delta_cond' num2str(sCounter) '_sd'])(tableCounter)=std(...
                        max(allData{sCounter}, [], 2)-min(allData{sCounter}, [], 2));
                    statsTable.(['var_cond' num2str(sCounter) '_avg'])(tableCounter)=mean(var(allData{sCounter}, [], 2));
                    statsTable.(['var_cond' num2str(sCounter) '_sd'])(tableCounter)=std(var(allData{sCounter}, [], 2));
                end

                statsTable.mean(tableCounter)=allDataMoments(1);
                statsTable.var(tableCounter)=allDataMoments(2);
                statsTable.skew(tableCounter)=allDataMoments(3);
                statsTable.kurtosis(tableCounter)=allDataMoments(4);

                statsTable.ttest_mean_p(tableCounter)=ttp_mean;
                statsTable.ttest_max_p(tableCounter)=ttp_max;
                statsTable.ttest_min_p(tableCounter)=ttp_min;
                statsTable.ttest_delta_p(tableCounter)=ttp_delta;

                for mCounter=1:nModels
                    close all hidden
                    if nModels>100 && mCounter/(nModels/10)==floor(mCounter/(nModels/10))
                        disp(mCounter)
                    end

                    %% set up indices of each test/train set
                    for sCounter=1:nConditions
                        sIndices=find(mergedConditionLabels==sCounter);

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
                    mergedTestLabels=mergedConditionLabels(testIndices);
                    mergedTrainLabels=mergedConditionLabels(trainIndices);

                    % randomize labels and data on this balanced set
                    if randomShuffle % shuffle the labels maintaining balance
                        mergedTestLabels=mergedTestLabels(randperm(length(mergedTestLabels), length(mergedTestLabels)));
                        mergedTrainLabels=mergedTrainLabels(randperm(length(mergedTrainLabels), length(mergedTrainLabels)));
                    end

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
                end

                statsTable.anovan{tableCounter}=anovaTable;
                statsTable.session_p(tableCounter)=fp(1);
                statsTable.condition_p(tableCounter)=fp(2);
                statsTable.session_F(tableCounter)=fp(3);
                statsTable.condition_F(tableCounter)=fp(4);

                virusName='';
                mouseVirusIndex=find(strcmp(params.mouse, mouseViruses(:,1)));
                if ~isempty(mouseVirusIndex)
                    vList=mouseViruses{mouseVirusIndex(1),2};
                    virusToFind=num2str(vList(channel));
                    getVirusName
                end
                statsTable.channelVirus(tableCounter)=virusName;


                for sCounter=1:nConditions
                    statsTable.(['cond' num2str(sCounter)])(tableCounter)=conditionStrings{sCounter};

                    for momentCounter=1:4
                        statsTable.(['moment' num2str(momentCounter) '_bootstrap_cond' num2str(sCounter) '_avg'])(tableCounter)=...
                            mean(squeeze(trainMoments(sCounter, momentCounter, :)));
                        statsTable.(['moment' num2str(momentCounter) '_bootstrap_cond' num2str(sCounter) '_sd'])(tableCounter)=...
                            std(squeeze(trainMoments(sCounter, momentCounter, :)));
                    end
                end
            end
            if runLDAhyp
                %   with LDA hyper parameter sweep and cross-validation - better fits
                try
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
                catch
                    'LDA failed'
                end
            end
        end

    end
end
%% calcalate dPrimes

save(['statsAndMore ' datestr(clock) '.mat'],   'statsTable', 'conditionSets', 'mouseViruses', 'saveName', 'groupsToAnalyze', ...
    'allValues')
save(['statsAndMore ' saveName '.mat'],         'statsTable', 'conditionSets', 'mouseViruses', 'saveName', 'groupsToAnalyze', ...
    'allValues')



