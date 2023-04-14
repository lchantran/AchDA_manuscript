function fff = rollingZ(rSignal, windowSize)
    gg_m = movmean(rSignal, windowSize);
    gg_s = movstd(rSignal, windowSize);
    fff=(rSignal-gg_m)./gg_s;

end

