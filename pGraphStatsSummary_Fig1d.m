% assumes dPrimeTable and statsTable are loaded
load('statsAndMore Figure1_DA.mat')

%% plot dprime and stats

dPrimePlotColumns={'mean', 'mean_c12_dp', 'var', 'LDA_testPred_dp'};%, 'MSE_train_cond1_dp', 'MSE_train_cond2_dp'};
dPrimeLabels={'mean ', 'dMean', 'var ',  'LDA ', 'MSE1', 'MSE2'};

miceToPlot={};
conditionsToPlot=[2:2:size(dPrimeTable,2)];
allMatch=conditionsToPlot-1;

plotOnOneGraph=true;
channelsToPlot=1;
useVirusNames=true;
plotOnlyThese={'dLight', 'Grab-Ach', 'rGrab-DA', 'jrCamp1b'};
saveFigures=true;
saveFigurePath=fullfile('.', 'statsFigures');
allChanLabels={'dLight', '', '', '', 'Grab-Ach', 'rGrab-DA'};

maxVal=20; % put a cap on the value to keep the y-scale the same

%% if plotting with the names, load up the descriptions and assume mouseViruses was loaded
if useVirusNames
    ABT_virusCode;
end

%% set up colors and markers etc...
markDelta=.1;

colorList={'k', 'b', 'c', 'y', 'g', 'r'};
markerList={'o', 'o', '', '', 'square', 'square'};


dPrimePlotIndices=zeros(1, length(dPrimePlotColumns));
for cC=1:length(dPrimePlotColumns)
    dPrimePlotIndices(cC)=find(strcmp(dPrimePlotColumns{cC}, dPrimeTable.Properties.VariableNames));
end


%% find the mice, to plot
if isempty(miceToPlot)
    miceToPlot=unique(statsTable.mouseID');
elseif ischar(miceToPlot)
    miceToPlot={miceToPlot};
end

if isempty(conditionsToPlot)
    conditionsToPlot=unique(statsTable.condition);
end

if isempty(channelsToPlot)
    channelsToPlot=unique(statsTable.channel);
end

if size(channelsToPlot, 1)>size(channelsToPlot, 2)
    channelsToPlot=channelsToPlot';
end

if size(conditionsToPlot, 1)>size(conditionsToPlot, 2)
    conditionsToPlot=conditionsToPlot';
end

nConditions=length(conditionsToPlot);

nMice=length(miceToPlot);
dPrimeLabelsAll=repmat(miceToPlot, 1, nConditions);
dPrimeMarksAll=zeros(1, nMice*nConditions);

for counter=1:nConditions
    dPrimeMarksAll((0:(nMice-1))+(counter-1)*nMice+1)=(0:(nMice-1))+(counter-1)*nMice+counter;
end

colorCounter=0;
%% loop through dPrime measures for one channle, then find conditions, then mice and plot
for dpCounter=1:length(dPrimePlotIndices)
    dpIndex=dPrimePlotIndices(dpCounter);

    %% loop throught the chhannels
    for channel=channelsToPlot
        colorCounter=colorCounter+1;
        %% make the figure for this channel and dpPrimeMeasure
        if ~plotOnOneGraph || ((dpCounter==1) && (channel==channelsToPlot(1)))
            if plotOnOneGraph
                figTitle='Summary';
            else
                figTitle=[char(dPrimeLabels{dpCounter}) ', channel ' num2str(channel)];
            end
            figure('NumberTitle', 'off', 'Name', figTitle)
            set(gcf, 'Position', [800   500   1400   300])
            set(gca, 'FontSize', 12)
            set(gca,'TickDir','out')
            hold on
            set(gca, 'XTick', dPrimeMarksAll, 'XTickLabel', dPrimeLabelsAll, 'XTickLabelRotation', 90); %dPrimeNames(dprimePlotIndices))
            set(gca, 'XLim', [min(dPrimeMarksAll)-1, max(dPrimeMarksAll)+1])
            if ~plotOnOneGraph
                title(figTitle)
            end
            if ~isempty(maxVal) && ~isinf(maxVal)
                set(gca, 'YLim', [0 maxVal])
            end
        end

        %% get some text on it
        startX=0.04; 
        dX=0.94;
        set(gca, 'Position', [startX    0.25    dX    0.68])
        
        %% loop through conditions

        valsToPlot=nan(1, nMice*nConditions);
        cisToPlot=nan(1, nMice*nConditions);

        for conditionCounter=1:nConditions
            condition=conditionsToPlot(conditionCounter);

            annotation('textbox', ...
                [startX+dX/(2*nConditions)+(conditionCounter-1)*dX/nConditions, 0.08, 0, 0], ...
                'string', conditionSets{condition}{1}, ...
                'LineStyle', 'none', 'HorizontalAlignment', 'Center', 'FontSize', 14);

            indices=find(dPrimeTable.condition==condition & dPrimeTable.channel==channel);
            if ~isempty(allMatch) && ~isnan(allMatch(conditionCounter))
                allIndex=[find(dPrimeTable.condition==allMatch(conditionCounter) & dPrimeTable.channel==channel)];
                indices=[allIndex; indices];
                valsToPlot((0:(nMice-1))+(conditionCounter-1)*nMice+1)=...
                    min(dPrimeTable.(dPrimePlotColumns{dpCounter})(indices), maxVal);
            else
                valsToPlot((1:(nMice-1))+(conditionCounter-1)*nMice+1)=...
                    min(dPrimeTable.(dPrimePlotColumns{dpCounter})(indices), maxVal);
            end

        end

        if plotOnOneGraph
            dPrimeMarksOffset=0.2*(dpCounter-ceil((1+length(dPrimePlotIndices)/2)));
        else
            dPrimeMarksOffset=0;
        end
        plot(dPrimeMarksOffset+dPrimeMarksAll, valsToPlot, 'o', ...
            'LineStyle', 'none', 'MarkerSize', 10, ...
            'MarkerEdgeColor', 'k', 'MarkerFaceColor', colorList{colorCounter}, 'DisplayName',[dPrimeLabels{dpCounter} 'Ch' num2str(channel)]); 
    end
end

if plotOnOneGraph
    legend
end

