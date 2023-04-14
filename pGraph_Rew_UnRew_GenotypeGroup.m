
prefix='max'; % set to mean for DA and delta for Ach
statsPlotColumns={[prefix '_cond1_avg'], [prefix '_cond2_avg']};
p_val_column=['ttest_' prefix '_p']; %condition_p';
addToPlot=false;


miceToPlot={'AVG1', 'AVG5'}; %,'AVG cKO'};
channelsToPlot=[1];
conditionsToPlot=[];
xMatrix=[];
yMatrix=[];
dMatrix=[];

%% set up colors and markers etc...
markDelta=.1;

colorList={'k', 'b', 'c', 'y', 'g', 'r'};
markerList={'o', 'd',  'square',  'd', '>', 'x'};

% WTMice={'S1355', 'S1356', 'S1357', 'S1358', 'S1376', 'S1399', 'S1400', 'S1401', 'S1448', 'S1449', 'S1450', 'S1451'};
% FFMice={'S1417', 'S1419', 'S1421', 'S1460', 'S1462', 'S1473', 'S1474'};
% KOMice={'S1416', 'S1418', 'S1420', 'S1459', 'S1461', 'S1470', 'S1471', 'S1472'};
%
% statsTable.genotype=statsTable.mouseID;
% statsTable.genotype(find(contains(statsTable.mouseID, WTMice)))='WT';
% statsTable.genotype(find(contains(statsTable.mouseID, FFMice)))='FF';
% statsTable.genotype(find(contains(statsTable.mouseID, KOMice)))='KO';


statsPlotIndices=zeros(1, length(statsPlotColumns));
for cC=1:length(statsPlotColumns)
    try
        statsPlotIndices(cC)=find(strcmp(statsPlotColumns{cC}, statsTable.Properties.VariableNames));
    catch
        error([statsPlotColumns{cC} ' column not found in stats table'])
    end
end

combosToPlot={... % condition, channel, column
    {1, 6, 'mean_cond1_avg', 'mean_cond1_sd',  'DA post mean Rew'}...
    {1, 6, 'mean_cond2_avg', 'mean_cond2_sd',  'DA post mean NoRew'}...
    {11, 6, 'mean_cond1_avg', 'mean_cond1_avg',  'DA pre mean All'}...
    {1, 5, 'mean_cond1_avg', 'mean_cond1_sd', 'Ach post Rew'}...
    {1, 5, 'mean_cond2_avg', 'mean_cond2_sd',  'Ach post NoRew'}...
    {2, 5, 'mean_cond1_avg', 'mean_cond1_sd',  'Ach post2 mean Rew'}...
    {2, 5, 'mean_cond2_avg', 'mean_cond2_sd',  'Ach post2 mean NoRew'}...
    {11, 5, 'mean_cond1_avg', 'mean_cond1_sd',  'Avg pre mean All'}...    
%    {12, 5, 'mean_cond1_avg', 'mean_cond1_sd',  'Avg pre2 mean All'}...
    };

%% find the mice, to plot
if isempty(miceToPlot)
    miceToPlot=unique(statsTable.mouseID');
elseif ischar(miceToPlot)
    miceToPlot={miceToPlot};
end
miceToPlotID=find(contains(statsTable.mouseID, miceToPlot));



if ~addToPlot
    figTitle='Summary';
    disp(figTitle)
    figure('NumberTitle', 'off', 'Name', figTitle)
    set(gcf, 'Position', [800   500   1400   300])
    set(gca,'TickDir','out')
    hold on
end

set(gca, 'XTickLabelRotation', 30);
set(gca, 'FontSize', 14);

xTickVals=[];
xTickLabels=strings(1,0);
xTicksOffset=0;
boxLabel={};

%% loop through stats measures for one channle, then find conditions, then mice and plot
for cCounter=1:length(combosToPlot)
    condition=combosToPlot{cCounter}{1};
    channel=combosToPlot{cCounter}{2};
    colName=combosToPlot{cCounter}{3};
    colNameSD=combosToPlot{cCounter}{4};

    indices=find(statsTable.randomShuffle==false & statsTable.condition==condition & statsTable.channel==channel);
    indices=intersect(indices, miceToPlotID);

    allIndices=find(statsTable.randomShuffle==false & statsTable.condition==condition & statsTable.channel==channel);
    allIndices=setdiff(allIndices, indices);
    aaa=anova(statsTable.genotype(allIndices), statsTable.(colName)(allIndices));

    pVal=aaa.stats.pValue(1);
    if pVal<=0.05
        fColor='w';
    else
        fColor='k';
    end

    indices=[indices(3) indices(1) indices(2)];
    %% loop through the mice

    if ~isempty(indices)
        valsToPlot=...
            statsTable{indices, colName};
        errsToPlot=...
            statsTable{indices, colNameSD};

        xTicks=xTicksOffset+(1:length(indices));
        xTickVals=[xTickVals xTicks];
        xTickLabels=[xTickLabels statsTable.mouseID(indices)'];
        errorbar(xTicks, valsToPlot, errsToPlot, ...
            'Color', 'k', ... % markerList{markerIndex},
            'LineStyle', '-', ...%'DisplayName', mouse, ...
            'LineWidth', 1.5, ...
            'Marker', markerList(1), ...
            'MarkerSize', 10, 'MarkerFaceColor', fColor, ...
            'MarkerEdgeColor', 'k');
        %    xTicks=xTicks+size(errsToPlot, 1)+1;
        disp([combosToPlot{cCounter}{5} ' ' num2str(pVal)])
        if pVal<=0.05
            boxLabel{end+1}=[combosToPlot{cCounter}{5} ' ' num2str(pVal)];
        else
            boxLabel{end+1}=[combosToPlot{cCounter}{5}];
        end

    end
    %         xTicks=xTicks+nStats-0.5;
    if ~isempty(xTicks)
        xTicksOffset=max(xTicks)+0.5;
    end
end

if ~addToPlot
    dx=0.85/length(combosToPlot);

    for cCounter=1:length(combosToPlot)
        % Create textbox
        x0=dx/2+(cCounter-1)*dx;
        annotation(gcf,'textbox',...
            [ x0 0.014626204238923 0.1 0.0910404624277457],...
            'String',boxLabel{cCounter},...
            'FontSize',12,...
            'EdgeColor','none');
    end
    %    set(gca, 'XLim', [-1 max(xTicks)-1.5])

    set(gca, 'XTick', xTickVals)
    set(gca, 'XTickLabel', xTickLabels)

    %   set(gca, 'YTick', [-1.5 0 1.5])
    set(gca, 'Position',[0.05 0.35 0.9 0.6]);
    set(gcf, 'Position', [417         876        1400         355])
end