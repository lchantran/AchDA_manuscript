%% Setup analysis
testFraction=0.3;
trainFraction=1-testFraction;

nModels=100;
alphaForTTest=0.05;
rerunOldAnalysisSet=true;

randomShuffle=false;  % set to true for label shuffle control
zScoreAllData=false; % normalize the data acorss all sessions before doing analysis.  Doesn't seem to affect LDA/SVM performance at all so leave it off to have summary statistics in natural units

runSVMhyp=false;
runLDAhyp=true;

channelsToAnalyze=[5 6];

swappedChannelMice={'WT60', 'WT61', 'WT68'}; % Use channel 6 in these mice
saveName='Figure1_Ach_DA_cKO_ALL';

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

startDrop=-1;
preN=18;
rewN=18;
norewN=18;

conditionSets={};

% are reward and no reward different before and after the SI
conditionSets{end+1}={'Rew/NoRew' 'mouse' 'trials'          {'Rew', 'SI', [-1 18]}   {'NoRew', 'SI', [-1 18]}}; % done
conditionSets{end+1}={'Rew/NoRew(2)' 'mouse' 'trials'          {'Rew', 'SI', [-9 16]}   {'NoRew', 'SI', [-9 16]}}; % done
conditionSets{end+1}={'Rew/NoRew(Pre)' 'mouse' 'trials'     {'All', 'SI', [18 -1]}   {'All', 'SI', [18 -1]}}; % done
conditionSets{end+1}={'Rew/NoRew(Pre2)' 'mouse' 'trials'     {'All', 'SI', [18 -9]}   {'All', 'SI', [18 -9]}}; % done
% 
% % % are reward and no reward different before and after the SI
% conditionSets{end+1}={'aA/AA' 'mouse' 'trials'              {'w_aA', 'SI', [startDrop norewN]}   {'w_AA', 'SI', [startDrop norewN]}}; % done
% conditionSets{end+1}={'aa/Aa' 'mouse' 'trials'              {'w_aa', 'SI', [startDrop norewN]}   {'w_Aa', 'SI', [startDrop norewN]}}; % done
% 
% % % are reward and no reward different before and after the SI
% % conditionSets{end+1}={'(pre)aA/AA' 'mouse' 'trials'              {'w_aA', 'SI', [preN startDrop]}   {'w_AA', 'SI', [preN startDrop]}}; % done
% % conditionSets{end+1}={'(pre)aa/Aa' 'mouse' 'trials'              {'w_aa', 'SI', [preN startDrop]}   {'w_Aa', 'SI', [preN startDrop]}}; % done
% 
% % switch trials
% conditionSets{end+1}={'aB/AB' 'mouse' 'trials'              {'w_aB', 'SI', [startDrop norewN]}   {'w_AB', 'SI', [startDrop norewN]}}; % done
% conditionSets{end+1}={'ab/Ab' 'mouse' 'trials'              {'w_ab', 'SI', [startDrop norewN]}   {'w_Ab', 'SI', [startDrop norewN]}}; % done

%%
processStats_SIMPLE

