close all

ind=1;
dData=processed_WT63_11082021.signals{ind};

disp('DATA MOMENTS')
disp(processed_WT63_11082021.signalMoments);

L=1000;

nBins=floor(length(dData)/L);
outputData=zeros(5, nBins);
outputModel=outputData;

ccAll=xcorr(dData, L-1, 'normalized');
figure
hold on

cmv=zeros(L,L);

for pCounter=0:(floor(length(dData)/L)-1)

    sigData=normalize(...
        processed_WT63_11082021.signals{ind}...
        ((pCounter*L)+(1:L)));
    plot(sigData)

    cc=xcorr(sigData, 'normalize');

    midN=L+1;
    lengthCC=length(cc);
% 
%     for counter=1:L
%         cmv(counter,:)=cc(mod(L-counter+(1:L)-1, lengthCC)+1);
%     end
    cmv=cc(cmvIndex);
%    isequal(cmv, cmv')

    disp('calculating model')
    R=normalize(mvnrnd(zeros(1,L), cmv));

    ccR=xcorr(R, 'normalized');

    outputData(1:4, pCounter+1)=[mean(sigData) var(sigData) skewness(sigData,0) kurtosis(sigData,0)]';
    outputData(5, pCounter+1)=sum(ccAll.*cc);
    outputModel(1:4, pCounter+1)=[mean(R) var(R) skewness(R,0) kurtosis(R,0)]';
    outputModel(5, pCounter+1)=sum(ccAll.*ccR);
end


