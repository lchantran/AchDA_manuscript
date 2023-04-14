withVariances=false;
windowSize=0;
loadIfNecessary=false;
showLegend=true;
lineTransparency=0;  % 0.0 = solid, 0.9=90% transparent

alignmentCode='SI';
conds={'Rew'};
extraSavePrefix='ChatJax';
channels=[1];

if ischar(conds)
    conds={conds};
end

if windowSize>1
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
end


colorList={'g', 'r', 'b', 'k', 'm', 'c'};
colorCounter=0;
fHi=figure;
title('Hi')
hold on
if showLegend
    legend
end
fLow=figure;
title('Low')
hold on
if showLegend
    legend
end

for cCounter=1:length(conds)
    cond=conds{cCounter};
    condExtra=[extraSavePrefix cond];
    for chCounter=1:length(channels)
        channel=channels(chCounter);
        colorCounter=max(mod(colorCounter+1, length(colorList)),1);

        for dataSessionCounter=1:length(processed_sum.ph.(alignmentCode).(condExtra).components)
            dataSession=processed_sum.ph.(alignmentCode).(condExtra).components{dataSessionCounter};

            if exist(dataSession, 'var')
                ana=eval([dataSession '.ph.(alignmentCode).(cond)']);
            else
                disp(['Loading missing session ' dataSession]);
                fileName=[dataSession '.mat'];
                temp=load(fileName);
                ff=fieldnames(temp);
                eval([dataSession '=temp.(ff{1})']);
                clear temp
                ana=eval([dataSession '.ph.(alignmentCode).(cond)']);
            end

            curvemid=ana.xc_noise{5,6};%ana.photometry_mean{channel};
%            sem=0     photometry_std{channel}/sqrt(length(ana.trialIndices));
%            curvea=curvemid+sem;
%            curveb=curvemid-sem;

            disp([dataSession '.ph.(' alignmentCode ').(' cond ') ' num2str(channel)]);
            disp([0 0 mean(curvemid) var(curvemid) skewness(curvemid) kurtosis(curvemid)]);

            if windowSize>1
%                curvea=filter(b, a, curvea);
%                curveb=filter(b, a, curveb);
                curvemid=filter(b, a, curvemid);
%                curvea(1:windowSize)=nan;
%                curveb(1:windowSize)=nan;
                curvemid(1:windowSize)=nan;              
            end
            if withVariances
                fillBetween(...
                    curvea, ...
                    curveb, ...
                    colorList{colorCounter});
                lineWidth=2;
            else
                lineWidth=1;
            end

            if mean(curvemid(70:75)<-0.1)
                figure(fHi);
            else
                figure(fLow);
            end
              
            if showLegend 
                hLine=plot(curvemid, ...
                    'DisplayName', removeDash(dataSession), ...
                    'Color', colorList{colorCounter}, ...
                    'LineWidth', lineWidth);
                hLine.Color(4)=1-lineTransparency;
            else
                hLine=plot(curvemid, ...
                    'Color', colorList{colorCounter}, ...
                    'LineWidth', lineWidth);
                hLine.Color(4)=1-lineTransparency;
            end
        end
    end
end
