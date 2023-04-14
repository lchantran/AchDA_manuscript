
prefix='mean'; % set to mean for DA and delta for Ach
statsPlotColumns={[prefix '_cond1_avg'], [prefix '_cond2_avg']};
p_val_column=['ttest_' prefix '_p']; %condition_p'; 
addToPlot=false;


miceToPlot={'AVG1', 'AVG5'}; %{'AVG WT', 'AVG FF' ,'AVG KO'};
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

%% find the mice, to plot
if isempty(miceToPlot)
    miceToPlot=unique(statsTable.mouseID');
elseif ischar(miceToPlot)
    miceToPlot={miceToPlot};
end

nMice=length(miceToPlot);
gMice=miceToPlot;
% for mCounter=1:nMice
%     mouse=miceToPlot{mCounter};    
%     fff=find(contains(statsTable.mouseID, mouse));
%     gMice(mCounter)=statsTable.genotype(fff(1));
% end
% 
% [gMice, gggi]=sort(gMice);
% miceToPlot=miceToPlot(gggi);

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
xTickLabels={};

%% loop through stats measures for one channle, then find conditions, then mice and plot
for cCounter=1:length(conditionsToPlot)
    conditionIndex=conditionsToPlot(cCounter);

    %% loop through the mice
    for mCounter=1:nMice
        mouse=miceToPlot{mCounter};
        indices=find(statsTable.mouseID==mouse & statsTable.randomShuffle==false & statsTable.condition==conditionIndex);

        if length(channelsToPlot)==1
            indices=intersect(indices, find(statsTable.channel==channelsToPlot));
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
                    fColor=colorList{gCounter};
                end

                errorbar(xTicks+(gCounter-1)*0.1, valsToPlot(gCounter, :), errsToPlot(gCounter, :), ...
                   'Color', 'k', ... % markerList{markerIndex}, 
                    'LineStyle', '-', ...%'DisplayName', mouse, ...
                    'LineWidth', 1.5, ...
                    'Marker', markerList(1), ...
                    'MarkerSize', 10, 'MarkerFaceColor', fColor, ...
                    'MarkerEdgeColor', colorList{gCounter});
                %    xTicks=xTicks+size(errsToPlot, 1)+1;
                xMatrix(:, end+1)=xTicks+(gCounter-1)*0.1;
                yMatrix(:, end+1)=valsToPlot(gCounter, :);
                dMatrix(:, end+1)=errsToPlot(gCounter, :);
            end
        end
        xTickVals(end+1)=mean(xTicks);
        xTickLabels{end+1}=[mouse ' ' gMice{mCounter} ' (' num2str(round(100*statsTable.LDA_hyp_testPred(indices))) '%)'];
        xTicks=xTicks+nStats-0.5;
    end
    xTicks=xTicks+1.5;
end

if ~addToPlot
    % Create textbox
    annotation(gcf,'textbox',...
        [0.12 0.014626204238923 0.26125 0.0910404624277457],...
        'String',{'rewarded vs. unrewarded, post entry'},...
        'FontSize',18,...
        'EdgeColor','none');
    
    % Create textbox
    annotation(gcf,'textbox',...
        [0.448571428571429 0.0146262042389212 0.26 0.0910404624277457],...
        'String',{'rewarded vs. unrewarded, pre entry'},...
        'FontSize',18,...
        'EdgeColor','none');
    
    % Create textbox
    annotation(gcf,'textbox',...
        [0.0192857142857142 0.319077071290947 0.0969642857142857 0.0910404624277457],...
        'String',{'z-score'},...
        'Rotation',90,...
        'FontSize',18,...
        'EdgeColor','none');
    
    set(gca, 'XLim', [-1 max(xTicks)-1.5])
    
    set(gca, 'XTick', xTickVals)
    set(gca, 'XTickLabel', xTickLabels)
    
    set(gca, 'YTick', [-1.5 0 1.5])
    set(gca, 'Position',[0.05 0.35 0.95 0.6]);
    set(gcf, 'Position', [417         876        1400         355])
end