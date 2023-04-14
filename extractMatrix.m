function [rMatrix, errorStrings]=extractMatrix(rawSignal, events, prePts, postPts, options)
arguments
    rawSignal
    events
    prePts
    postPts
    options.timeList=false
    options.binSize=1
    options.trimEvents=true
end

errorStrings={};

if isempty(events)
    rMatrix=[];
    return
end

if isrow(rawSignal) || iscolumn(rawSignal) % it's 1D
    if options.trimEvents
        fff=union(find(events<1), find(events>length(rawSignal)));
        if ~isempty(fff)
            events(fff)=[];
        end
    end

    rMatrix=zeros(length(events), postPts+prePts+1);

    for counter=1:length(events)
        range=events(counter)+(-prePts:postPts);
        if min(range)>0 && max(range)<=length(rawSignal)
            rMatrix(counter, :)=rawSignal(range);
        else
            mess=['extractMatrix: data lacking. Event #' num2str(counter)];
            errorStrings=statusUpdate(errorStrings, mess);
        end
    end
elseif ismatrix(rawSignal) % it's 2D  signals x time
    if options.trimEvents
        fff=union(find(events<prePts), find(events>=(-postPts+size(rawSignal, 2))));
        if ~isempty(fff)
            events(fff)=[];
        end
    end

    rMatrix=zeros(length(events), size(rawSignal, 1), postPts+prePts+1);

    for counter=1:length(events)
        range=events(counter)+(-prePts:postPts);
        if min(range)>0 && max(range)<=length(rawSignal)
            rMatrix(counter, :, :)=rawSignal(:, range);
        else
            mess=['extractMatrix: data lacking. Event #' num2str(counter)];
            errorStrings=statusUpdate(errorStrings, mess);
        end
    end

end
