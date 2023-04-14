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

channelToAnalyze=1;

swappedChannelMice={...  % Analyze channel 5 in these
    'WT8', 'WT9', 'WT10', 'WT11', 'WT21', 'WT22'
    };

saveName='Figure1_DA_Fig1_LR_Words_TestAll';

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



conditionSets={};


% Aa vs aa
%conditionSets{end+1}={'Aa/aa' 'all' 'trials'                {'w_Aa', 'SI', [0 norewN]}  {'w_aa', 'SI', [0 norewN]}};
conditionSets{end+1}={'Aa/aa' 'mouse' 'trials'              {'w_Aa', 'SI', [0 norewN]}  {'w_aa', 'SI', [0 norewN]}}; % done
%conditionSets{end+1}={'Aa/aa(Pre)' 'all' 'trials'           {'w_Aa', 'SI', [preN 0]}  {'w_aa', 'SI', [preN 0]}};
conditionSets{end+1}={'Aa/aa(Pre)' 'mouse' 'trials'         {'w_Aa', 'SI', [preN 0]}  {'w_aa', 'SI', [preN 0]}}; % done

% Ab vs ab
%conditionSets{end+1}={'Ab/ab' 'all' 'trials'                {'w_Ab', 'SI', [0 norewN]}  {'w_ab', 'SI', [0 norewN]}};
conditionSets{end+1}={'Ab/ab' 'mouse' 'trials'              {'w_Ab', 'SI', [0 norewN]}  {'w_ab', 'SI', [0 norewN]}}; % done
%conditionSets{end+1}={'Ab/ab(Pre)' 'all' 'trials'           {'w_Ab', 'SI', [preN 0]}  {'w_ab', 'SI', [preN 0]}};
conditionSets{end+1}={'Ab/ab(Pre)' 'mouse' 'trials'         {'w_Ab', 'SI', [preN 0]}  {'w_ab', 'SI', [preN 0]}}; % done

% AA vs aA
%conditionSets{end+1}={'AA/aA' 'all' 'trials'                {'w_AA', 'SI', [0 rewN]}  {'w_aA', 'SI', [0 rewN]}};
conditionSets{end+1}={'AA/aA' 'mouse' 'trials'              {'w_AA', 'SI', [0 rewN]}  {'w_aA', 'SI', [0 rewN]}}; % done
%conditionSets{end+1}={'AA/aA(Pre)' 'all' 'trials'           {'w_AA', 'SI', [preN 0]}  {'w_aA', 'SI', [preN 0]}};
conditionSets{end+1}={'AA/aA(Pre)' 'mouse' 'trials'         {'w_AA', 'SI', [preN 0]}  {'w_aA', 'SI', [preN 0]}}; % done

% AB vs aB
%conditionSets{end+1}={'AA/aB' 'all' 'trials'                {'w_AB', 'SI', [0 rewN]}  {'w_aB', 'SI', [0 rewN]}};
conditionSets{end+1}={'AB/aB' 'mouse' 'trials'              {'w_AB', 'SI', [0 rewN]}  {'w_aB', 'SI', [0 rewN]}}; % done
%conditionSets{end+1}={'AA/aB(Pre)' 'all' 'trials'           {'w_AB', 'SI', [preN 0]}  {'w_aB', 'SI', [preN 0]}};
conditionSets{end+1}={'AB/aB(Pre)' 'mouse' 'trials'         {'w_AB', 'SI', [preN 0]}  {'w_aB', 'SI', [preN 0]}}; % done

processStats_core

