%% make beta coefficient plots

% First use readtable to read in the data from a csv file from josh.
dataFolder=['/Users/lynnechantranupong/Dropbox (HMS)/2ABT_data_bernardo/test/_new_from_BS/betas/final_outputs_rev'];
cd(dataFolder)

% table1=readtable('Figure_1_2-reconstruct-gACH=base_simple.csv');
table1=readtable('Figure_3-reconstruct-gACH=1_rDA_to_gACH.csv');

dt=0.054;
zeroPoint=41;

pointsPerGraph=height(table1);
pointRange=0:(pointsPerGraph-1);
offsetBetweenGraphs=2;

keepColNames={};
allColNames=fieldnames(table1);
true_mn=find(contains(allColNames, '_T_mn'));
recon_mn=find(contains(allColNames, '_P_mn'));

%% make the figure 
figure; 
hold on; 

%% horizontal zero line
plot([0 dt*(length(true_mn)*(offsetBetweenGraphs+pointsPerGraph))], [0 0], 'k--')

%% find vertical range

minMin=-1;
maxMax=1;

for counter=1:length(true_mn)
    colNumber=true_mn(counter);
    disp(allColNames{colNumber})

    lowLine=table1.(allColNames{colNumber-1}); % assume that the low comes before mean
    hiLine=table1.(allColNames{colNumber+1}); % assume that the upper comes after mean

    minMin=min(minMin, min(lowLine));
    maxMax=max(maxMax, max(hiLine));

    colNumber=recon_mn(counter);

    lowLine=table1.(allColNames{colNumber-1}); % assume that the low comes before mean
    hiLine=table1.(allColNames{colNumber+1}); % assume that the upper comes after mean    
end

%% set vertical range
maxDev=max(maxMax, abs(minMin)); % multiply by 1.1 if you want padding
set(gca, 'YLim', [-maxDev maxDev]) % symmetric and 

% set(gca, 'YLim', [-minMin maxMax]) % if you want it tighter and not symetric


%% add the vertical dashed lines at zero
for counter=1:length(true_mn)
    midmid= dt*(zeroPoint+(counter-1)*(offsetBetweenGraphs+pointsPerGraph));

    plot([midmid midmid], [-maxDev maxDev], 'k--')

end

%% shaded areas and mid lines for the true and reconstructed

plottingOrder=1:length(true_mn); % if you want a different order, set it here

% e.g. plottingOrder=[2 3 1 7 3...]
% e.g. plottingOrder=flip(plottingOrder);

for counter=1:length(plottingOrder)
    % the true signals
    trueColNumber=true_mn(plottingOrder(counter));
    reconColNumber=recon_mn(plottingOrder(counter));
    
    disp(allColNames{trueColNumber})

    % true bounds
    lowLine=table1.(allColNames{trueColNumber-1}); % assume that the sem comes after the mean
    hiLine=table1.(allColNames{trueColNumber+1}); % assume that the str comes 3 after the mean

    % plots the shading for the true
    fillBetween(lowLine, hiLine, tRange=[(counter-1)*(pointsPerGraph+offsetBetweenGraphs)-1 dt], ...
        colorName='k', opacity=0.1);

    % recon bounds
    lowLine=table1.(allColNames{reconColNumber-1}); % assume that the sem comes after the mean
    hiLine=table1.(allColNames{reconColNumber+1}); % assume that the str comes 3 after the mean

    % plots the shading for the recon
    fillBetween(lowLine, hiLine, tRange=[(counter-1)*(pointsPerGraph+offsetBetweenGraphs)-1 dt], ...
        colorName='g', opacity=0.1);

    % plots the lines
    % true line
    midLine=table1.(allColNames{trueColNumber});
    plot(dt*((counter-1)*(pointsPerGraph+offsetBetweenGraphs)+pointRange), midLine, 'color', 'k', 'LineWidth', 1)
    % recon line
    midLine=table1.(allColNames{reconColNumber});
    plot(dt*((counter-1)*(pointsPerGraph+offsetBetweenGraphs)+pointRange), midLine, 'color', 'g', 'LineWidth', 1)


end


%% axes
axis tight
axis on
ylim([-1.5 2.1])
set(gca, 'Position', [0.02 0.05 0.95 0.90])


