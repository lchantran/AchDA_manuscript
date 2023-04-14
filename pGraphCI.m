function ph=pGraphCI(dataSet, options)
arguments
    dataSet double
    options.colorName char='b' % color to use
    options.tRange (1,2) double=[0 1]
    options.plotSideWays logical=false
    options.axPlot handle=[]
    options.opacity double=0.3
    options.lineWidth double=1
    options.midMode char {mustBeMember(options.midMode,['mean','median', 'given'])} = 'median'   
    options.CIMode char {mustBeMember(options.CIMode,['std','sem'])} = 'sem'   
end

if isempty(options.axPlot)
    options.axPlot=gca;
end

switch options.midMode
    case 'mean'
        curvemid=mean(dataSet);
    case 'median'
        curvemid=median(dataSet);
    case 'given'
        curvemid=dataSet(1,:);
        curveCI=dataSet(2,:);
        options.CIMode='none';
end

switch options.CIMode
    case 'std'
        curveCI=std(dataSet);
    case 'sem'
        curveCI=std(dataSet)/sqrt(size(dataSet,1));
end

ph=fillBetween(curvemid-curveCI, curvemid+curveCI, ...
    axPlot=options.axPlot, opacity=options.opacity, ...
    plotSideWays=options.plotSideWays, tRange=options.tRange, colorName=options.colorName);

xx=options.tRange(2)*((1:length(curvemid))+options.tRange(1));

if isempty(options.axPlot)
    options.axPlot=gca;
end

hold(options.axPlot, 'on')
if options.lineWidth>0
    if options.plotSideWays
        plot(options.axPlot, curvemid, xx, 'color', options.colorName, 'LineWidth', options.lineWidth);            
    else
        plot(options.axPlot, xx, curvemid, 'color', options.colorName, 'LineWidth', options.lineWidth);
    end
end


