for counter=1:16
    if ~isempty(processed.signals{counter})
        test=processed.signals{counter};

        mm=zeros(6, 2);

        mm(1,1)=mean(test);
        mm(2,1)=var(test);
        mm(3,1)=skewness(test);
        mm(4,1)=kurtosis(test)-3;
        mm(5,1)=skewness(test, 0);
        mm(6,1)=kurtosis(test, 0)-3;

        tNoise=normrnd(mm1, sqrt(mm2), size(test));
        mm(1,2)=mean(tNoise);
        mm(2,2)=var(tNoise);
        mm(3,2)=skewness(tNoise);
        mm(4,2)=kurtosis(tNoise)-3;
        mm(5,2)=skewness(tNoise, 0);
        mm(6,2)=kurtosis(tNoise, 0)-3;

        disp(['Channel ' num2str(counter)]);
        disp(mm);
        myFFT(test, params.finalSampleFreq); title(['Channel ' num2str(counter)]);
        myFFT(tNoise, params.finalSampleFreq); title(['Channel ' num2str(counter) ' gaussian']);
    end
end