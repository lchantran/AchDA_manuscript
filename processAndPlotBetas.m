%% make beta coefficient plots

% First use readtable to read in the data from a csv file from josh.

dataFolder=['/Users/lynnechantranupong/Dropbox (HMS)/2ABT_data_bernardo/test/_new_from_BS/betas/Local-Tetanus-Outputs'];
cd(dataFolder)

table1=readtable('Figure_7_g1--20_20sft-kernels-gDAc=1_base_words_max_iter10000__fit_interceptFalse__alpha0____0__l1_ratio0____0.csv');
dt=0.054;

pointsPerGraph=height(table1);
pointRange=0:(pointsPerGraph-1);
midPoint=(pointsPerGraph-1)/2;
offsetBetweenGraphs=2;

keepColNames={};
allColNames=fieldnames(table1);
isMean=find(contains(allColNames, '_mean'));

%% make the figure 
figure; 
hold on; 

%% horizontal zero line
plot([0 dt*(length(isMean)*(offsetBetweenGraphs+pointsPerGraph))], [0 0], 'k--')


%% find vertical range

minMin=-1;
maxMax=1;

for counter=1:length(isMean)
    colNumber=isMean(counter);
    disp(allColNames{colNumber})
    midLine=table1.(allColNames{colNumber});
    semLine=table1.(allColNames{colNumber+1}); % assume that the sem comes after the mean
    stdLine=table1.(allColNames{colNumber+3}); % assume that the str comes 3 after the mean

    lowLine=midLine-stdLine;
    hiLine=midLine+stdLine;

    minMin=min(minMin, min(lowLine));
    maxMax=max(maxMax, max(hiLine));
end

%% set vertical range
maxDev=max(maxMax, abs(minMin)); % multiply by 1.1 if you want padding
set(gca, 'YLim', [-maxDev maxDev]) % symmetric and 

% set(gca, 'YLim', [-minMin maxMax]) % if you want it tighter and not symetric


%% add the vertical dashed lines at zero
for counter=1:length(isMean)
    midmid= dt*(midPoint+(counter-1)*(offsetBetweenGraphs+pointsPerGraph));

    plot([midmid midmid], [-maxDev maxDev], 'k--')

end

%% shaded areas and mid lines

plottingOrder=1:length(isMean); % if you want a different order, set it here
% plottingOrder=[2 3 1 7 3]
% e.g. plottingOrder=[2 3 1 7 3...]
% e.g. plottingOrder=flip(plottingOrder);
% plottingOrder=[12];

for counter=1:length(plottingOrder)
    colNumber=isMean(plottingOrder(counter));
    disp(allColNames{colNumber})
    midLine=table1.(allColNames{colNumber});
    semLine=table1.(allColNames{colNumber+1}); % assume that the sem comes after the mean
    stdLine=table1.(allColNames{colNumber+3}); % assume that the str comes 3 after the mean

    lowLine=midLine-stdLine; % can change to something difference if you want a broader range.  Like 2*std
    hiLine=midLine+stdLine;

    % puts the shading
    fillBetween(lowLine, hiLine, tRange=[(counter-1)*(pointsPerGraph+offsetBetweenGraphs)-1 dt], colorName='g');
    % puts the line
    plot(dt*((counter-1)*(pointsPerGraph+offsetBetweenGraphs)+pointRange), midLine, 'color', 'g', 'LineWidth', 1)
end


%% axes
axis tight
axis on
% ylim([-0.2 0.05])
set(gca, 'Position', [0.02 0.05 0.95 0.90])

hold on

%% repeat

dataFolder=['/Users/lynnechantranupong/Dropbox (HMS)/2ABT_data_bernardo/test/_new_from_BS/betas/Local-Tetanus-Outputs'];
cd(dataFolder)

table1=readtable('Figure_7_g1--20_20sft-kernels-gDAt=1_base_words_max_iter10000__fit_interceptFalse__alpha0____0__l1_ratio0____0.csv');
dt=0.054;

pointsPerGraph=height(table1);
pointRange=0:(pointsPerGraph-1);
midPoint=(pointsPerGraph-1)/2;
offsetBetweenGraphs=2;

keepColNames={};
allColNames=fieldnames(table1);
isMean=find(contains(allColNames, '_mean'));

%% make the figure 
% figure; 
% hold on; 

%% horizontal zero line
plot([0 dt*(length(isMean)*(offsetBetweenGraphs+pointsPerGraph))], [0 0], 'k--')


%% find vertical range

minMin=-1;
maxMax=1;

for counter=1:length(isMean)
    colNumber=isMean(counter);
    disp(allColNames{colNumber})
    midLine=table1.(allColNames{colNumber});
    semLine=table1.(allColNames{colNumber+1}); % assume that the sem comes after the mean
    stdLine=table1.(allColNames{colNumber+3}); % assume that the str comes 3 after the mean

    lowLine=midLine-stdLine;
    hiLine=midLine+stdLine;

    minMin=min(minMin, min(lowLine));
    maxMax=max(maxMax, max(hiLine));
end

%% set vertical range
maxDev=max(maxMax, abs(minMin)); % multiply by 1.1 if you want padding
set(gca, 'YLim', [-maxDev maxDev]) % symmetric and 

% set(gca, 'YLim', [-minMin maxMax]) % if you want it tighter and not symetric


%% add the vertical dashed lines at zero
for counter=1:length(isMean)
    midmid= dt*(midPoint+(counter-1)*(offsetBetweenGraphs+pointsPerGraph));

    plot([midmid midmid], [-maxDev maxDev], 'k--')

end

%% shaded areas and mid lines

plottingOrder=1:length(isMean); % if you want a different order, set it here
% plottingOrder=[2 3 1 7 3]
% e.g. plottingOrder=[2 3 1 7 3...]
% e.g. plottingOrder=flip(plottingOrder);
% plottingOrder=[12];

for counter=1:length(plottingOrder)
    colNumber=isMean(plottingOrder(counter));
    disp(allColNames{colNumber})
    midLine=table1.(allColNames{colNumber});
    semLine=table1.(allColNames{colNumber+1}); % assume that the sem comes after the mean
    stdLine=table1.(allColNames{colNumber+3}); % assume that the str comes 3 after the mean

    lowLine=midLine-stdLine; % can change to something difference if you want a broader range.  Like 2*std
    hiLine=midLine+stdLine;

    % puts the shading
    fillBetween(lowLine, hiLine, tRange=[(counter-1)*(pointsPerGraph+offsetBetweenGraphs)-1 dt], colorName='m');
    % puts the line
    plot(dt*((counter-1)*(pointsPerGraph+offsetBetweenGraphs)+pointRange), midLine, 'color', 'm', 'LineWidth', 1)
end


%% axes
axis tight
axis on
% ylim([-0.2 0.05])
set(gca, 'Position', [0.02 0.05 0.95 0.90])



