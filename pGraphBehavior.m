function pGraphBehavior(ana, conds, options)
arguments
    ana struct
    conds
    options.bySide logical=false
    options.tRange double=[0 1]
    options.axPlot handle=[]
    options.behaviorMap cell={}
    options.behaviorSet char {mustBeMember(options.behaviorSet, {'2ABT', 'Shijia', 'Wallace'})}='2ABT'
end

if ischar(conds)
    conds={conds};
end

if isempty(options.axPlot)
    figure
    options.axPlot=axes;
end
hold(options.axPlot, 'on');
legend

colorList={'g', 'r', 'b', 'k', 'm', 'c'};

switch options.behaviorSet
    case 'Shijia'
         options.behaviorMap={...
             {'cue', 'risingEdge', 1},...
             {'lick', 'risingEdge', 2},...
             {'rew', 'risingEdge', 4}...
           %  {'mov', 'downSampled', 5}...
             };
    case 'Wallace'
         options.behaviorMap={...
             {'CI', 'risingEdge', 1},...
             {'CO', 'fallingEdge', 1},...
             {'SI_R', 'risingEdge', 2}...
             {'SO_R', 'fallingEdge', 2}...
             {'SI_L', 'risingEdge', 3}...
             {'SO_L', 'fallingEdge', 3}...
            };         
end

displayNames={};

for cCounter=1:length(conds)
    cond=conds{cCounter};
    nPoints=length(ana.(cond).risingEdge_mean(1,:));
    xx=options.tRange(2)*((1:nPoints)+options.tRange(1));

    if ~isempty(options.behaviorMap)
        for bCounter=1:length(options.behaviorMap)
            trio=options.behaviorMap{bCounter};
            dataField=ana.(cond).([trio{2} '_mean']);
            plot(xx, ...
                dataField(trio{3},:), ...
                'Color', colorList{bCounter}, 'LineWidth', cCounter);
            displayNames{end+1}=removeDash([trio{1} ' ' cond]);
        end
    else
        plot(xx, ...
            ana.(cond).risingEdge_mean(1,:), ...
            'Color', colorList{1}, 'LineWidth', cCounter);
        displayNames{end+1}=['CI ' removeDash(cond)];

        plot(xx, ...
            ana.(cond).fallingEdge_mean(1,:), ...
             'Color', colorList{1}, 'LineStyle', '--', 'LineWidth', cCounter);
        displayNames{end+1}=['CO ' removeDash(cond)];
    
        if options.bySide
            plot(xx, ...
                ana.(cond).risingEdge_mean(3,:), ...
                'Color', colorList{2}, 'LineWidth', cCounter);
            displayNames{end+1}=['SI L ' removeDash(cond)];
            plot(xx, ...
                -ana.(cond).risingEdge_mean(2,:), ...
                'Color', colorList{2}, 'LineWidth', cCounter);
            displayNames{end+1}=['SI R ' removeDash(cond)];
    
            plot(xx, ...
                ana.(cond).fallingEdge_mean(3,:), ...
                'Color', colorList{2}, 'LineStyle', '--', 'LineWidth', cCounter);
            displayNames{end+1}=['SO L ' removeDash(cond)];            
            plot(xx, ...
                -ana.(cond).fallingEdge_mean(2,:), ...
                'Color', colorList{2}, 'LineStyle', '--', 'LineWidth', cCounter);
            displayNames{end+1}=['SO R ' removeDash(cond)];            
    
            plot(xx, ...
                ana.(cond).risingEdge_mean(4,:), ...
                'Color', colorList{3}, 'LineWidth', cCounter);
            displayNames{end+1}=['Licks L ' removeDash(cond)];            
            plot(xx, ...
                -ana.(cond).risingEdge_mean(5,:), ...
                'Color', colorList{3}, 'LineWidth', cCounter);
            displayNames{end+1}=['Licks R ' removeDash(cond)];            
        else
            plot(xx, ...
                (ana.(cond).risingEdge_mean(2,:)+ana.(cond).risingEdge_mean(3,:)), ...
                'Color', colorList{2}, 'LineWidth', cCounter);
            displayNames{end+1}=['SI ' removeDash(cond)];            
            plot(xx, ...
                (ana.(cond).fallingEdge_mean(2,:)+ana.(cond).fallingEdge_mean(3,:)), ...
                'Color', colorList{2}, 'LineStyle', '--', 'LineWidth', cCounter);
            displayNames{end+1}=['SO ' removeDash(cond)];            
    
            plot(xx, ...
                (ana.(cond).risingEdge_mean(4,:)+ana.(cond).risingEdge_mean(5,:)), ...
                'Color', colorList{3}, 'LineWidth', cCounter);
            displayNames{end+1}=['Licks ' removeDash(cond)];            
        end
    end
    set(gca, 'XLim', [min(xx) max(xx)])

end

if options.bySide
    plot([0 0], [-1 1], 'K--','DisplayName','')
else
    plot([0 0], [0 1], 'K--','DisplayName','')
end
displayNames{end+1}='';
legend(displayNames)

