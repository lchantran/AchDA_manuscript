%% Setup analysis
testFraction=0.3;
trainFraction=1-testFraction;

nModels=100;
alphaForTTest=0.05;
rerunOldAnalysisSet=false;
keepAllValues=true;

randomShuffle=false;  % set to true for label shuffle control
zScoreAllData=false; % normalize the data acorss all sessions before doing analysis.  Doesn't seem to affect LDA/SVM performance at all so leave it off to have summary statistics in natural units

runSVMhyp=false;
runLDAhyp=true;

channelsToAnalyze=[5 6];

swappedChannelMice={'WT60', 'WT61', 'WT68'}; % Use channel 1 in these mice
saveName='Figure_Dual_Celia';



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
dPoints=15;

conditionSets={};

% are reward and no reward different before and after the SI
conditionSets{end+1}={'Rew/NoRew' 'mouse' 'trials'          {'Rew', 'SI', [startDrop dPoints]}   {'NoRew', 'SI', [startDrop dPoints]}}; % done

% are post SI outcome signals different depending on history
conditionSets{end+1}={'aA/AA' 'mouse' 'trials'              {'w_aA', 'SI', [startDrop dPoints]}   {'w_AA', 'SI', [startDrop dPoints]}}; % done
conditionSets{end+1}={'aa/Aa' 'mouse' 'trials'              {'w_aa', 'SI', [startDrop dPoints]}   {'w_Aa', 'SI', [startDrop dPoints]}}; % done
conditionSets{end+1}={'aB/AB' 'mouse' 'trials'              {'w_aB', 'SI', [startDrop dPoints]}   {'w_AB', 'SI', [startDrop dPoints]}}; % done
conditionSets{end+1}={'ab/Ab' 'mouse' 'trials'              {'w_ab', 'SI', [startDrop dPoints]}   {'w_Ab', 'SI', [startDrop dPoints]}}; % done

% are pre SI signals different 
conditionSets{end+1}={'(pre switch)FRew/FNoRew' 'mouse' 'trials'            {'FRewSw', 'SI', [dPoints startDrop]}   {'FNoRewSw', 'SI', [dPoints startDrop]}}; % done
conditionSets{end+1}={'(pre FNoRew)Sw/NoSw' 'mouse' 'trials'                {'FNoRewSw', 'SI', [dPoints startDrop]}   {'FNoRewNoSw', 'SI', [dPoints startDrop]}}; % done
conditionSets{end+1}={'(pre FRew)Sw/NoSw' 'mouse' 'trials'                  {'FRewSw', 'SI', [dPoints startDrop]}   {'FRewNoSw', 'SI', [dPoints startDrop]}}; % done

% are post CI signals different 
conditionSets{end+1}={'(post CI switch)FRew/FNoRew' 'mouse' 'trials'            {'FRewSw', 'CI', [startDrop dPoints]}   {'FNoRewSw', 'CI', [startDrop dPoints]}}; % done
conditionSets{end+1}={'(post CI FNoRew)Sw/NoSw' 'mouse' 'trials'                {'FNoRewSw', 'CI', [startDrop dPoints]}   {'FNoRewNoSw', 'CI', [startDrop dPoints]}}; % done
conditionSets{end+1}={'(post CI FRew)Sw/NoSw' 'mouse' 'trials'                  {'FRewSw', 'CI', [startDrop dPoints]}   {'FRewNoSw', 'CI', [startDrop dPoints]}}; % done

% are post SO signals different by switch?
conditionSets{end+1}={'(post SO Rew)Sw/NoSw' 'mouse' 'trials'            {'w_A_Sw', 'CI', [startDrop dPoints]}   {'w_A_NoSw', 'CI', [startDrop dPoints]}}; % done
conditionSets{end+1}={'(post SO NoRew)Sw/NoSw' 'mouse' 'trials'            {'w_a_Sw', 'CI', [startDrop dPoints]}   {'w_a_NoSw', 'CI', [startDrop dPoints]}}; % done

%%
processStats_SIMPLE

