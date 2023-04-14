
% Set the conditions and alignments to calculate and store
conditionsList={'fast', 'med', 'slow'};

alignmentCodeList={'CI', 'CO', 'SI', 'SO', 'FL'};
aligmentColumn={ ...
    'photometryCenterInIndex', ...
    'photometryCenterOutIndex', ...
    'photometrySideInIndex', ...
    'photometrySideOutIndex', ...
    'photometryFirstLickIndex' ...
    };

sessionsToAnalyze=who('processed_WT*')'; %{'processed_WT68_12192021'};

for session=sessionsToAnalyze
    disp(['Processing ' session{1}]);

    assignin('base', 'processed', eval(session{1}));

    % fix errors in centerOutTimes
    errorTimes=find(processed.trialTable.photometryCenterOutIndex(1:(end-1))==processed.trialTable.photometryCenterOutIndex(2:end));
    errorTimes=intersect(errorTimes, find(processed.trialTable.hasAllPhotometryData));
    processed.trialTable.photometryCenterOutIndex(errorTimes)=processed.trialTable.photometryCenterInIndex(errorTimes);

    
    params=processed.params;
    params.ptsKeep_before=200;
    params.ptsKeep_after=100;
    
    imTimes=params.finalTimeStep*(-params.ptsKeep_before:params.ptsKeep_after);
    totalPointsToKeep=params.ptsKeep_before+params.ptsKeep_after+1;
    
    minPtsOffset=params.signalDetrendWindow/2;
    finalSamples=max(params.finalSamples);
    
    hasP=find(...
        processed.trialTable.isPhotometryTrial ...
        & (processed.trialTable.photometryCenterInIndex>(params.ptsKeep_before+minPtsOffset)) ...
        & (processed.trialTable.photometrySideOutIndex<(finalSamples-params.ptsKeep_after))...
        );
    
    RR=find(processed.trialTable.choseRight(1:end-1)==1 & processed.trialTable.choseRight(2:end)==1);
    LL=find(processed.trialTable.choseLeft(1:end-1)==1 & processed.trialTable.choseLeft(2:end)==1);
    AA=union(RR,LL);
    
    RL=find(processed.trialTable.choseRight(1:end-1)==1 & processed.trialTable.choseLeft(2:end)==1);
    LR=find(processed.trialTable.choseLeft(1:end-1)==1 & processed.trialTable.choseRight(2:end)==1);
    AB=union(RL,LR);

    Rew=find(processed.trialTable.wasRewarded==1);
    NoRew=find(processed.trialTable.wasRewarded~=1);
    
    NextRew=find(processed.trialTable.wasRewarded(2:end)==1);
    NextNoRew=find(processed.trialTable.wasRewarded(2:end)~=1);
    
    Rew_Rew=intersect(intersect(intersect(AA, Rew), NextRew)+1, hasP);
    Rew_NoRew=intersect(intersect(intersect(AA, Rew), NextNoRew)+1, hasP);
    NoRew_Rew=intersect(intersect(intersect(AA, NoRew), NextRew)+1, hasP);
    NoRew_NoRew=intersect(intersect(intersect(AA, NoRew), NextNoRew)+1, hasP);

    Sw_Rew_Rew=intersect(intersect(intersect(AB, Rew), NextRew)+1, hasP);
    Sw_Rew_NoRew=intersect(intersect(intersect(AB, Rew), NextNoRew)+1, hasP);
    Sw_NoRew_Rew=intersect(intersect(intersect(AB, NoRew), NextRew)+1, hasP);
    Sw_NoRew_NoRew=intersect(intersect(intersect(AB, NoRew), NextNoRew)+1, hasP);

    Rew_Rew_first=intersect(intersect(intersect(AA, Rew), NextRew), hasP);
    Rew_NoRew_first=intersect(intersect(intersect(AA, Rew), NextNoRew), hasP);
    NoRew_Rew_first=intersect(intersect(intersect(AA, NoRew), NextRew), hasP);
    NoRew_NoRew_first=intersect(intersect(intersect(AA, NoRew), NextNoRew), hasP);

    Sw_Rew_Rew_first=intersect(intersect(intersect(AB, Rew), NextRew), hasP);
    Sw_Rew_NoRew_first=intersect(intersect(intersect(AB, Rew), NextNoRew), hasP);
    Sw_NoRew_Rew_first=intersect(intersect(intersect(AB, NoRew), NextRew), hasP);
    Sw_NoRew_NoRew_first=intersect(intersect(intersect(AB, NoRew), NextNoRew), hasP);

    Rew_Sw_first=intersect(intersect(AB, Rew), hasP);
    Rew_NoSw_first=intersect(intersect(AA, Rew), hasP);
    NoRew_Sw_first=intersect(intersect(AB, NoRew), hasP);
    NoRew_NoSw_first=intersect(intersect(AA, NoRew), hasP);

    processConditions;
    assignin('base', session{1}, processed);
    pGraph(processed.ph.CI, {'Rew_Rew', 'NoRew_Rew'}, 5);
    title(removeDash(session{1}))
    drawnow
end




