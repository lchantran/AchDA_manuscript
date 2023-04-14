
addToPlot=false;
pickedMiceToPlot={};


%% set up colors and markers etc...

colorList={'k', 'b', 'c', 'y', 'g', 'r'};
markerList={'o', 'd',  'square',  'd', '>', 'x'};
pairedData=false;

doLDA=true;


mashUp=false;
mashUpChan=6;
mashUpOffset=-52;

% combosToPlot={... % {'label', {condition1, channel1, metric1, group1}, {condition2, channel2, metric2, group2}}
%     {'DA post mean Rew', {1, 11, 'mean', 1 }, {1, 15, 'mean', 1}}...
%     {'DA post mean UnRew', {1, 11, 'mean', 2 }, {1, 15, 'mean', 2}}...
%     {'DA pre mean All', {2, 11, 'mean', 2 }, {2, 15, 'mean', 2}}...
%     };


combosToPlot={... % {'label', {condition1, channel1, metric1, group1}, {condition2, channel2, metric2, group2}}
    {'DA Rew LED noLED', {1, 1, 'mean', 2}, {1, 1, 'mean', 1}}...
    {'DA Rew LED noLED', {2, 1, 'mean', 2}, {2, 1, 'mean', 1}}...
    {'DA Rew LED noLED', {3, 1, 'mean', 2}, {3, 1, 'mean', 1}}...
    {'DA Rew LED noLED', {4, 1, 'mean', 2}, {4, 1, 'mean', 1}}...
    {'DA NoRew LED noLED', {5, 1, 'mean', 2}, {5, 1, 'mean', 1}}...
    {'DA NoRew LED noLED', {6, 1, 'mean', 2}, {6, 1, 'mean', 1}}...
    {'DA NoRew LED noLED', {7, 1, 'mean', 2}, {7, 1, 'mean', 1}}...
    {'DA NoRew LED noLED', {8, 1, 'mean', 2}, {8, 1, 'mean', 1}}...
    {'DA PreRew LED noLED', {9, 1, 'mean', 2}, {9, 1, 'mean', 1}}...
    {'DA PreRew LED noLED', {10, 1, 'mean', 2}, {10, 1, 'mean', 1}}...
    {'DA PreRew LED noLED', {11, 1, 'mean', 2}, {11, 1, 'mean', 1}}...
    {'DA PreRew LED noLED', {12, 1, 'mean', 2}, {12, 1, 'mean', 1}}...
    {'DA PreNoRew LED noLED', {13, 1, 'mean', 2}, {13, 1, 'mean', 1}}...
    {'DA PreNoRew LED noLED', {14, 1, 'mean', 2}, {14, 1, 'mean', 1}}...
    {'DA PreNoRew LED noLED', {15, 1, 'mean', 2}, {15, 1, 'mean', 1}}...
    {'DA PreNoRew LED noLED', {16, 1, 'mean', 2}, {16, 1, 'mean', 1}}...
    };

%% find the mice, to plot
if isempty(pickedMiceToPlot)
    allMiceToPlot=unique(statsTable.mouseID');
elseif ischar(pickedMiceToPlot)
    allMiceToPlot={pickedMiceToPlot};
elseif iscell(pickedMiceToPlot)
    allMiceToPlot=pickedMiceToPlot;
end


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

    mouseIndices=...
        find(contains(statsTable.mouseID, allMiceToPlot) & ...
        (statsTable.channel==combo{2}{2} | statsTable.channel==combo{3}{2}) & ...
        (statsTable.condition==combo{2}{1} | statsTable.condition==combo{3}{1}));
    
    miceToPlot=unique(statsTable.mouseID(mouseIndices))

    for mCounter=1:length(miceToPlot)
        mouse=miceToPlot(mCounter)
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
            if mashUp && channel==mashUpChan
                set1=allValues{index, 1}{group};
                set2=allValues{index+mashUpOffset, 1}{group};
                allPairedData{condCounter}=[set1, set2];
            else
                allPairedData{condCounter}=allValues{index, 1}{group};
            end


            if condCounter==2
                xTickLabels(end+1)=[char(statsTable.mouseID(index)) 'Ch' num2str(channel)];
            else
                xTickLabels(end+1)=['Ch' num2str(channel)];
            end

            if ~isempty(index)
                valsToPlot(end+1)=...
                    statsTable{index, colName};
                errsToPlot(end+1)=...
                    statsTable{index, colNameSD};
            end
        end

        if ~pairedData
            [tth,ttp,ttci]=ttest2(dataVals{2}, dataVals{3});
        else
            [tth,ttp]=ttest2(dataVals{2}, dataVals{3});
        end

        if ttp<=0.05
            fColor='w';
        else
            fColor='k';
        end

        if doLDA
            if pairedData 
                allN1=size(allPairedData{2}, 1);
                allN2=allN1;
                trainN=floor(0.7*allN1);
                testN=allN1-trainN;
                testIndices1=randperm(allN1, testN);
                trainIndices1=setdiff(1:allN1, testIndices1);
    
                testIndices2=testIndices1;
                trainIndices2=trainIndices1;
            else
                allN1=size(allPairedData{2}, 1);
                allN2=size(allPairedData{3}, 1);
                trainN=min(floor(0.7*allN1), floor(0.7*allN2));
    
                trainIndices1=randperm(allN1, trainN);
                trainIndices2=randperm(allN2, trainN);
    
                if allN1<=allN2
                    testN=allN1-trainN;
                    testIndices1=setdiff(1:allN1, trainIndices1);
                    remTest=setdiff(1:allN2, trainIndices2);
                    remIndex=randperm(length(remTest), testN);
                    testIndices2=remTest(remIndex);
                else
                    testN=allN2-trainN;
                    testIndices2=setdiff(1:allN2, trainIndices2);
                    remTest=setdiff(1:allN1, trainIndices1);
                    remIndex=randperm(length(remTest), testN);
                    testIndices1=remTest(remIndex);
                end
            end            
    
            mergedTrainData=[allPairedData{2}(trainIndices1, :); allPairedData{3}(trainIndices2, :)];
            mergedTrainLabels=[zeros(trainN, 1); ones(trainN, 1)];
            Mdl = fitcdiscr(mergedTrainData,mergedTrainLabels, ...
                'OptimizeHyperparameters', 'auto',...
                'HyperparameterOptimizationOptions', ...
                struct('ShowPlots', false, 'Verbose', 0, ...
                'Repartition', true, ...
                'AcquisitionFunctionName','expected-improvement-plus'));
            %    close all
    
            yy=predict(Mdl, mergedTrainData);
            trainPredHyp=mean((mergedTrainLabels==yy));
            disp(['OVERALL hyp TRAIN set accuracy: ' num2str(trainPredHyp)])
    
            mergedTestData=[allPairedData{2}(testIndices1, :); allPairedData{3}(testIndices2, :)];
            mergedTestLabels=[zeros(testN, 1); ones(testN, 1)];
    
            yy=predict(Mdl, mergedTestData);
            testPredHyp=mean((mergedTestLabels==yy));
            disp(['OVERALL hyp TEST set accuracy: ' num2str(testPredHyp)])
    
            xTickLabels(end)=[xTickLabels{end} ' ' num2str(round(testPredHyp*100)) '%'];
        end

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
            xTicksOffset=max(xTicks);
        end
    end
    xTicksOffset=xTicksOffset;
    if mod(condition, 4)==0
        xTicksOffset=xTicksOffset+1;
    end
        
end

if ~addToPlot
    dx=0.85/length(combosToPlot);

    for cCounter=1:4:length(combosToPlot)
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