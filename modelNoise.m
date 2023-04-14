makeCmvMatrix=false;

processed.gpModels={};
processed.gpSkewModels={};

indList=[1 2 5 6];
for ind=indList
    disp(['*** Processing channel ' num2str(ind)]);
    if ~isempty(processed.signals{ind})
        maxPoints=min(20000, length(processed.signals{ind}));
        sigData=normalize(double(processed.signals{ind}(1:maxPoints)));

        L=length(sigData);
        
        maxlag=L;
%        maxlag=100;
        
        if maxlag==0
            maxlag=L;
        end

        cc=xcorr(sigData, maxlag, 'normalize');

        figure; plot(cc)

        midN=L+1;
        lengthCC=length(cc);

        if ~exist('cmvIndex', 'var') || size(cmvIndex,1)~=L
            makeCmvMatrix=true;
            disp('Forcing remaking index matrix')
        end

        if makeCmvMatrix
            disp('Making Matrix');
            cmvIndex=zeros(L,L);
            for counter=1:L
                if maxlag==L
                    cmvIndex(counter,:)=mod(L-counter+(1:L), lengthCC)+1;
                else
                    mmin=max(counter-maxlag, 1);
                    mmax=min(counter+maxlag, L);

                    rmin=max(maxlag-counter+2, 1);
                    rmax=rmin+(mmax-mmin);
                    cmvIndex(counter, mmin:mmax)=...
                        rmin:rmax;
                end
            end
        else
            disp('Using last matrix');
        end

        if maxlag==L
            cmv=cc(cmvIndex);
        else
            cmv=zeros(L,L);
            cmv(cmvIndex>0)=cc(cmvIndex(cmvIndex>0));
        end

        maxN=100;
        %figure;imagesc(cmv(1:maxN, 1:maxN));axis square

        disp('Modeling with covariance structure')
        R=normalize(mvnrnd(zeros(1,L), cmv));

        % figure; hold on
        % legend
        % plot(R, 'DisplayName', 'model');
        % plot(sigData, 'DisplayName', 'data');

        cc2=xcorr(R, maxlag, 'normalized');

        figure; hold on
        legend
        plot(cc, 'DisplayName', 'data cc')
        plot(cc2, 'DisplayName', 'model cc')
        title([fileName ' xcorr channel ' num2str(ind)]);

        myFFT(sigData, params.finalSampleFreq );
        hold on
        title([fileName ' FFT channel ' num2str(ind)])
        myFFT(R, params.finalSampleFreq, 0, gca);

        disp('DATA [mean var skew kurt]')
        disp([mean(sigData) var(sigData) skewness(sigData,0) kurtosis(sigData,0)])
        disp('GAUSSIAN MODEL [mean var skew kurt]')
        disp([mean(R) var(R) skewness(R,0) kurtosis(R,0)])

        if isfield(params, 'reducePrecision') && params.reducePrecision
            processed.gpModels{ind}=int16(100*R);
        else
            processed.gpModels{ind}=R;
        end

        searchFit

        if isfield(params, 'reducePrecision') && params.reducePrecision
            processed.gpSkewModels{ind}=int16(100*modelData);
        else
            processed.gpSkewModels{ind}=modelData;
        end
        
        if ~isfield(processed, 'gpFits')
            processed.gpFits(ind)=struct;
        end
        
        processed.gpFits(ind).sData=sData;
        processed.gpFits(ind).sGauss=sGauss;
        processed.gpFits(ind).sModel=sModel;
        processed.gpFits(ind).kData=kData;
        processed.gpFits(ind).kGauss=kGauss;
        processed.gpFits(ind).kModel=kModel;
        processed.gpFits(ind).mseGauss=mseGauss;
        processed.gpFits(ind).mseModel=mseModel;
        processed.gpFits(ind).gaussGoodness=gaussGoodness;
        processed.gpFits(ind).modelGoodness=modelGoodness;
    end
end

