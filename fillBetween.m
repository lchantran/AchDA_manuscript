function ph=fillBetween(curvea, curveb, options)
arguments
    curvea (1,:) double
    curveb (1,:) double
    options.colorName char='b' % color to use
    options.tRange (1,2) double=[0 1]
    options.plotSideWays logical=false
    options.axPlot handle=[]
    options.opacity double=0.3
end

if isempty(options.axPlot)
    options.axPlot=gca;
end

if length(curvea)~=length(curveb)
    error('curves must be same legnth');
end

xx=options.tRange(2)*((1:length(curvea))+options.tRange(1));

if options.plotSideWays
    ph=patch(options.axPlot, [curvea fliplr(curveb)], [xx fliplr(xx)], options.colorName, 'LineStyle', 'none', 'FaceAlpha', options.opacity);
else
    ph=patch(options.axPlot, [xx fliplr(xx)], [curvea fliplr(curveb)], options.colorName, 'LineStyle', 'none', 'FaceAlpha', options.opacity);
end

