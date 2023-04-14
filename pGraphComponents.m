withVariances=false;
windowSize=0;
loadIfNecessary=false;
showLegend=false;
lineTransparency=0.8;  % 0.0 = solid, 0.9=90% transparent

alignmentCode='SI';
conds={'Rew'};
extraSavePrefix='LabD2RKO';
channels=[5 6];

if ischar(conds)
    conds={conds};
end

if windowSize>1
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
end

figure
hold on
if showLegend
    legend
end

colorList={'g', 'r', 'b', 'k', 'm', 'c'};
colorCounter=0;

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

            curvemid=ana.photometry_mean{channel};
            sem=ana.photometry_std{channel}/sqrt(length(ana.trialIndices));
            curvea=curvemid+sem;
            curveb=curvemid-sem;

            disp([dataSession '.ph.(' alignmentCode ').(' cond ') ' num2str(channel)]);
            disp([0 0 mean(curvemid) var(curvemid) skewness(curvemid) kurtosis(curvemid)]);

            if windowSize>1
                curvea=filter(b, a, curvea);
                curveb=filter(b, a, curveb);
                curvemid=filter(b, a, curvemid);
                curvea(1:windowSize)=nan;
                curveb(1:windowSize)=nan;
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

            if showLegend && dataSessionCounter==1 && cCounter==1
                hLine=plot(curvemid, ...
                    'DisplayName', [removeDash(cond) ' ' num2str(channel)], ...
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
