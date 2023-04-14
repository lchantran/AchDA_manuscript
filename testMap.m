function inData=normData(inData, options)
arguments
    inData (1,:) double
    options.zCut double=1;
    options.interations double=25;
end

nPoints=length(inData);
normTemplate=normrnd(0,1, 1, 2*nPoints,1);

inData=(inData-mean(inData))/std(inData);

normTemplateCut=normTemplate(normTemplate<optionszCut);

for counter=1:25
    ptsZ=sort(inData(inData<zCut));
    pts=sort(normTemplateCut(1:length(ptsZ)));
    mdl = fitlm(pts,ptsZ);
    inData=(inData-mdl.Coefficients.Estimate(1))/mdl.Coefficients.Estimate(2);
end
