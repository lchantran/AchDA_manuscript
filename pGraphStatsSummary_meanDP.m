% assumes statsTable and statsTable are loaded
%% plot dprime and stats

% statsPlotColumns={...
%     'moment1_train_cond1_avg', 'moment2_train_cond1_avg', 'moment1_train_cond2_avg', 'moment2_train_cond2_avg', ...
%     'LDA_testPred_avg', 'LDA_hyp_testPred'...
%     };
% statsLabels={'mean 1', 'var 1',  'mean 2', 'var 2', 'LDA', 'LDA hyp'};
% statsHasSd=[true, true, true, true, ...
%     true, false];

statsPlotColumns={...
    'moment1_mean_dp_avg', 'moment1_dp_avg' 'max_cond1_avg', 'max_cond2_avg', 'min_cond1_avg', 'min_cond2_avg'};%, 'MSE_train_cond1_dp', 'MSE_train_cond2_dp'};

statsLabels={'pop mean dp', 'trial mean dp', 'max cond1', 'max cond2', 'min cond1', 'min  cond2'};
statsHasSd=[false, true, true, true, true, true];

miceToPlot={};
conditionsToPlot=[1:1:max(statsTable.condition)];; [1:6]; 7:16 ; 1:6; [1 2 9 10]; [7:14]; [2:2:size(statsTable,2)];
plotALL=false;

statsTable.moment1_mean_dp_avg=dPrime(statsTable.moment1_train_cond1_avg, statsTable.moment1_train_cond2_avg, statsTable.moment1_train_cond1_sd, statsTable.moment1_train_cond2_sd);
statsTable.moment1_mean_dp_sd=0*dPrime(statsTable.moment1_train_cond1_avg, statsTable.moment1_train_cond2_avg, statsTable.moment1_train_cond1_sd, statsTable.moment1_train_cond2_sd);

plotOnOneGraph=true;
channelsToPlot=1;
useVirusNames=true;
plotOnlyThese={'dLight', 'Grab-Ach', 'rGrab-DA', 'jrCamp1b'};
saveFigures=false;
saveFigurePath=fullfile('.', 'statsFigures');
spreadFactor=1.2;

allChanLabels={'dLight', '', '', '', 'Grab-Ach', 'rGrab-DA'};

maxVal=30; % put a cap on the value to keep the y-scale the same

%%
pGraphStatsSummmary_core
