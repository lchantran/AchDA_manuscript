
prefix='mean'; % set to mean for DA and delta for Ach
statsPlotColumns={[prefix '_cond1_avg'], [prefix '_cond2_avg']};
p_val_column=['ttest_' prefix '_p']; %condition_p';

%miceToPlot={};
channelsToPlot=[15];
conditionsToPlot=[1 3 4 5];
xMatrix=[];
yMatrix=[];
dMatrix=[];

addToPlot=false;

%% set up colors and markers etc...
markDelta=.1;

colorList={'k', 'b', 'c', 'y', 'g', 'r'};
markerList={'o', 'd',  'square',  'd', '>', 'x'};

if addToPlot
    domColor='b';
else
    domColor='k';
end

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

if addToPlot
    xTicks=xTicks+0.4;
end

%%
% allMarks=zeros(1, length(statsMarks*length(conditionsToPlot)));
% allLabels={};
% for cc=0:(length(conditionsToPlot)-1)
%     allMarks(cc*length(statsMarks)+(1:length(statsMarks)))=spreadFactor*cc*length(statsMarks)+(1:length(statsMarks));
%     allLabels=[allLabels statsLabels];
% end
%
if ~addToPlot
    figTitle='Summary';
    disp(figTitle)
    figure('NumberTitle', 'off', 'Name', figTitle)
    set(gcf, 'Position', [800   500   1400   300])
    set(gca,'TickDir','out')
    hold on
end
%
%  set(gca, 'XTickLabelRotation', 30); %statsNames(dprimePlotIndices))
% %             set(gca, 'XLim', [min(allMarks)-1, max(allMarks)+1])
% %
%  set(gca, 'FontSize', 14);
% % set(gca, 'XTickMode', 'manual', 'XTick', []);

xTickVals=[];
xTickLabels={};

condLabels={};

%% loop through stats measures for one channle, then find conditions, then mice and plot
for cCounter=1:length(conditionsToPlot)
    conditionIndex=conditionsToPlot(cCounter);

    %% loop through the mice
    for mCounter=1:nMice
        mouse=miceToPlot{mCounter};
        [mouse ' ' num2str(conditionIndex) ' ' num2str(channelsToPlot)]
        indices=find(statsTable.mouseID==mouse & statsTable.randomShuffle==false & statsTable.condition==conditionIndex);

        if length(channelsToPlot)==1
            indices=intersect(indices, find(statsTable.channel==channelsToPlot))
        end

        if ~isempty(indices)
            valsToPlot=...
                statsTable{indices, statsPlotIndices};
            errsToPlot=...
                statsTable{indices, statsPlotIndices+1};

            for gCounter=1:size(valsToPlot, 1)
                if isempty(p_val_column) || statsTable.(p_val_column)(indices(gCounter))<=0.05
                    fColor='w';
                else
                    fColor=domColor;
                end

                errorbar(xTicks+(gCounter-1)*0.1, valsToPlot(gCounter, :), errsToPlot(gCounter, :), ...
                    'Color', domColor, ... % markerList{markerIndex},
                    'LineStyle', '-', ...%'DisplayName', mouse, ...
                    'LineWidth', 1.5, ...
                    'Marker', markerList(1), ...
                    'MarkerSize', 10, 'MarkerFaceColor', fColor, ...
                    'MarkerEdgeColor', domColor);
                %    xTicks=xTicks+size(errsToPlot, 1)+1;
                xMatrix(:, end+1)=xTicks+(gCounter-1)*0.1;
                yMatrix(:, end+1)=valsToPlot(gCounter, :);
                dMatrix(:, end+1)=errsToPlot(gCounter, :);
            end
        end
        xTickVals(end+1)=mean(xTicks);
        xTickLabels{end+1}=[mouse ' (' num2str(round(100*statsTable.LDA_hyp_testPred(indices))) '%)'];
        xTicks=xTicks+nStats-0.5
    end
    condLabels{end+1}=statsTable.conditionString{indices(1)};
    xTicks=xTicks+1.5;
end

if ~addToPlot
    dx=0.85/length(conditionsToPlot);

    for cCounter=1:length(conditionsToPlot)
        % Create textbox
        x0=dx/2+(cCounter-1)*dx;
        annotation(gcf,'textbox',...
            [ x0 0.014626204238923 0.1 0.0910404624277457],...
            'String', condLabels{cCounter},...
            'FontSize',12,...
            'EdgeColor','none');
    end


    set(gca, 'XLim', [-1 max(xTicks)-1.5])

    set(gca, 'XTickLabel', xTickLabels)


    set(gca, 'YTick', [-1.5 0 1.5])
    set(gca, 'Position',[0.05 0.35 0.855 0.6]);
    set(gcf, 'Position', [417         876        1400         355])
end
