%% set things up
sessionsToAnalyze=who('processed_WT53*')';
useOldEvents=1;

alignmentCodeList={'CI', 'CO', 'SI', 'SO', 'FL'};
aligmentColumn={ ...
    'photometryCenterInIndex', ...
    'photometryCenterOutIndex', ...
    'photometrySideInIndex', ...
    'photometrySideOutIndex', ...
    'photometryFirstLickIndex' ...
    };

conditionsList={'RR', 'RNR', 'LR', 'LNR', 'R', 'L', 'Rew', 'NoRew', 'Hi', 'Low', 'Hi_NoRew', 'Low_NoRew', 'Hi_Rew', 'Low_Rew'};

for session=sessionsToAnalyze
    disp(['Processing ' session{1}]);

    assignin('base', 'processed', eval(session{1}));

    % fix errors in centerOutTimes
    errorTimes=find(processed.trialTable.photometryCenterOutIndex(1:(end-1))==processed.trialTable.photometryCenterOutIndex(2:end));
    errorTimes=intersect(errorTimes, find(processed.trialTable.hasAllPhotometryData));
    processed.trialTable.photometryCenterOutIndex(errorTimes)=processed.trialTable.photometryCenterInIndex(errorTimes);

    params=processed.params;
    totalPointsToKeep=params.ptsKeep_after+params.ptsKeep_before+1;

%     processed.signals{1}=processed.signals{5}-processed.signals{1};
%     processed.signals{2}=processed.signals{6}-processed.signals{2};
    
    useOldEvents=true;
    processConditions

 %   anaCrossCor
    assignin('base', session{1}, processed);    
end