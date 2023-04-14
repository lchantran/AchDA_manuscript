% assumes dPrimeTable and statsTable are loaded
%% plot dprime and stats

miceToPlot={'WT62'};
conditionsToPlot=[2:2:28];
channelsToPlot=1; [1 5 6];
useVirusNames=true;
plotOnlyThese={'dLight', 'Grab-Ach', 'rGrab-DA', 'jrCamp1b'};
saveFigures=false;
saveFigurePath=fullfile('.', 'statsFigures');
allChanLabels={'dLight', '', '', '', 'Grab-Ach', 'rGrab-DA'};


%% if plotting with the names, load up the descriptions and assume mouseViruses was loaded
if useVirusNames
    ABT_virusCode;
end

%% set up colors and markers etc...
markDelta=.1;

colorList={'g', 'r', 'b', 'y'};
markerList={'o', 'square', 'x'};

statsPlotColumns={'LDA_trainPred_avg', 'LDA_testPred_avg', 'LDA_hyp_trainPred', 'LDA_hyp_testPred', 'moment1_train_cond1_avg', 'moment2_train_cond1_avg', 'moment1_train_cond2_avg', 'moment2_train_cond2_avg', 'moment1_p_avg', 'moment2_p_avg', 'moment3_p_avg', 'moment4_p_avg'};
statsPlotIndices=zeros(1, length(statsPlotColumns));
for cC=1:length(statsPlotColumns)
    statsPlotIndices(cC)=find(strcmp(statsPlotColumns{cC}, statsTable.Properties.VariableNames));
end
statsLabels={'LDA train', 'LDA test', 'LDA hyp train', 'LDA hyp test', 'mean1', 'var1', 'mean2', 'var2', 'mean p', 'var p', 'skew p', 'kurtosis p'};

dPrimePlotColumns={'LDA_testPred_dp', 'moment1_train_cond1_dp', 'moment2_train_cond1_dp', 'moment3_train_cond1_dp','moment1_train_cond2_dp', 'moment2_train_cond2_dp', 'moment3_train_cond2_dp'};
dPrimePlotIndices=zeros(1, length(dPrimePlotColumns));
for cC=1:length(dPrimePlotColumns)
    dPrimePlotIndices(cC)=find(strcmp(dPrimePlotColumns{cC}, dPrimeTable.Properties.VariableNames));
end
dprimeLabels={'LDA test', 'mean 1', 'var 1', 'skew 1', 'mean 2', 'var 2', 'skew 2', 'mean', 'dMean'};

statsMarks=length(statsPlotIndices);
dprimeMarks=length(dPrimePlotIndices);


%% find the mice, to plot
if isempty(miceToPlot)
    miceToPlot=unique(statsTable.mouseID');
elseif ischar(miceToPlot)
    miceToPlot={miceToPlot};
end


%% loop through mice and then find conditions and channels for that mouse
for mCounter=1:length(miceToPlot)
    mouseID=miceToPlot{mCounter};
    mouseIndices=find(contains(statsTable.mouseID, mouseID));

    if isempty(conditionsToPlot)
        conditionsToPlotNow=unique(statsTable.condition(mouseIndices));
    else
        conditionsToPlotNow=conditionsToPlot';
    end
    if isempty(channelsToPlot)
        channelsToPlotNow=unique(statsTable.channel(mouseIndices));
    else
        channelsToPlotNow=channelsToPlot;
    end

    if size(channelsToPlotNow, 1)>size(channelsToPlotNow, 2)
        channelsToPlotNow=channelsToPlotNow';
    end
    if size(conditionsToPlotNow, 1)>size(conditionsToPlotNow, 2)
        conditionsToPlotNow=conditionsToPlotNow';
    end
    
    %% loop through conditions
    for condition=conditionsToPlotNow
        % make the stats figure
        figure('NumberTitle', 'off', 'Name', [mouseID ' cond:' num2str(condition)])
        set(gcf, 'Position', [ 15   539   841   290]);
        set(gca, 'FontSize', 12)
        hold on

        set(gca, 'XTick', (1:statsMarks)-1, 'XTickLabel', statsLabels, 'XTickLabelRotation', 30);
        set(gca, 'XLim', [-0.5 statsMarks-0.5+1.5])

        legendStrings={};

        midChan=mean(channelsToPlotNow);
        %% loop through channels for stats table
        % not shuffled
        channelsToPlotNext=[];
        for channel=channelsToPlotNow
            index=find(...
                contains(statsTable.mouseID, mouseID) & ...
                statsTable.condition==condition & ...
                statsTable.channel==channel & ...
                statsTable.randomShuffle==false  ...
                );

            plotChannel=true;
            chanLegend=['Chan' num2str(channel)];
            if useVirusNames
                mouseVirusIndex=find(strcmp(mouseID, mouseViruses(:,1)));
                if ~isempty(mouseVirusIndex)
                    vList=mouseViruses{mouseVirusIndex(1),2};
                    virusToFind=num2str(vList(channel));
                    getVirusName
                    if ~isempty(virusName)
                        chanLegend=virusName;
                        if ~isempty(plotOnlyThese)
                            plotEntry=find(strcmp(virusName, plotOnlyThese));
                            if isempty(plotEntry)
                                plotChannel=false;
                            end
                        end
                    elseif ~isempty(plotOnlyThese)
                        plotChannel=false;
                    end
                end
            end

            if ~isempty(index) && plotChannel
                ees=double(statsTable{index, statsPlotIndices+1}); ees(3:4)=0;
                errorbar((channel-midChan)*markDelta+(1:statsMarks)-1, statsTable{index, statsPlotIndices}, ees, ...
                    markerList{channel}, 'Color', 'k', ...
                    'LineWidth', 1, ...%'DisplayName', ['Chan' num2str(channel)], ...
                    'MarkerSize', 10, 'MarkerFaceColor', colorList{channel}, ...
                    'MarkerEdgeColor', 'k');
                legendStrings{end+1}=chanLegend;
                channelsToPlotNext(end+1)=channel;
            end

        end
        yline(0, 'k--')
        yline(0.5, 'k--')
        yline(1, 'k--')

        %  shuffled
        for channel=channelsToPlotNext
            index=find(...
                contains(statsTable.mouseID, mouseID) & ...
                statsTable.condition==condition & ...
                statsTable.channel==channel & ...
                statsTable.randomShuffle==true  ...
                );

            if ~isempty(index)
                ees=double(statsTable{index, statsPlotIndices+1}); ees(3:4)=0;
                errorbar((channel-midChan)*markDelta+(1:statsMarks)-1, statsTable{index, statsPlotIndices}, ees, ...
                    'x', 'Color', 'k', ...
                    'LineWidth', 1, ...%'DisplayName', ['Chan' num2str(channel)], ...
                    'MarkerSize', 10, 'MarkerFaceColor', colorList{channel}, ...
                    'MarkerEdgeColor', 'k');
            end
        end

        xx=get(gca, 'YLim');
        xx(1)=min(xx(1), -1);
        xx(2)=max(xx(2), 2);
        set(gca, 'YLim',xx);

        figTitle=[char(mouseID) ' ' char(statsTable.analysisMode(index)) ' ' char(statsTable.conditionString(index)) ' #' num2str(condition)];
        set(gcf, 'Name', figTitle);
        legend(legendStrings);%, 'Position', [    0.7170    0.6969    0.0868    0.1983]);
        if saveFigures
            saveas(gcf, fullfile(saveFigurePath, ['stats_' figTitle '.fig']))
        end

        % make the dprime figure
        figure('NumberTitle', 'off', 'Name', figTitle)
        set(gcf, 'Position', [860   539   526   290]);
        set(gca, 'FontSize', 12)
        hold on
        set(gca, 'XTick', (1:dprimeMarks)-1, 'XTickLabel', dprimeLabels, 'XTickLabelRotation', 30); %dPrimeNames(dprimePlotIndices))
        set(gca, 'XLim', [-0.5 dprimeMarks-0.5+1.5])
        for channel=channelsToPlotNext
            index=find(...
                contains(dPrimeTable.mouseID, mouseID) & ...
                dPrimeTable.condition==condition & ...
                dPrimeTable.channel==channel ...
                );
            if ~isempty(index)
                plot((channel-midChan)*markDelta+(1:dprimeMarks)-1, dPrimeTable{index, dPrimePlotIndices}, markerList{channel},...
                    'LineWidth', 1, 'MarkerSize', 10, ...
                    'MarkerFaceColor', colorList{channel}, 'MarkerEdgeColor', 'k')
            end
        end
        legend(legendStrings)
        xx=get(gca, 'YLim');
        xx(1)=min(xx(1), 0);
        xx(2)=max(xx(2), 10);
        set(gca, 'YLim',xx);
        if saveFigures
            saveas(gcf, fullfile(saveFigurePath, ['dprime_' figTitle '.fig']))
        end        
    end
end

