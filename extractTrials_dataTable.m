function trialTable = extractTrials_dataTable(stats, pokeHistory, firstKeepTrial, lastKeepTrial)

if nargin<4
    firstKeepTrial=1;
    lastKeepTrial=length(pokeHistory);
end

%% get basic trial counts and poke times
% create a vector 'timePoked' where each entry represents a poke, and the
% value is the number of seconds since the first poke. This is also
% calculated in pokeAnalysis_v1, but I wanted to add it here so this can
% stand as an independent function. 

timePoked = zeros(1,length(pokeHistory));
firstPoke = datevec(pokeHistory(firstKeepTrial).timeStamp);
for i = 1:length(pokeHistory)
    timePoked(i) = etime(datevec(pokeHistory(i).timeStamp), firstPoke);
end

isLeftTrial=stats.trials.left == 2;
isRightTrial=stats.trials.right == 2;

leftTrials=find(isLeftTrial);
rightTrials=find(isRightTrial);

numLeftTrials = length(leftTrials);
numRightTrials = length(rightTrials);
numTrials = numLeftTrials + numRightTrials;

trialTable=table; % make table


if numTrials==0
    disp('      extractTrials: Error - no side port trials found');
    trials=[];
    return
end

%% initialize table
trialTable.centerInPokeIndex=zeros(numTrials,1);
trialTable.centerInTime=zeros(numTrials,1);
trialTable.sideInPokeIndex=zeros(numTrials,1);
trialTable.sideInTime=zeros(numTrials,1);
trialTable.choseLeft=false(numTrials,1);
trialTable.choseRight=false(numTrials,1);
trialTable.wasRewarded=false(numTrials,1);

trialTable.leftRewardProb=zeros(numTrials,1);
trialTable.rightRewardProb=zeros(numTrials,1);
trialTable.sideLaser=false(numTrials,1);
trialTable.centerLaser=false(numTrials,1);
trialTable.isPhotometryTrial=false(numTrials,1);

%% determine which actual pokes were trials
[decisionPokes, sortOrder] = sort([leftTrials rightTrials], 'ascend');

trialTable.sideInPokeIndex=decisionPokes';
trialTable.sideInTime = timePoked(trialTable.sideInPokeIndex)';

trialTable.centerInPokeIndex=trialTable.sideInPokeIndex-1;
trialTable.centerInTime = timePoked(trialTable.centerInPokeIndex)';

dummy=[ones(1, numLeftTrials) zeros(1, numRightTrials)];
trialTable.choseLeft=(dummy(sortOrder)==1)';
trialTable.choseRight=(dummy(sortOrder)==0)';

keepTrials=...
    (trialTable.sideInPokeIndex>=firstKeepTrial) ...
    & (trialTable.centerInPokeIndex<=lastKeepTrial);
trialTable.isPhotometryTrial(keepTrials)=true;

%% create trials matrix

%all trials
for i = 1:numTrials
    trialTable.leftRewardProb(i) = pokeHistory(trialTable.sideInPokeIndex(i)).leftPortStats.prob;
    trialTable.rightRewardProb(i) = pokeHistory(trialTable.sideInPokeIndex(i)).rightPortStats.prob;
    trialTable.wasRewarded(i) = (pokeHistory(trialTable.sideInPokeIndex(i)).REWARD==1);
    if isfield(pokeHistory, 'Laser')
        trialTable.laser(i) = sum(pokeHistory(trialTable.sideInPokeIndex(i)).laser);
    end        
end

% the Center laser stim:
disp('extractTrials_opto commented out center laser trial')
% for j = 1:length(pokeHistory)
%     if pokeHistory(j).isTRIAL == 2;
%         Claser_stim(index) = sum(pokeHistory(j).laser);
%         index = index + 1;
%     end
%     
% end
% trials(:,9) = Claser_stim;

