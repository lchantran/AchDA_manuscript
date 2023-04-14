%% Setup analysis
testFraction=0.3;
trainFraction=1-testFraction;

nModels=10;
alphaForTTest=0.05;
rerunOldAnalysisSet=true;

randomShuffle=false;  % set to true for label shuffle control
zScoreAllData=false; % normalize the data acorss all sessions before doing analysis.  Doesn't seem to affect LDA/SVM performance at all so leave it off to have summary statistics in natural units

runSVMhyp=false;
runLDAhyp=false;

channelToAnalyze=[1 5];

saveName='Figure1_Fig1_LED_Rerun';

startDrop=-1;
rewN=18;
norewN=18;

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
conditionSets{end+1}={'NoLed/LED Rew' 'theseSessions' 'trials'    {'Rew', 'SI', [startDrop rewN], 'processed_WT62_11222021'}   {'Rew', 'SI', [startDrop rewN], 'processed_WT62_11082021'}};
conditionSets{end+1}={'NoLed/LED Rew' 'theseSessions' 'trials'    {'Rew', 'SI', [startDrop rewN], 'processed_WT63_11222021'}   {'Rew', 'SI', [startDrop rewN], 'processed_WT63_11102021'}};
conditionSets{end+1}={'NoLed/LED Rew' 'theseSessions' 'trials'    {'Rew', 'SI', [startDrop rewN], 'processed_WT64_11222021'}   {'Rew', 'SI', [startDrop rewN], 'processed_WT64_11082021'}};
conditionSets{end+1}={'NoLed/LED Rew' 'theseSessions' 'trials'    {'Rew', 'SI', [startDrop rewN], 'processed_WT65_11222021'}   {'Rew', 'SI', [startDrop rewN], 'processed_WT65_11082021'}};
conditionSets{end+1}={'NoLed/LED NoRew' 'theseSessions' 'trials'    {'NoRew', 'SI', [startDrop norewN], 'processed_WT62_11222021'}   {'NoRew', 'SI', [startDrop norewN], 'processed_WT62_11082021'}};
conditionSets{end+1}={'NoLed/LED NoRew' 'theseSessions' 'trials'    {'NoRew', 'SI', [startDrop norewN], 'processed_WT63_11222021'}   {'NoRew', 'SI', [startDrop norewN], 'processed_WT63_11102021'}};
conditionSets{end+1}={'NoLed/LED NoRew' 'theseSessions' 'trials'    {'NoRew', 'SI', [startDrop norewN], 'processed_WT64_11222021'}   {'NoRew', 'SI', [startDrop norewN], 'processed_WT64_11082021'}};
conditionSets{end+1}={'NoLed/LED NoRew' 'theseSessions' 'trials'    {'NoRew', 'SI', [startDrop norewN], 'processed_WT65_11222021'}   {'NoRew', 'SI', [startDrop norewN], 'processed_WT65_11082021'}};

conditionSets{end+1}={'NoLed/LED Rew' 'theseSessions' 'trials'    {'Rew', 'SI', [startDrop rewN], 'processed_WT58_10042021'}   {'Rew', 'SI', [startDrop rewN], 'processed_WT58_10182021'}};
conditionSets{end+1}={'NoLed/LED Rew' 'theseSessions' 'trials'    {'Rew', 'SI', [startDrop rewN], 'processed_WT59_10042021'}   {'Rew', 'SI', [startDrop rewN], 'processed_WT59_10182021'}};
conditionSets{end+1}={'NoLed/LED Rew' 'theseSessions' 'trials'    {'Rew', 'SI', [startDrop rewN], 'processed_WT60_10042021'}   {'Rew', 'SI', [startDrop rewN], 'processed_WT60_10182021'}};
conditionSets{end+1}={'NoLed/LED Rew' 'theseSessions' 'trials'    {'Rew', 'SI', [startDrop rewN], 'processed_WT61_10042021'}   {'Rew', 'SI', [startDrop rewN], 'processed_WT61_10182021'}};
conditionSets{end+1}={'NoLed/LED NoRew' 'theseSessions' 'trials'    {'NoRew', 'SI', [startDrop noRewN], 'processed_WT58_10042021'}   {'NoRew', 'SI', [startDrop noRewN], 'processed_WT58_10182021'}};
conditionSets{end+1}={'NoLed/LED NoRew' 'theseSessions' 'trials'    {'NoRew', 'SI', [startDrop noRewN], 'processed_WT59_10042021'}   {'NoRew', 'SI', [startDrop noRewN], 'processed_WT59_10182021'}};
conditionSets{end+1}={'NoLed/LED NoRew' 'theseSessions' 'trials'    {'NoRew', 'SI', [startDrop noRewN], 'processed_WT60_10042021'}   {'NoRew', 'SI', [startDrop noRewN], 'processed_WT60_10182021'}};
conditionSets{end+1}={'NoLed/LED NoRew' 'theseSessions' 'trials'    {'NoRew', 'SI', [startDrop noRewN], 'processed_WT61_10042021'}   {'NoRew', 'SI', [startDrop noRewN], 'processed_WT61_10182021'}};


%%
processStats_SIMPLE

