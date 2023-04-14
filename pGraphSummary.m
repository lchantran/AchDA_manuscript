function pGraphSummary(ana, conditionList, channels, options)
arguments
    ana struct
    conditionList
    channels double
    options.tRange double=[0 1]
    options.allBehavior logical=false
    options.behaviorMap cell={}
    options.behaviorSet char='2ABT'
    options.square logical=false
    options.combineChannels=false
end

if ischar(conditionList)
    conditionList={conditionList};
end

if options.square
    ssw=floor(sqrt(length(channels)));
    ssh=ceil(sqrt(length(channels)))+1;
else
    ssw=1;
    if options.combineChannels
        ssh=2;
    else    
        ssh=length(channels)+1;
    end
end
behSections=(ssw*ssh-ssw+1):(ssw*ssh);

figure
aaa=subplot(ssh, ssw, behSections);

title(['Behavior ' removeDash(conditionList{1})])
if options.allBehavior
    pGraphBehavior(ana, conditionList, tRange=options.tRange, axPlot=aaa, ...
        behaviorSet=options.behaviorSet, ...
        behaviorMap=options.behaviorMap);
else
    pGraphBehavior(ana, conditionList{1}, tRange=options.tRange, axPlot=aaa, ...
        behaviorSet=options.behaviorSet, ...
        behaviorMap=options.behaviorMap);
end

axesHandlesX(1)=aaa;
axesHandlesY=[];
for cCounter=1:length(channels)
    channel=channels(cCounter);
%     rrr=floor(cCounter)/ssw+1;
%     ccc=cCounter-(rrr-1)*ssw;
    if options.combineChannels
        aaa=subplot(ssh, ssw, 1);
    else
        aaa=subplot(ssh, ssw, cCounter);
    end        
    
    axesHandlesX(end+1)=aaa;
    axesHandlesY(end+1)=aaa;
    title(['Ch' num2str(channel)])
    pGraph(ana, conditionList, channel, axPlot=aaa, tRange=options.tRange, zeroLine=true);
end
linkaxes(axesHandlesX, 'x')
linkaxes(axesHandlesY, 'y')

