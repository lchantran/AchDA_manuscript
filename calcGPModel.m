function [R, cmvIndex]=calcGPModel(inData, options)
arguments
    inData (1,:) double
    options.dataRange double=[];
    options.maxPoints double=20000;
    options.maxlag double=0;
    options.plot logical=false;
    options.cmvIndex double=[];
    options.freq double=1;
end

if ~isempty(options.dataRange)
    inData=inData(options.dataRange);
end

maxPoints=min(options.maxPoints, length(inData));
sigData=normalize(double(inData(1:maxPoints)));

L=length(sigData);

if options.maxlag==0
    options.maxlag=L;
end

cc=xcorr(sigData, options.maxlag, 'normalize');

if options.plot
    figure; plot(cc)
end

lengthCC=length(cc);

if isempty(options.cmvIndex) || size(options.cmvIndex,1)~=L
    disp('Making Matrix');
    cmvIndex=zeros(L,L);
    for counter=1:L
        if options.maxlag==L
            cmvIndex(counter,:)=mod(L-counter+(1:L), lengthCC)+1;
        else
            mmin=max(counter-options.maxlag, 1);
            mmax=min(counter+options.maxlag, L);

            rmin=max(options.maxlag-counter+2, 1);
            rmax=rmin+(mmax-mmin);
            cmvIndex(counter, mmin:mmax)=...
                rmin:rmax;
        end
    end
else
    disp('Using last matrix');
    cmvIndex=options.cmvIndex;
end

if options.maxlag==L
    cmv=cc(cmvIndex);
else
    cmv=zeros(L,L);
    cmv(cmvIndex>0)=cc(cmvIndex(cmvIndex>0));
end

disp('Modeling with covariance structure')
R=normalize(mvnrnd(zeros(1,L), cmv));

cc2=xcorr(R, options.maxlag, 'normalized');

if options.plot
    figure; hold on
    legend
    plot(R, 'DisplayName', 'model');
    plot(sigData, 'DisplayName', 'data');
    
    figure; hold on
    legend
    plot(cc, 'DisplayName', 'data cc')
    plot(cc2, 'DisplayName', 'model cc')
    
    myFFT(sigData, options.freq );
    hold on
    myFFT(R, options.freq, 0, gca);
end

disp('DATA [mean var skew kurt]')
disp([mean(sigData) var(sigData) skewness(sigData,0) kurtosis(sigData,0)])
disp('GAUSSIAN MODEL [mean var skew kurt]')
disp([mean(R) var(R) skewness(R,0) kurtosis(R,0)])


% searchFit
% 
% processed.gpFits(ind).sData=sData;
% processed.gpFits(ind).sGauss=sGauss;
% processed.gpFits(ind).sModel=sModel;
% processed.gpFits(ind).kData=kData;
% processed.gpFits(ind).kGauss=kGauss;
% processed.gpFits(ind).kModel=kModel;
% processed.gpFits(ind).mseGauss=mseGauss;
% processed.gpFits(ind).mseModel=mseModel;
% processed.gpFits(ind).gaussGoodness=gaussGoodness;
% processed.gpFits(ind).modelGoodness=modelGoodness;
end

