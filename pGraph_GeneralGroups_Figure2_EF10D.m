
prefix='max'; % set to mean for DA and delta for Ach
statsPlotColumns={[prefix '_cond1_avg'], [prefix '_cond2_avg']};
p_val_column=['ttest_' prefix '_p']; %condition_p';
addToPlot=false;


miceToPlot={};


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

combosToPlot={... % {'label', {condition1, channel1, metric1, group1}, {condition2, channel2, metric2, group2}}
    {'DA post mean Rew', {1, 1, 'mean', 1 }, {1, 6, 'mean', 1}}...
    {'DA post mean NoRew', {1, 1, 'mean', 2}, {1, 6, 'mean', 2}}...
    {'DA pre mean All', {1, 6, 'mean', 1}, {1, 2, 'mean', 1}}...
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
for comboCounter=1:length(combosToPlot)
    combo=combosToPlot{comboCounter};

    for mCounter=1:length(miceToPlot)
        mouse=miceToPlot(mCounter);
        valsToPlot=[];
        errsToPlot=[];

        xTicks=xTicksOffset+(1:(length(combo)-1));
        xTickVals=[xTickVals xTicks];

        dataVals={};
        allPairedData={};

        for condCounter=2:length(combo)
            condition=combo{condCounter}{1};
            channel=combo{condCounter}{2};
            metric=combo{condCounter}{3};
            group=combo{condCounter}{4};
            colName=[metric '_cond' num2str(group) '_avg'];
            colNameSD=[metric '_cond' num2str(group) '_sd'];


            index=find(statsTable.mouseID==mouse & statsTable.randomShuffle==false & statsTable.condition==condition & statsTable.channel==channel);

            columnIndex=1+find(contains({'mean', 'max', 'min', 'delta'}, metric));
            dataVals{condCounter}=allValues{index, columnIndex}{group};
            allPairedData{condCounter}=allValues{index, columnIndex}{group};

            xTickLabels(end+1)=[char(statsTable.mouseID(index)) 'Ch' num2str(channel)];





            if ~isempty(index)
                valsToPlot(end+1)=...
                    statsTable{index, colName};
                errsToPlot(end+1)=...
                    statsTable{index, colNameSD};
            end
        end

        %[tth,ttp_mean,ttci]=ttest2(dataVals{2}, dataVals{3});
        [tth,ttp]=ttest(dataVals{2}, dataVals{3})
        if ttp<=0.05
            fColor='w';
        else
            fColor='k';
        end

        mergedTrainData=[allPairedData{2}; allPairedData{3}];
        mergedTrainLabels=[zeros(length(allPairedData{2}), 1); ones(length(allPairedData{3}), 1)];
        Mdl = fitcdiscr(mergedTrainData,mergedTrainLabels, ...
            'OptimizeHyperparameters', 'auto',...
            'HyperparameterOptimizationOptions', ...
            struct('ShowPlots', false, 'Verbose', 0, ...
            'Repartition', true, ...
            'AcquisitionFunctionName','expected-improvement-plus'));
        %    close all

        yy=predict(Mdl, mergedTrainData);
        trainPredHyp=mean((mergedTrainLabels==yy));
        disp(['OVERALL hyp test set accuracy, train ' num2str(trainPredHyp)])

        xTickLabels(end)=[xTickLabels{end} ' ' num2str(round(trainPredHyp*100)) '%']

        % figure; histogram(dataVals{2})
        % hold on
        % histogram(dataVals{3})

        errorbar(xTicks, valsToPlot, errsToPlot, ...
            'Color', 'k', ... % markerList{markerIndex},
            'LineStyle', '-', ...%'DisplayName', mouse, ...
            'LineWidth', 1.5, ...
            'Marker', markerList(1), ...
            'MarkerSize', 10, 'MarkerFaceColor', fColor, ...
            'MarkerEdgeColor', 'k');

        drawnow
        if ~isempty(xTicks)
            xTicksOffset=max(xTicks)+0.5;
        end    
    end
end

if ~addToPlot
    dx=0.85/length(combosToPlot);

    for cCounter=1:length(combosToPlot)
        % Create textbox
        x0=dx/2+(cCounter-1)*dx;
        annotation(gcf,'textbox',...
            [ x0 0.014626204238923 0.1 0.0910404624277457],...
            'String', combosToPlot{cCounter}{1},...
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