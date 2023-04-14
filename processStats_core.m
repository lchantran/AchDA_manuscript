%% reload data, if needed

if ~rerunOldAnalysisSet
    groupsToAnalyze=who('processed_WT64*')';
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
statsTable.moment1_dp_avg=zeros(0,1);
statsTable.moment1_dp_sd=zeros(0,1);
statsTable.moment2_dp_avg=zeros(0,1);
statsTable.moment2_dp_sd=zeros(0,1);
statsTable.moment3_dp_avg=zeros(0,1);
statsTable.moment3_dp_sd=zeros(0,1);
statsTable.moment4_dp_avg=zeros(0,1);
statsTable.moment4_dp_sd=zeros(0,1);
statsTable.anovan=cell(0,1);

%% find the maximum number of conditions to set up the tables
maxConditions=0;
for sCounter=1:length(conditionSets)
    conditionDefs=conditionSets{sCounter};
    maxConditions=max(maxConditions, length(conditionDefs)-3);
end

%% Set up the statsTable to hold results
dummyFill={'' 0 '' 0 '' false '' '' false 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 {}};

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
    statsTable.(['max_cond' num2str(sCounter) '_avg'])=zeros(0,1); 
    statsTable.(['max_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['min_cond' num2str(sCounter) '_avg'])=zeros(0,1); 
    statsTable.(['min_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    statsTable.(['max_dev_cond' num2str(sCounter) '_avg'])=zeros(0,1); 
    statsTable.(['max_dev_cond' num2str(sCounter) '_sd'])=zeros(0,1);
    dummyFill=[dummyFill {'' 0 0 0 0 0 0 0 0 0 0 0 0 0 0}];
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

    % init
%     allData=cell(1, nConditions);
%     conditionLabel=cell(1, nConditions);
%     labelCount=zeros(1, nConditions);
%     nDataPoints=zeros(1, nConditions);

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
        nDataPoints=zeros(1, nConditions);

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

                        nDataPoints(sCounter)=size(newData,2);
                    else
                        allData{sCounter}=cat(1, allData{sCounter},  newData);
                        nestedLabel{sCounter}=cat(1, nestedLabel{sCounter},  repmat(nestedConditionCounter, size(newData,1), 1));
                        conditionLabel{sCounter}=cat(1, conditionLabel{sCounter},  repmat(sCounter, size(newData,1), 1));
                        sessionLabel{sCounter}=cat(1, sessionLabel{sCounter},  repmat(sessionCountner, size(newData,1), 1));
                        mouseLabel{sCounter}=cat(1, mouseLabel{sCounter},  repmat(mouseLabelNum, size(newData,1), 1));

                        nDataPoints(sCounter)=nDataPoints(sCounter)+size(newData,2);
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
        %    figure; hold on
        %   [h,p,ci]=ttest2(mean(allData{1}'), mean(allData{2}'));

        for sCounter=1:nConditions
            newData=allData{sCounter};
            %      histogram(mean(allData{sCounter}'))

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
            if zScoreAllData
                mergedAllData=reshape(mergedAllData, 1, numel(mergedAllData)); % linearize
                mergedAllData=normalize(mergedAllData); % z-score
                mergedAllData=reshape(mergedAllData, dataSize);
            end

            anovaTable={};
            if conditionCounter>0 %==1
                % extraSavePrefix=[mouse '_'];
                % varSearchList={{[mouse '*']}}; % what subset of mice to analyze.  Leave at '' to get all the ones in memory
                % sumAll;
%                pGraphSummary(processed_sum.ph.SI, {[mouse '_RR'], [mouse '_LR'], [mouse '_RNR'], [mouse '_LNR'], }, [1 5], tRange=[-41 0.054]);
                
                
                mergedMaxs=max(mergedAllData, [], 2);
                varnames={'mouse', 'session', 'condition'};
%                [p,anovaTable,stats,terms]=anovan(mergedMaxs, {mergedSessionLabels mergedConditionLabels}, 'varnames', varnames(2:3), 'model', 'interaction');
                [p,anovaTable,stats,terms]=anovan(mergedMaxs, {mergedSessionLabels mergedNestedLabels}, 'varnames', varnames(2:3), 'model', 'interaction', 'nested', [0 0; 1 0]);
                conditionDescriptor
                p
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
                momentsDP=zeros(nModels, 4);

                for mCounter=1:nModels
                    %          close all
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

                        peaks(sCounter, 1, mCounter)=mean(max(cTrainData{sCounter}, [], 2));
                        peaks(sCounter, 2, mCounter)=mean(min(cTrainData{sCounter}, [], 2));
                        peaks(sCounter, 3, mCounter)=mean(max(abs(max(cTrainData{sCounter}, [], 2)), abs(min(cTrainData{sCounter}, [], 2))));                        
                    end
                    [h,p]=ttest2(mean(cTrainData{1}, 2), mean(cTrainData{2}, 2), 'alpha', alphaForTTest);
                    momentsP(mCounter, 1)=p;
                    momentsDP(mCounter, 1)=(mean(mean(cTrainData{1}, 2))-mean(mean(cTrainData{2}, 2)))./...
                        (((var(mean(cTrainData{1}, 2))+var(mean(cTrainData{2}, 2)))/2).^0.5);

                    [h,p]=ttest2(var(cTrainData{1}, 0, 2), var(cTrainData{2}, 0, 2), 'alpha', alphaForTTest);
                    momentsP(mCounter, 2)=p;
                    momentsDP(mCounter, 2)=(mean(var(cTrainData{1}, 0, 2))-mean(var(cTrainData{2}, 0, 2)))./...
                        (((var(var(cTrainData{1}, 0, 2))+var(var(cTrainData{2}, 0, 2)))/2).^0.5);

                    [h,p]=ttest2(skewness(cTrainData{1}, 1, 2), skewness(cTrainData{2}, 1, 2), 'alpha', alphaForTTest);
                    momentsP(mCounter, 3)=p;
                    [h,p]=ttest2(kurtosis(cTrainData{1}, 1, 2), kurtosis(cTrainData{2}, 1, 2), 'alpha', alphaForTTest);
                    momentsP(mCounter, 4)=p;

                end

                statsTable.anovan{tableCounter}=anovaTable;

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

                    statsTable.(['max_cond' num2str(sCounter) '_avg'])(tableCounter)=...
                        mean(squeeze(peaks(sCounter, 1, :)));
                    statsTable.(['max_cond' num2str(sCounter) '_sd'])(tableCounter)=...
                        std(squeeze(peaks(sCounter, 1, :)));
                    statsTable.(['min_cond' num2str(sCounter) '_avg'])(tableCounter)=...
                        mean(squeeze(peaks(sCounter, 2, :)));
                    statsTable.(['min_cond' num2str(sCounter) '_sd'])(tableCounter)=...
                        std(squeeze(peaks(sCounter, 2, :)));
                    statsTable.(['max_dev_cond' num2str(sCounter) '_avg'])(tableCounter)=...
                        mean(squeeze(peaks(sCounter, 3, :)));
                    statsTable.(['max_dev_cond' num2str(sCounter) '_sd'])(tableCounter)=...
                        std(squeeze(peaks(sCounter, 3, :)));
                end

                for momentCounter=1:4
                    mString=num2str(momentCounter);
                    statsTable.(['moment' mString '_p_avg'])(tableCounter)=mean(momentsP(:,momentCounter));
                    statsTable.(['moment' mString '_p_sd'])(tableCounter)=std(momentsP(:,momentCounter));
                    statsTable.(['moment' mString '_dp_avg'])(tableCounter)=mean(abs(momentsDP(:,momentCounter)));
                    statsTable.(['moment' mString '_dp_sd'])(tableCounter)=std(abs(momentsDP(:,momentCounter)));
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



