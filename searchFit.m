
XX=-5:.2:5;
[nData, ~] = histcounts(sigData, XX, 'Normalization', 'probability');
[nGauss, ~] = histcounts(R, XX, 'Normalization', 'probability');

mseGauss=100*sum((nData-nGauss).^2);
kGauss=kurtosis(R, 0);
sGauss=skewness(R, 0);

kData=kurtosis(sigData, 0);
sData=skewness(sigData, 0);
%
slope=6;
offset=3;

searchByMSE=false;
disp('MODEL [goodness stepsize offset slope skew kurt]')

for ccc=1:3
    countWorse=0;
    gSize=0.5;
    modelGoodnessOld=1e9;
    cont=true;

    if mod(ccc,2)==1
        searchByMSE=true;
    else
        searchByMSE=false;
    end

    while cont
        rr=gSize*(rand(1,2)-0.5);
        dSlope=rr(1);
        dOffset=rr(2);

        modelData=normalize(1./(1+(R+offset+dOffset)/(slope+dSlope))-1);
        %    disp([skewness(modelData,0)-sData kurtosis(modelData,0)-kData]);
        [nModel, ~] = histcounts(modelData, XX, 'Normalization', 'probability');
        mseModel=100*sum((nData-nModel).^2);
        sModel=skewness(modelData,0);
        kModel=kurtosis(modelData,0);
        if searchByMSE
            modelGoodness=mseModel;
        else
            modelGoodness=mseModel/sum(nData.^2)/3 + 100/3*(sModel/sData-1)^2 + 100/3*((kModel)/(kData)-1)^2;
        end

        if modelGoodness<modelGoodnessOld
            slope=slope+dSlope;
            offset=offset+dOffset;
            modelGoodnessOld=modelGoodness;
            %       disp([mseModel gSize offset slope skewness(modelData,0)-sData kurtosis(modelData,0)-kData]);
            countWorse=0;
            gSize=gSize*0.95;
        else
            countWorse=countWorse+1;
            if countWorse>1000
                cont=false;
            elseif mod(countWorse, 100)==0
                gSize=gSize*1.05;
            end
            %        disp(countWorse)
        end
    end

    disp([100*sum((nData-nModel).^2) gSize offset slope skewness(modelData,0)-sData kurtosis(modelData,0)-kData]);
end
close all


ccData=xcorr(sigData, 200);
ccGauss=xcorr(R, 200);
[ccModel, lags]=xcorr(modelData, 200);

figure; hold on; legend
plot(lags, ccData, 'DisplayName', 'data', 'LineWidth', 2)
plot(lags, ccGauss, 'DisplayName', 'gaussian', 'LineWidth', 2)
plot(lags, ccModel, 'DisplayName', 'model', 'LineWidth', 2)
drawnow

figure; hold on; legend
plot(XX(1:end-1), nData, 'DisplayName', 'data', 'LineWidth', 2)
plot(XX(1:end-1), nGauss, 'DisplayName', 'gaussian', 'LineWidth', 2)
plot(XX(1:end-1), nModel, 'DisplayName', 'model', 'LineWidth', 2)
drawnow

% figure; hold on; legend
% plot(sigData, 'DisplayName', 'data')
% plot(modelData, 'DisplayName', 'model')

disp('DATA [skew kurtosis]')
disp([sData kData]);

disp('ORIGINAL GAUSSIAN FIT [mse dSkew dKurtosis]')
disp([mseGauss sGauss-sData kGauss-kData]);

sModel=skewness(modelData,0);
kModel=kurtosis(modelData,0);

disp('FINAL SKEWED FIT [mse dSkew dKurtosis]')
disp([mseModel sModel-sData kModel-kData]);

disp('FINAL [slope offset]')
disp([slope offset])

gaussGoodness=mseGauss/sum(nData.^2)/3 + 100/3*(sGauss/sData-1)^2 + 100/3*((kGauss)/(kData)-1)^2;
modelGoodness=mseModel/sum(nData.^2)/3 + 100/3*(sModel/sData-1)^2 + 100/3*((kModel)/(kData)-1)^2;
disp('MODEL GOODNESS [gauss skewed] Lower is better')
disp(fix(round([gaussGoodness modelGoodness])));


