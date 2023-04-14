
%% if plotting with the names, load up the descriptions and assume mouseViruses was loaded
if useVirusNames
    ABT_virusCode;
end

%% set up colors and markers etc...
markDelta=.1;

colorList={'k', 'b', 'c', 'y', 'g', 'r'};
markerList={'o',  'd', 'square',  '>', 'x'};


statsPlotIndices=zeros(1, length(statsPlotColumns));
for cC=1:length(statsPlotColumns)
    try
        statsPlotIndices(cC)=find(strcmp(statsPlotColumns{cC}, statsTable.Properties.VariableNames));
    catch
        error([statsPlotColumns{cC} ' column not found in stats table'])
    end
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

conditionsToPlotIndices=find(ismember(statsTable.condition, conditionsToPlot));
allIndices=find(ismember(statsTable.condition, conditionsToPlot-1));
nConditions=length(conditionsToPlot);

nMice=length(miceToPlot);
statsMarks=1:length(statsPlotColumns);
first=true;
plottedMice={};

mouseGap=6;
conditionGap=35;
channelGap=2;
statsColumnGap=.7;

colorIndex=1;
%% loop through stats measures for one channle, then find conditions, then mice and plot
for cCounter=1:length(conditionsToPlot)
    conditionIndex=conditionsToPlot(cCounter);
    %% loop through the chhannels
    for channelCounter=1:length(channelsToPlot)
        channel=channelsToPlot(channelCounter);

        %% make the figure for this channel
        ff=find(statsTable.condition==conditionIndex);
        if ~plotOnOneGraph
            figTitle=[char(statsTable.conditionString{ff(1)}) ', channel ' num2str(channel)];
            disp(figTitle)
            figure('NumberTitle', 'off', 'Name', figTitle)
            set(gcf, 'Position', [800   500   1400   300])
            set(gca, 'FontSize', 12)
            set(gca,'TickDir','out')
            hold on
%             set(gca, 'XTick', statsMarks, 'XTickLabel', statsLabels, 'XTickLabelRotation', 90); %statsNames(dprimePlotIndices))
%             set(gca, 'XLim', [min(statsMarks)-1, max(statsMarks)+1])
%             title(figTitle)
            marksOffset=0;
        elseif first
            allMarks=zeros(1, length(statsMarks*length(conditionsToPlot)));
            allLabels={};
            for cc=0:(length(conditionsToPlot)-1)
                allMarks(cc*length(statsMarks)+(1:length(statsMarks)))=spreadFactor*cc*length(statsMarks)+(1:length(statsMarks));
                allLabels=[allLabels statsLabels];
            end
            first=false;
            figTitle='Summary';
            disp(figTitle)
            figure('NumberTitle', 'off', 'Name', figTitle)
            set(gcf, 'Position', [800   500   1400   300])
            set(gca, 'FontSize', 12)
            set(gca,'TickDir','out')
            hold on
%             set(gca, 'XTick', allMarks, 'XTickLabel', allLabels, 'XTickLabelRotation', 90); %statsNames(dprimePlotIndices))
%             set(gca, 'XLim', [min(allMarks)-1, max(allMarks)+1])
            marksOffset=0;
        else
            marksOffset=spreadFactor*(cCounter-1)*length(statsMarks)+(channelCounter-1)*spreadFactor/30;
        end


        %% get some space for text on it

        startX=0.04;
        dX=0.94;
%         set(gca, 'Position', [startX    0.25    dX    0.68])

        valsToPlot=nan(1, nConditions);
        cisToPlot=nan(1, nConditions);

        colorIndex=1;

        if ~plotOnOneGraph
            colorIndex=1;
            plottedMice={};
        end
        %% loop through the mice
        for mCounter=1:nMice
            mouse=miceToPlot{mCounter};
            if strcmp(mouse, 'ALL') && ~plotALL
                disp('Skipping ALL')
            else
                indices=find(statsTable.mouseID==mouse & statsTable.channel==channel & statsTable.randomShuffle==false);
                if strcmp(mouse, 'ALL')
                    conditionIndices=find(statsTable.condition==conditionIndex-1);
                else
                    conditionIndices=find(statsTable.condition==conditionIndex);
                end
                indices=intersect(indices, conditionIndices);

                if ~isempty(indices)
%                     mouse
                    if mCounter==1 && plotOnOneGraph
    %                    sString=removeDash(removeDash(removeDash(removeDash(statsTable.conditionString{indices}, ''), '', '['), '', ']'), '', ' ');
                        sString=removeDash(removeDash(statsTable.conditionString{indices}, ''), ',', ' ');
                        annotation('textbox', ...
                            [startX+dX*(marksOffset+length(statsMarks)/2)/(spreadFactor*length(allMarks)+1), 0.08, 0, 0], ...
                            'string', sString, ...
                            'LineStyle', 'none', 'HorizontalAlignment', 'Center', 'FontSize', 10);
                    end
                    valsToPlot=...
                        min(statsTable{indices, statsPlotIndices}, maxVal);
                    errsToPlot=...
                        statsTable{indices, statsPlotIndices+1};
                    errsToPlot(~statsHasSd)=0;
    
                    statsMarksOffset=0.6*(mCounter-1-nMice/2)/nMice;
    
                    markerIndex=1+floor(colorIndex/length(colorList));

                    xTicks=statsColumnGap*(0:(length(valsToPlot)-1)) + (mCounter-1)*mouseGap + (cCounter-1)*conditionGap + (channelCounter-1)*channelGap;
                    % marksOffset+statsMarksOffset+statsMarks
                    errorbar(xTicks, valsToPlot, errsToPlot, ...
                        markerList{markerIndex}, 'Color', 'k', ...
                        'LineStyle', 'none', ...%'DisplayName', mouse, ...
                        'Marker', markerList(channelCounter), ...
                        'MarkerSize', 10, 'MarkerFaceColor', colorList{1+mod(colorIndex,6)}, ...
                        'MarkerEdgeColor', 'k');
                    plottedMice{end+1}=mouse;
                    colorIndex=colorIndex+1;
                end
            end
            if ~plotOnOneGraph
                yline(0)
                yline(-1)
                yline(0.5)
                yline(1)
                legend(plottedMice)
            end
        end
    end
end
if plotOnOneGraph
    yline(0)
    yline(-1)
    yline(0.5)
    yline(1)
    legend(plottedMice)
end

