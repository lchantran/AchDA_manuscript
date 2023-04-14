function [imAxis, ch1Axis, ch2Axis]=pGraphXC(ana, cond, chan1, chan2, options)
arguments
    ana struct
    cond char
    chan1 double
    chan2 double
    options.tRange (1,2) double=[0 1]
    options.colorList cell={'g', 'r'}
    options.CLim double=[-1 1]
    options.title char=''
    options.r2=false
end

if isfield(ana.(cond), 'photometry_mean_sa_n') % it's an average across session
    ciBands='rmsSem';
else
    ciBands='sem';
end

% make a new figure and give it a title
if ~isempty(options.title)
    figTitle=options.title;
else
    figTitle=[removeDash(cond) ' Y:' num2str(chan1) ' X:' num2str(chan2)];
end

figure('NumberTitle', 'off', 'Name', figTitle);
ppp=get(gcf, 'Position');
ppp(3:4)=[477 455];
set(gcf, 'Position', ppp);

% set up the time range for the plots
nPoints=length(ana.(cond).photometry_mean{chan1});
xxx=options.tRange(2)*((1:nPoints)+options.tRange(1));
minMaxRange=[xxx(1) xxx(end)];

% make a 4x4 grid of plots and use the lower right 3x3 for the image
imAxis=subplot(4, 4, [6 7 8 10 11 12 14 15 16]);
axis off
axis square

hold(imAxis, 'on');
if options.r2
    imagesc(ana.(cond).xc2_noise{chan1, chan2}.*abs(ana.(cond).xc2_noise{chan1, chan2}), 'XData', xxx, 'YData', xxx)
else
    imagesc(ana.(cond).xc2_noise{chan1, chan2}, 'XData', xxx, 'YData', xxx)
end

xTicks=get(imAxis, 'XTick');
plot(imAxis, [0 0], minMaxRange, 'k--');
plot(imAxis, minMaxRange, [0 0], 'k--');
set(imAxis, 'CLim', options.CLim)
set(imAxis, 'XLim', minMaxRange, 'YLim', minMaxRange, 'YTick', xTicks, 'YDir', 'reverse');

% put the channel 1 signal along the left edge
ch1Axis=subplot(4, 4, [5 9 13]);
set(ch1Axis,'xaxisLocation','top')
pGraph(ana, cond, chan1, tRange=options.tRange, axPlot=ch1Axis, plotSideWays=true, bands=ciBands, colorList=options.colorList(1))
hold(ch1Axis, 'on');
set(ch1Axis, 'YLim', minMaxRange, 'YTick', xTicks, 'YDir', 'reverse', 'XDir', 'reverse');
rRange=1.1*max(abs(get(ch1Axis, 'XLim')));
set(ch1Axis, 'XLim', rRange*[-1 1]);
plot(ch1Axis, rRange*[-1 1], [0 0], 'k--');
legend off

% put the channel 2 signal along the top
ch2Axis=subplot(4, 4, [ 2 3 4]);
set(ch2Axis,'xaxisLocation','top')
pGraph(ana, cond, chan2, tRange=options.tRange, axPlot=ch2Axis, bands=ciBands, colorList=options.colorList(2))
hold(ch2Axis, 'on');
set(ch2Axis, 'XLim', minMaxRange, 'XTick', xTicks);
rRange=1.1*max(abs(get(ch2Axis, 'YLim')));
set(ch2Axis, 'YLim', rRange*[-1 1]);
plot(ch2Axis, [0 0], rRange*[-1 1], 'k--');
legend off

linkaxes([imAxis ch2Axis], 'x')
linkaxes([imAxis ch1Axis], 'y')







