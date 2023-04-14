% getAllSignals for a set of sessions


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
conditionSets={};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'Rew', 'SI', [0 20], 'processed_WT60_10182021'}   {'Rew', 'SI', [0 20], 'processed_WT60_10132021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'Rew', 'SI', [0 20], 'processed_WT61_10182021'}   {'Rew', 'SI', [0 20], 'processed_WT61_10132021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'Rew', 'SI', [0 20], 'processed_WT63_11222021'}   {'Rew', 'SI', [0 20], 'processed_WT63_11182021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'Rew', 'SI', [0 20], 'processed_WT64_11222021'}   {'Rew', 'SI', [0 20], 'processed_WT64_11182021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'Rew', 'SI', [0 20], 'processed_WT65_11222021'}   {'Rew', 'SI', [0 20], 'processed_WT65_11182021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'NoRew', 'SI', [0 10], 'processed_WT60_10182021'}   {'NoRew', 'SI', [0 10], 'processed_WT60_10132021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'NoRew', 'SI', [0 10], 'processed_WT61_10182021'}   {'NoRew', 'SI', [0 10], 'processed_WT61_10132021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'NoRew', 'SI', [0 10], 'processed_WT63_11222021'}   {'NoRew', 'SI', [0 10], 'processed_WT63_11182021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'NoRew', 'SI', [0 10], 'processed_WT64_11222021'}   {'NoRew', 'SI', [0 10], 'processed_WT64_11182021'}};
% conditionSets{end+1}={true 'theseSessions' 'trials'    {'NoRew', 'SI', [0 10], 'processed_WT65_11222021'}   {'NoRew', 'SI', [0 10], 'processed_WT65_11182021'}};
% conditionSets{end+1}={true 'all' 'means'     {'Rew', 'SI', [10 10]}   {'NoRew', 'SI', [10 10]}};
% conditionSets{end+1}={true 'all' 'means'     {'Rew', 'SI', [0 10]}   {'NoRew', 'SI', [0 10]}};
% conditionSets{end+1}={true 'all' 'means'     {'Rew', 'SI', [10 0]}   {'NoRew', 'SI', [10 0]}};
% conditionSets{end+1}={true 'all' 'trials'       {'Rew', 'SI', [10 10]}   {'NoRew', 'SI', [10 10]}};
% conditionSets{end+1}={true 'mouse' 'trials'     {'Rew', 'SI', [10 10]}   {'NoRew', 'SI', [10 10]}};
% conditionSets{end+1}={true 'all' 'trials'         {'w_Aa', 'SI', [10 10]}  {'w_aa', 'SI', [10 10]}};
% conditionSets{end+1}={true 'all' 'trials'         {'w_AA', 'SI', [10 20]}  {'w_aA', 'SI', [10 20]}};
% conditionSets{end+1}={true 'all' 'means'         {'w_Aa', 'SI', [10 10]}  {'w_aa', 'SI', [10 10]}};
% conditionSets{end+1}={true 'all' 'means'         {'w_AA', 'SI', [10 20]}  {'w_aA', 'SI', [10 20]}};
% conditionSets{end+1}={true 'mouse' 'trials'         {'w_Aa', 'SI', [10 10]}  {'w_aa', 'SI', [10 10]}};
% conditionSets{end+1}={true 'mouse' 'trials'         {'w_AA', 'SI', [10 20]}  {'w_aA', 'SI', [10 20]}};
conditionSets{end+1}={true 'all' 'trials'         {'w_Ab', 'SI', [10 0]}  {'w_ab', 'SI', [10 0]}};

channelList=[1 5 6];

%%
groupsToAnalyze=who('processed_WT*')';
testFraction=0.3;
trainFraction=1-testFraction;
randomShuffle=false;  % set to true for label shuffle control
nModels=100;


%% set up the tables
statsTable=table;
statsTable.mouseID=strings(0,1);
statsTable.condition=zeros(0,1);
statsTable.channel=zeros(0,1);
statsTable.analysisMode=strings(0,1);
statsTable.modelType=strings(0,1);
statsTable.randomShuffle=false(0,1);
statsTable.testFraction=zeros(0,1);
statsTable.trainFraction=zeros(0,1);

statsTable.LDA_nModels=zeros(0,1);
statsTable.LDA_trainPred=zeros(0,1);
statsTable.LDA_trainPred_sd=zeros(0,1);
statsTable.LDA_testPred=zeros(0,1);
statsTable.LDA_testPred_sd=zeros(0,1);
statsTable.LDA_hyp_trainPred=zeros(0,1);
statsTable.LDA_hyp_trainPred_sd=zeros(0,1);
statsTable.LDA_hyp_testPred=zeros(0,1);
statsTable.LDA_hyp_testPred_sd=zeros(0,1);

%%
maxConditions=0;
for sCounter=1:length(conditionSets)
    conditionDefs=conditionSets{sCounter};
    maxConditions=max(maxConditions, length(conditionDefs)-3);
end

%%
dummyFill={'' 0 0 '' '' false 0 0 0 0 0 0 0 0 0 0 0};

for sCounter=1:maxConditions
    statsTable.(['cond' num2str(sCounter)])=strings(0,1);
    statsTable.(['moment1_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['moment2_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['moment3_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['moment4_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['moment1_trainAvg_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['moment1_trainSD_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['moment2_trainAvg_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['moment2_trainSD_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['moment3_trainAvg_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['moment3_trainSD_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['moment4_trainAvg_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['moment4_trainSD_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['MSE_all_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['MSE_all_sd_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['MSE_test_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['MSE_test_sd_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['ME_all_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['ME_all_sd_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['ME_test_cond' num2str(sCounter)])=zeros(0,1);
    statsTable.(['ME_test_sd_cond' num2str(sCounter)])=zeros(0,1);
    dummyFill=[dummyFill {'' 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}];
end

%% loop through all the conditions to test
tableCounter=0;

for conditionCounter=1:length(conditionSets)
    conditionDefs=conditionSets{conditionCounter}(4:end);

    if conditionSets{conditionCounter}{1}==true % run this set
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
            for channel=channelList
%                disp([conditionCounter channel]
                disp(['Processing channel ' num2str(channel)]);
                for sessionCountner=1:length(sessionsToAnalyze)

                    if ~strcmp(groupBy, 'theseSessions')
                        assignin('base', 'processed', eval(sessionsToAnalyze{sessionCountner}));
                        disp(['   Loaded ' sessionsToAnalyze{sessionCountner}]);
                        params=processed.params;

                        % add trials since last switch and until next switch to the trial Table
                        nTrials=size(processed.trialTable, 1);
                    end

                    conditionStrings=cell(nConditions, 1);
                    for sCounter=1:nConditions
                        condDef=conditionDefs{sCounter};
                        alignment=condDef{2};
                        condition=condDef{1};
                        startPt=condDef{3}(1);
                        endPt=condDef{3}(2);

                        conditionStrings{sCounter}=['cond=' condition '; alignment=' alignment '; start='...
                            num2str(startPt) '; end=' num2str(endPt)];
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
                for sCounter=1:nConditions
                    newData=allData{sCounter};

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
                    % linear and z-score
                    dataSize=size(mergedAllData);
                    mergedAllData=reshape(mergedAllData, 1, numel(mergedAllData)); % linearize
                    mergedAllData=normalize(mergedAllData); % z-score
                    mergedAllData=reshape(mergedAllData, dataSize);

                    %% calcalate averages and stats for later
                    condAvgs=zeros(nConditions, nDataPoints);
                    condStds=zeros(nConditions, nDataPoints);

                    moments=zeros(nConditions, 4);
                    for sCounter=1:nConditions
                        sInds=find(mergedDataLabels==sCounter);
                        cData=mergedAllData(sInds, :);
                        condAvgs(sCounter, :)=mean(cData, 1);
                        condStds(sCounter, :)=std(cData, 0, 1);
                        linearCond=reshape(cData, 1, numel(cData));
                        moments(sCounter, 1)=mean(linearCond);
                        moments(sCounter, 2)=var(linearCond);
                        moments(sCounter, 3)=skewness(linearCond);
                        moments(sCounter, 4)=kurtosis(linearCond);
                    end


                    %% LDA analysis
                    minTrainSize=min(floor(trainFraction * labelCount));
                    minTestSize=min(floor(testFraction * labelCount));

                    trainSets=zeros(nConditions, minTrainSize);
                    testSets=zeros(nConditions, minTestSize);

                    trainPred=zeros(nModels, 1);
                    testPred=zeros(nModels, 1);
                    testPredHyp=zeros(nModels, 1);

                    testMSE_All=zeros(nConditions, nModels);
                    testMSE_Train=zeros(nConditions, nModels);
                    testME_All=zeros(nConditions, nModels);
                    testME_Train=zeros(nConditions, nModels);

                    trainMoments=zeros(nConditions, 4, nModels);
                    
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
                        statsTable.mouseID(tableCounter)=mouseID;
                        statsTable.analysisMode(tableCounter)=analysisMode;
                        statsTable.randomShuffle(tableCounter)=randomShuffle;
                        statsTable.testFraction(tableCounter)=testFraction;
                        statsTable.trainFraction(tableCounter)=trainFraction;
                        statsTable.channel(tableCounter)=channel;
                        statsTable.LDA_nModels(tableCounter)=nModels;

                        disp(' ')
                        disp(['Running models Channel ' num2str(channel) ' rand ' num2str(randCounter-1)])

                        if randomShuffle
                            disp('   with random shuffling');
                        end

                        for mCounter=1:nModels
                            close all
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
                                oldTestLabels=mergedTestLabels;
                                oldTrainLabels=mergedTrainLabels;
                                mergedTestLabels=mergedTestLabels(randperm(length(mergedTestLabels), length(mergedTestLabels)));
                                mergedTrainLabels=mergedTrainLabels(randperm(length(mergedTrainLabels), length(mergedTrainLabels)));
                                %      mergedTestData=mergedTestData...
                                %          (randperm(length(mergedTestLabels), length(mergedTestLabels)), :);
                                %     mergedTrainData=mergedTrainData...
                                %          (randperm(length(mergedTrainLabels), length(mergedTrainLabels)), :);
                            end

                            %% run LDA model
                            % with default - may overfit and reduce fit quality on test data
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
                            for sCounter=1:nConditions
                                if randomShuffle
                                    sIndices=find(oldTestLabels==sCounter);
                                else
                                    sIndices=find(mergedTestLabels==sCounter);
                                end
                                cTrainData=mergedTrainData(mergedTrainLabels==sCounter,:);
                                pAvg=mean(cTrainData, 1);
                                
                                testMSE_All(sCounter, mCounter)=...
                                    mean(mean((mergedTestData(sIndices,:)-condAvgs(sCounter, :)).^2, 2));
                                testMSE_Train(sCounter, mCounter)=...
                                    mean(mean((mergedTestData(sIndices,:)-pAvg).^2, 2));
                                
                                if sCounter==1
                                    other=2;
                                else
                                    other=1;
                                end

                                pAvg=mean(mergedTrainData(mergedTrainLabels==other,:), 1);
                                testME_All(sCounter, mCounter)=...
                                    mean(mean((mergedTestData(sIndices,:)-condAvgs(other, :)), 2));
                                testME_Train(sCounter, mCounter)=...
                                    mean(mean((mergedTestData(sIndices,:)-pAvg), 2));    

                                % moments
                                cTrainData=reshape(cTrainData, 1, numel(cTrainData));
                                trainMoments(sCounter, 1, mCounter)=mean(cTrainData);
                                trainMoments(sCounter, 2, mCounter)=var(cTrainData);
                                trainMoments(sCounter, 3, mCounter)=skewness(cTrainData);
                                trainMoments(sCounter, 4, mCounter)=kurtosis(cTrainData);
                            end
                        end

                        %   with hyper parameter sweep and cross-validation - better fits
                        Mdl = fitcdiscr(mergedTrainData,mergedTrainLabels, ...
                            'OptimizeHyperparameters', 'auto',...
                            'HyperparameterOptimizationOptions', ...
                            struct('ShowPlots', false, 'Verbose', 0, ...
                            'Repartition', true, ...
                            'AcquisitionFunctionName','expected-improvement-plus'));
                        close all
                        yy=predict(Mdl, mergedTestData);
                        testPredHyp=mean((mergedTestLabels==yy));
                        yy=predict(Mdl, mergedTrainData);
                        trainPredHyp=mean((mergedTrainLabels==yy));

                        statsTable.modelType(tableCounter)=modelType;   
                        statsTable.LDA_trainPred(tableCounter)=mean(trainPred);
                        statsTable.LDA_trainPred_sd(tableCounter)=std(trainPred);
                        disp(['OVERALL train set accuracy: ' ...
                            num2str(statsTable.LDA_trainPred(tableCounter))...
                            ' +/- ' num2str(statsTable.LDA_trainPred_sd(tableCounter)) ])

                        statsTable.LDA_testPred(tableCounter)=mean(testPred);
                        statsTable.LDA_testPred_sd(tableCounter)=std(testPred);
                        disp(['OVERALL test set accuracy: '  ...
                            num2str(statsTable.LDA_testPred(tableCounter))...
                            ' +/- ' num2str(statsTable.LDA_testPred_sd(tableCounter)) ])

                        disp(['OVERALL hyp test set accuracy: '  num2str(testPredHyp) ' train ' num2str(trainPredHyp)])
                        statsTable.LDA_hyp_trainPred(tableCounter)=trainPredHyp;
                        statsTable.LDA_hyp_testPred(tableCounter)=testPredHyp;

                        for sCounter=1:nConditions
                            statsTable.(['cond' num2str(sCounter)])(tableCounter)=conditionStrings{sCounter};

                            statsTable.(['moment1_cond' num2str(sCounter)])(tableCounter)=moments(sCounter, 1);
                            statsTable.(['moment2_cond' num2str(sCounter)])(tableCounter)=moments(sCounter, 2);
                            statsTable.(['moment3_cond' num2str(sCounter)])(tableCounter)=moments(sCounter, 3);
                            statsTable.(['moment4_cond' num2str(sCounter)])(tableCounter)=moments(sCounter, 4);                            

                            statsTable.(['MSE_all_cond' num2str(sCounter)])(tableCounter)=mean(testMSE_All(sCounter,:));
                            statsTable.(['MSE_all_sd_cond' num2str(sCounter)])(tableCounter)=std(testMSE_All(sCounter,:));
                            statsTable.(['MSE_test_cond' num2str(sCounter)])(tableCounter)=mean(testMSE_Train(sCounter, :));
                            statsTable.(['MSE_test_sd_cond' num2str(sCounter)])(tableCounter)=std(testMSE_Train(sCounter,:));

                            statsTable.(['ME_all_cond' num2str(sCounter)])(tableCounter)=mean(testME_All(sCounter,:));
                            statsTable.(['ME_all_sd_cond' num2str(sCounter)])(tableCounter)=std(testME_All(sCounter,:));
                            statsTable.(['ME_test_cond' num2str(sCounter)])(tableCounter)=mean(testME_Train(sCounter, :));
                            statsTable.(['ME_test_sd_cond' num2str(sCounter)])(tableCounter)=std(testME_Train(sCounter,:));
                            
                            disp(['OVERALL MSE Cond ' num2str(sCounter) ' : v All '  ...
                                num2str(mean(testMSE_Train(sCounter,:)))  ' +/- ' num2str(std(testMSE_Train(sCounter,:))) ])
                            disp(['OVERALL ME Cond ' num2str(sCounter) ' : v All '  ...
                                num2str(mean(testME_Train(sCounter,:)))  ' +/- ' num2str(std(testME_Train(sCounter,:))) ])                        

                            for momentCounter=1:4
                                statsTable.(['moment' num2str(momentCounter) '_trainAvg_cond' num2str(sCounter)])(tableCounter)=...
                                    mean(squeeze(trainMoments(sCounter, momentCounter, :)));
                                statsTable.(['moment' num2str(momentCounter) '_trainSD_cond' num2str(sCounter)])(tableCounter)=...
                                    std(squeeze(trainMoments(sCounter, momentCounter, :)));
                            end                        
                        end
                    end
                end
            end
        end
    end
end

save('statsTable.mat', 'statsTable')
