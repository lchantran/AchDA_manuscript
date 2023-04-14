% assumes statsTable and statsTable are loaded
%% plot dprime and stats

% statsPlotColumns={...
%     'moment1_train_cond1_avg', 'moment2_train_cond1_avg', 'moment1_train_cond2_avg', 'moment2_train_cond2_avg', ...
%     'moment1_p_avg', 'moment2_p_avg', ...
%     'LDA_testPred_avg', 'LDA_hyp_testPred'...
%     };
% statsLabels={'mean 1', 'var 1',  'mean 2', 'var 2', 'mean dp', 'var dp', 'LDA', 'LDA hyp'};
% statsPlotColumns={...
%     'moment1_train_cond1_avg', ...
%     'moment1_train_cond2_avg', ...
%     'moment1_dp_avg',...
%     'moment1_mean_dp_avg', ...
%     'LDA_hyp_testPred'...
%     };
% statsLabels={'mean 1',  'mean 2', 'mean dp', 'pop mean dp', 'LDA hyp'};

statsPlotColumns={'mean_cond1_avg', 'mean_cond2_avg'};
statsLabels={'mean1', 'mean2'};

statsHasSd=[true, true];

miceToPlot={};
conditionsToPlot=[1:1:max(statsTable.condition)]; %3; %[1:2:max(statsTable.condition)];; [1:6]; 7:16 ; 1:6; [1 2 9 10]; [7:14]; [2:2:size(statsTable,2)];
plotALL=false;

% statsTable.moment1_mean_dp_avg=dPrime(statsTable.moment1_train_cond1_avg, statsTable.moment1_train_cond2_avg, statsTable.moment1_train_cond1_sd, statsTable.moment1_train_cond2_sd);
% statsTable.moment1_mean_dp_sd=0*dPrime(statsTable.moment1_train_cond1_avg, statsTable.moment1_train_cond2_avg, statsTable.moment1_train_cond1_sd, statsTable.moment1_train_cond2_sd);

plotOnOneGraph=true;
channelsToPlot=[1 5];
useVirusNames=true;
plotOnlyThese={'dLight', 'Grab-Ach', 'rGrab-DA', 'jrCamp1b'};
saveFigures=false;
saveFigurePath=fullfile('.', 'statsFigures');
spreadFactor=1.2;

allChanLabels={'dLight', '', '', '', 'Grab-Ach', 'rGrab-DA'};

maxVal=Inf; % put a cap on the value to keep the y-scale the same

%%
pGraphStatsSummmary_core
