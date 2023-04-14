%% Setup analysis
testFraction=0.3;
trainFraction=1-testFraction;

nModels=100;
alphaForTTest=0.05;
rerunOldAnalysisSet=false;

randomShuffle=false;  % set to true for label shuffle control
zScoreAllData=false; % normalize the data acorss all sessions before doing analysis.  Doesn't seem to affect LDA/SVM performance at all so leave it off to have summary statistics in natural units

runSVMhyp=false;
runLDAhyp=false;

channelsToAnalyze=[1 5];

swappedChannelMice={};

saveName='Figure1_Ach_Fig1_2Side_LR';

startDrop=1;
preN=10;
rewN=10;
norewN=10;

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

startDrop=1;
preN=10;
rewN=10;
norewN=10;

conditionSets={};

% % %R vs L no reward
conditionSets{end+1}={'r/l' 'mouse' 'trials'                {'RNR', 'SI', [startDrop norewN]}   {'LNR', 'SI', [startDrop norewN]}};
%conditionSets{end+1}={'r/l(Pre)' 'mouse' 'trials'           {'RNR', 'SI', [preN startDrop]}   {'LNR', 'SI', [preN startDrop]}};

% R vs L reward
conditionSets{end+1}={'R/L' 'mouse' 'trials'                {'RR', 'SI', [startDrop rewN]}   {'LR', 'SI', [startDrop rewN]}};
%conditionSets{end+1}={'R/L(Pre)' 'mouse' 'trials'           {'RR', 'SI', [preN startDrop]}   {'LR', 'SI', [preN startDrop]}};

% are reward and no reward different before and after the SI
conditionSets{end+1}={'Rew/NoRew' 'mouse' 'trials'          {'Rew', 'SI', [startDrop norewN]}   {'NoRew', 'SI', [startDrop norewN]}}; % done
%conditionSets{end+1}={'Rew/NoRew(Pre)' 'mouse' 'trials'     {'Rew', 'SI', [preN startDrop]}   {'NoRew', 'SI', [preN startDrop]}}; % done

% % are reward and no reward different before and after the SI
% conditionSets{end+1}={'aA/AA' 'mouse' 'trials'              {'Aa', 'SI', [startDrop norewN]}   {'AA', 'SI', [startDrop norewN]}}; % done
% conditionSets{end+1}={'aa/Aa' 'mouse' 'trials'              {'aa', 'SI', [startDrop norewN]}   {'Aa', 'SI', [startDrop norewN]}}; % done

%%
processStats_SIMPLE

