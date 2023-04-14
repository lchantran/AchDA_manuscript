
prefix='mean'; % set to mean for DA and delta for Ach
statsPlotColumns={[prefix '_cond1_avg'], [prefix '_cond2_avg']};
p_val_column=['ttest_' prefix '_p'];

%statsPlotColumns={'delta_cond1_avg', 'delta_cond2_avg'}; % for DA
miceToPlot={};
channelsToPlot=[1]; % set to 1 for DA and 5 for Ach
conditionsToPlot=[];
xMatrix=[];
yMatrix=[];
dMatrix=[];

%% set up colors and markers etc...
markDelta=.1;

colorList={'k', 'b', 'c', 'y', 'g', 'r'};
markerList={'o', 'd',  'square',  'd', '>', 'x'};


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

nStats=length(statsPlotIndices);
xTicks=0:(nStats-1);


%%
% allMarks=zeros(1, length(statsMarks*length(conditionsToPlot)));
% allLabels={};
% for cc=0:(length(conditionsToPlot)-1)
%     allMarks(cc*length(statsMarks)+(1:length(statsMarks)))=spreadFactor*cc*length(statsMarks)+(1:length(statsMarks));
%     allLabels=[allLabels statsLabels];
% end

figTitle='Summary';
disp(figTitle)
figure('NumberTitle', 'off', 'Name', figTitle)
set(gcf, 'Position', [800   500   1400   300])
set(gca,'TickDir','out')
hold on
%             set(gca, 'XTick', allMarks, 'XTickLabel', allLabels, 'XTickLabelRotation', 90); %statsNames(dprimePlotIndices))
%             set(gca, 'XLim', [min(allMarks)-1, max(allMarks)+1])

set(gca, 'FontSize', 14);
set(gca, 'XTickMode', 'manual', 'XTick', []);

%% loop through stats measures for one channle, then find conditions, then mice and plot
for cCounter=1:length(conditionsToPlot)
    conditionIndex=conditionsToPlot(cCounter);

    %% loop through the mice
    for mCounter=1:nMice
        mouse=miceToPlot{mCounter};
        indices=find(statsTable.mouseID==mouse & statsTable.randomShuffle==false & statsTable.condition==conditionIndex);


        if length(channelsToPlot)==1
            chIndices=find(statsTable.channel==channelsToPlot);
            indices=intersect(indices, chIndices);
        end

        if ~isempty(indices)
            valsToPlot=...
                statsTable{indices, statsPlotIndices};
            errsToPlot=...
                statsTable{indices, statsPlotIndices+1};

            for gCounter=1:size(valsToPlot, 1)
                lColor=colorList{mod(floor((cCounter-1)/4), 2)+1};
                if statsTable.(p_val_column)(indices(gCounter))<=0.01
                    fColor='w';
                else
                    fColor=lColor;
                end

                errorbar(xTicks+(gCounter-1)*0.1, valsToPlot(gCounter, :), errsToPlot(gCounter, :), ...
                   'Color', 'k', ... % markerList{markerIndex}, 
                    'LineStyle', '-', ...%'DisplayName', mouse, ...
                    'LineWidth', 1.5, ...
                    'Marker', markerList(1), ...
                    'MarkerSize', 10, 'MarkerFaceColor', fColor, ...
                    'MarkerEdgeColor', lColor);
                %    xTicks=xTicks+size(errsToPlot, 1)+1;
                xMatrix(:, end+1)=xTicks+(gCounter-1)*0.1;
                yMatrix(:, end+1)=valsToPlot(gCounter, :);
                dMatrix(:, end+1)=errsToPlot(gCounter, :);
            end
        end
        xTicks=xTicks+nStats-0.5;
    end
    xTicks=xTicks+1.5;%*nMice;
    if cCounter==8
        xTicks=xTicks+7;
    end
    xTicks=xTicks-7.45;
end

set(gca, 'Position',[0.0435714285714286 0.11 0.941428571428571 0.815]);

% Create textbox
annotation(gcf,'textbox',...
    [0.448571428571429 0.0146262042389212 0.146964285714286 0.0910404624277457],...
    'String',{'after entry'},...
    'FontSize',18,...
    'EdgeColor','none');

% Create textbox
annotation(gcf,'textbox',...
    [0.747142857142857 0.0156262042389212 0.164821428571429 0.0910404624277457],...
    'String',{'before entry'},...
    'FontSize',18,...
    'EdgeColor','none');

% Create textbox
annotation(gcf,'textbox',...
    [0.0192857142857142 0.319077071290947 0.0969642857142857 0.0910404624277457],...
    'String',{'z-score'},...
    'Rotation',90,...
    'FontSize',18,...
    'EdgeColor','none');
%set(gca, 'XLim', [-1 max(xTicks)-1.5])
