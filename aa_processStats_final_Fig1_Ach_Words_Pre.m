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

channelsToAnalyze=[5];

swappedChannelMice={'WT60', 'WT61', 'WT68'}; % Use channel 1 in these mice
saveName='Figure1_Ach_Words_Pre';

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

startDrop=0;
preN=18;
rewN=18;
norewN=18;

conditionSets={};


% % are reward and no reward different before and after the SI
conditionSets{end+1}={'(pre)aA/AA' 'mouse' 'trials'              {'w_aA', 'SI', [preN startDrop]}   {'w_AA', 'SI', [preN startDrop]}}; % done
conditionSets{end+1}={'(pre)aa/Aa' 'mouse' 'trials'              {'w_aa', 'SI', [preN startDrop]}   {'w_Aa', 'SI', [preN startDrop]}}; % done

% switch per
conditionSets{end+1}={'(pre)aB/AB' 'mouse' 'trials'              {'w_aB', 'SI', [preN startDrop]}   {'w_AB', 'SI', [preN startDrop]}}; % done
conditionSets{end+1}={'(pre)ab/Ab' 'mouse' 'trials'              {'w_ab', 'SI', [preN startDrop]}   {'w_Ab', 'SI', [preN startDrop]}}; % done

%%
processStats_SIMPLE

