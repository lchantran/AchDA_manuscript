%%

outField='fig2test';
maxLags=300;

pairs=[5 6];
% pairs=[1 1; 5 5; 6 6; 5 6; 5 1; 1 6];
if ~exist('xcSummary', 'var')
    xcSummary=struct;
end

xcSummary.(outField)=[];

figure; hold on
title(outField)

%% set up one of the following two lines to find the sessions to process
% D=dir('processed_WT*'); % to get from disk
sessionsToAnalyze=who('processed_WT*')'; % search in memory

output=zeros(4, length(sessionsToAnalyze));

maxChan=max(max(pairs));

xcSummary.(outField).xcAll=cell(maxChan, maxChan);
for cc=1:size(pairs, 1)
    xcSummary.(outField).xcAll{pairs(cc, 1), pairs(cc, 2)}=zeros(length(sessionsToAnalyze), 2*maxLags+1);
    xcSummary.(outField).xcAllShuffle{pairs(cc, 1), pairs(cc, 2)}=zeros(length(sessionsToAnalyze), 2*maxLags+1);
end

%% Do some shuffling
inOrder=1:length(sessionsToAnalyze);
keepGoing=true;

while keepGoing
    [rrr, randOrder]=sort(rand(1, length(sessionsToAnalyze)));
    if any(inOrder==randOrder)
        keepGoing=true;
    else
        keepGoing=false;
    end
end


%% Loop through all the files
for sessionCounter=inOrder
    sessionName=sessionsToAnalyze{sessionCounter};
    sessionNameShuffle=sessionsToAnalyze{randOrder(sessionCounter)};

    disp(['Working on ' sessionName]);
    assignin('base', 'processed', eval(sessionName));
    assignin('base', 'processed_shuffle', eval(sessionNameShuffle));

    params=processed.params;

    mouse=params.mouse;
    date=params.date;

    for cc=1:size(pairs, 1)
        minLen=min(length(processed.signals{pairs(cc, 1)}),length(processed_shuffle.signals{pairs(cc, 2)}));
        [xcShuffle, ~]=xcorr(processed.signals{pairs(cc, 1)}(1:minLen), processed_shuffle.signals{pairs(cc, 2)}(1:minLen), maxLags, 'normalized');

        [xc,xl]=xcorr(processed.signals{pairs(cc, 1)}, processed.signals{pairs(cc, 2)}, maxLags, 'normalized');

        randShift=randi(10000);
        shiftData=circshift(processed.signals{pairs(cc, 2)}, randShift);
        [xcShift, ~]=xcorr(processed.signals{pairs(cc, 1)}(1:minLen), shiftData(1:minLen), maxLags, 'normalized');
        
        if sessionCounter==1 &&   cc==1
            xcSummary.(outField).lags=xl*processed.params.finalTimeStep;
        end
        xcSummary.(outField).xcAll{pairs(cc, 1), pairs(cc, 2)}(sessionCounter,:)=xc;
        xcSummary.(outField).xcAllShuffle{pairs(cc, 1), pairs(cc, 2)}(sessionCounter,:)=xcShuffle;
        xcSummary.(outField).xcAllShift{pairs(cc, 1), pairs(cc, 2)}(sessionCounter,:)=xcShift;        
        plot(xcSummary.(outField).lags, xc);
    end

end

figure; hold on
title('avg')
legend
for cc=1:size(pairs, 1)
    xcSummary.(outField).xcMean{pairs(cc, 1), pairs(cc, 2)}=...
        mean(xcSummary.(outField).xcAll{pairs(cc, 1), pairs(cc, 2)});
    xcSummary.(outField).xcVar{pairs(cc, 1), pairs(cc, 2)}=...
        var(xcSummary.(outField).xcAll{pairs(cc, 1), pairs(cc, 2)});
    xcSummary.(outField).xcStd{pairs(cc, 1), pairs(cc, 2)}=...
        std(xcSummary.(outField).xcAll{pairs(cc, 1), pairs(cc, 2)});
    xcSummary.(outField).xcSem{pairs(cc, 1), pairs(cc, 2)}=...
        std(xcSummary.(outField).xcAll{pairs(cc, 1), pairs(cc, 2)})...
        /sqrt(size(xcSummary.(outField).xcAll{pairs(cc, 1), pairs(cc, 2)}, 1));
    plot(xcSummary.(outField).lags, xcSummary.(outField).xcMean{pairs(cc, 1), pairs(cc, 2)}, ...
        'DisplayName', num2str(pairs(cc, :)))
end

figure; hold on
title('avg shuffle')
legend
for cc=1:size(pairs, 1)
    xcSummary.(outField).xcMeanShuffle{pairs(cc, 1), pairs(cc, 2)}=...
        mean(xcSummary.(outField).xcAllShuffle{pairs(cc, 1), pairs(cc, 2)});
    xcSummary.(outField).xcVarShuffle{pairs(cc, 1), pairs(cc, 2)}=...
        var(xcSummary.(outField).xcAllShuffle{pairs(cc, 1), pairs(cc, 2)});
    xcSummary.(outField).xcStdShuffle{pairs(cc, 1), pairs(cc, 2)}=...
        std(xcSummary.(outField).xcAllShuffle{pairs(cc, 1), pairs(cc, 2)});
    xcSummary.(outField).xcSemShuffle{pairs(cc, 1), pairs(cc, 2)}=...
        std(xcSummary.(outField).xcAllShuffle{pairs(cc, 1), pairs(cc, 2)})...
        /sqrt(size(xcSummary.(outField).xcAll{pairs(cc, 1), pairs(cc, 2)}, 1));
    plot(xcSummary.(outField).lags, xcSummary.(outField).xcMeanShuffle{pairs(cc, 1), pairs(cc, 2)}, ...
        'DisplayName', num2str(pairs(cc, :)))
end

figure; hold on
title('avg shift')
legend
for cc=1:size(pairs, 1)
    xcSummary.(outField).xcMeanShift{pairs(cc, 1), pairs(cc, 2)}=...
        mean(xcSummary.(outField).xcAllShift{pairs(cc, 1), pairs(cc, 2)});
    xcSummary.(outField).xcVarShift{pairs(cc, 1), pairs(cc, 2)}=...
        var(xcSummary.(outField).xcAllShift{pairs(cc, 1), pairs(cc, 2)});
    xcSummary.(outField).xcStdShift{pairs(cc, 1), pairs(cc, 2)}=...
        std(xcSummary.(outField).xcAllShift{pairs(cc, 1), pairs(cc, 2)});
    xcSummary.(outField).xcSemShift{pairs(cc, 1), pairs(cc, 2)}=...
        std(xcSummary.(outField).xcAllShift{pairs(cc, 1), pairs(cc, 2)})...
        /sqrt(size(xcSummary.(outField).xcAll{pairs(cc, 1), pairs(cc, 2)}, 1));
    plot(xcSummary.(outField).lags, xcSummary.(outField).xcMeanShift{pairs(cc, 1), pairs(cc, 2)}, ...
        'DisplayName', num2str(pairs(cc, :)))
end


%%
% outFields={'WT', 'FF', 'KO'};
outFields={'fig2test'};


for cc=1
    figure; hold on; legend; title(num2str(pairs(cc,:)));

    for outFieldCounter=1:length(outFields)
        outField=outFields{outFieldCounter};
        if isfield(xcSummary, outField) ...
                && isfield(xcSummary.(outField), 'xcMean') ...
                && ~isempty(xcSummary.(outField).xcMean{pairs(cc,1),pairs(cc,2)})
            meanVals=xcSummary.(outField).xcMean{pairs(cc,1),pairs(cc,2)};
            semVals=xcSummary.(outField).xcSem{pairs(cc,1),pairs(cc,2)};

            fillBetween(meanVals-semVals, meanVals+semVals, tRange=[-(maxLags+1)  processed.params.finalTimeStep]);
            plot(xcSummary.(outField).lags, meanVals, 'LineWidth', 2, 'DisplayName', [outField ' r1']);
            if isfield(xcSummary.(outField), 'xcMeanShuffle')

                meanVals=xcSummary.(outField).xcMeanShuffle{pairs(cc,1),pairs(cc,2)};
                semVals=xcSummary.(outField).xcSemShuffle{pairs(cc,1),pairs(cc,2)};

                fillBetween(meanVals-semVals, meanVals+semVals, tRange=[-(maxLags+1)  processed.params.finalTimeStep]);
                plot(xcSummary.(outField).lags, meanVals, 'LineWidth', 2, 'DisplayName', [outField ' shuffle r1']);
            end
            if isfield(xcSummary.(outField), 'xcMeanShift')

                meanVals=xcSummary.(outField).xcMeanShift{pairs(cc,1),pairs(cc,2)};
                semVals=xcSummary.(outField).xcSemShift{pairs(cc,1),pairs(cc,2)};

                fillBetween(meanVals-semVals, meanVals+semVals, tRange=[-(maxLags+1)  processed.params.finalTimeStep]);
                plot(xcSummary.(outField).lags, meanVals, 'LineWidth', 2, 'DisplayName', [outField ' shift r1']);
            end
        end
        %             plot(xcSummary.lags, xcSummary.xcMeanShuffle{pairs(cc,1),pairs(cc,2)}...
        %                 , 'DisplayName', 'WT r1')
        %             plot(xcSummary.lags, xcSummary.xcMeanShuffle{pairs(cc,1),pairs(cc,2)}...
        %                 , 'DisplayName', 'KO r1')
        %     plot(xcSummary.WT.lags, xcSummary.WT.xcMeanShuffle{pairs(cc,1),pairs(cc,2)}...
        %         , 'DisplayName', 'WT r1')
        %     plot(xcSummary.KO.lags, xcSummary.KO.xcMeanShuffle{pairs(cc,1),pairs(cc,2)}...
        %         , 'DisplayName', 'KO r1')

        %     plot(xcSummary.FF.lags, xcSummary.FF.xcMean{pairs(cc,1),pairs(cc,2)}.*...
        %         abs(xcSummary.FF.xcMean{pairs(cc,1),pairs(cc,2)}), 'DisplayName', 'FF r2')
        %     plot(xcSummary.WT.lags, xcSummary.WT.xcMean{pairs(cc,1),pairs(cc,2)}.*...
        %         abs(xcSummary.WT.xcMean{pairs(cc,1),pairs(cc,2)}), 'DisplayName', 'WT r2')
        %     plot(xcSummary.KO.lags, xcSummary.KO.xcMean{pairs(cc,1),pairs(cc,2)}.*...
        %         abs(xcSummary.KO.xcMean{pairs(cc,1),pairs(cc,2)}), 'DisplayName', 'KO r2')
        %
        %     plot(xcSummary.FF.lags, xcSummary.FF.xcMeanShuffle{pairs(cc,1),pairs(cc,2)}.*...
        %         abs(xcSummary.FF.xcMeanShuffle{pairs(cc,1),pairs(cc,2)}), 'DisplayName', 'FF r2')
        %     plot(xcSummary.WT.lags, xcSummary.WT.xcMeanShuffle{pairs(cc,1),pairs(cc,2)}.*...
        %         abs(xcSummary.WT.xcMeanShuffle{pairs(cc,1),pairs(cc,2)}), 'DisplayName', 'WT r2')
        %     plot(xcSummary.KO.lags, xcSummary.KO.xcMeanShuffle{pairs(cc,1),pairs(cc,2)}.*...
        %         abs(xcSummary.KO.xcMeanShuffle{pairs(cc,1),pairs(cc,2)}), 'DisplayName', 'KO r2')
    end
end
