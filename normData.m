function inData=normData(inData, options)
arguments
    inData (1,:) double
    options.zCut double=1;
    options.cutLowToo=false;
    options.iterations double=25;
    options.rollingWindow double=0;
end

if options.rollingWindow==0
    nPoints=length(inData);
    normTemplate=normrnd(0,1, 1, 2*nPoints,1);
    
    inData=normalize(inData);
    
    if options.cutLowToo
        normTemplateCut=normTemplate(...
            normTemplate>-options.zCut & normTemplate<options.zCut...
            );
    else
        normTemplateCut=normTemplate(normTemplate<options.zCut);
    end
    
    for counter=1:options.iterations
        if options.cutLowToo
            ptsZ=sort(inData(...
                inData>-options.zCut & inData<options.zCut));
        else
            ptsZ=sort(inData(inData<options.zCut));
        end
        pts=sort(normTemplateCut(1:length(ptsZ)));
        mdl = fitlm(pts,ptsZ);
        inData=(inData-mdl.Coefficients.Estimate(1))/mdl.Coefficients.Estimate(2);
    end
else 
    nPoints=length(inData);
    normTemplate=normrnd(0,1, 1, 2*nPoints,1);
    
    inData=normalize(inData);
    
    if options.cutLowToo
        normTemplateCut=normTemplate(...
            normTemplate>-options.zCut & normTemplate<options.zCut...
            );
    else
        normTemplateCut=normTemplate(normTemplate<options.zCut);
    end
    
    for counter=1:options.iterations
        if options.cutLowToo
            ptsZ=sort(inData(...
                inData>-options.zCut & inData<options.zCut));
        else
            ptsZ=sort(inData(inData<options.zCut));
        end
        pts=sort(normTemplateCut(1:length(ptsZ)));
        mdl = fitlm(pts,ptsZ);
        inData=(inData-mdl.Coefficients.Estimate(1))/mdl.Coefficients.Estimate(2);
    end

end