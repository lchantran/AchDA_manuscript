
if ~useCurrent
    %suffix='S13XX_5_1_Rew';
    suffix=saveSuffix;
    %mDiag=ana.(suffix).xcv_norm_pp;
    mDiag=anaSum.(suffix).xcv_norm_pp;
end

suffix='SI.NoRew'
mDiag=processed_sum.ph.SI.NoRew.xc2_noise{5, 6};


prefix=suffix;
disp(['Extracting diagonals from ' suffix])
r2=1;
if r2==1
    prefix=[prefix ' R2 '];
end


if doPlot
    dfig=figure;
    hold on
    title(removeDash([prefix 'diag xcv']));
    ifig=figure;
    hold on
    set(gca, 'YDir', 'reverse')
    title(removeDash([prefix 'diag index']));
end

sampleStep=1;

nLagSamples=4;
nSampleRange=-nLagSamples:sampleStep:nLagSamples;
nSamples=size(mDiag, 1);

imm=nan(length(nSampleRange), nSamples);

ccc=0;
for dSamples=nSampleRange
    ccc=ccc+1;
    if dSamples<0
        minX=1;
        maxX=nSamples+dSamples;
        dY=-dSamples;
    else
        minX=dSamples+1;
        maxX=nSamples;
        dY=-dSamples;
    end

    nDiagPoints=maxX-minX+1;
    dData=zeros(1, nDiagPoints);
    for counterX=minX:maxX
        dData(counterX-minX+1)=mDiag(counterX+dY, counterX).*abs(mDiag(counterX+dY, counterX));
    end

    imm(ccc, minX:maxX)=dData;
    if doPlot
        figure(dfig)
        plot([dSamples:(dSamples+nDiagPoints-1)], dData+dSamples/sampleStep);
        plot([dSamples:(dSamples+nDiagPoints-1)], 0*dData+dSamples/sampleStep, 'color', 'black', 'LineStyle', '--');
        figure(ifig)
        plot(minX:maxX, (minX:maxX)+dY);
    end
end

% if ~useCurrent
%     ana.(suffix).diagCCs=imm;
%     anaSum.(suffix).diagCCs=imm;
% else
%     ana.(suffix).diagCCs=imm;
% end

if doPlot
    figure
    imagesc(1:nSamples, nSampleRange, imm); colorbar;
    set(gca, 'YDir', 'normal')
    title(removeDash([prefix 'm1>m2']));
end