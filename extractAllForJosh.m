
varSearchList={'sst*'};

for cIndex=1:length(varSearchList)
    toAnalyze=who(['processed_' varSearchList{cIndex}])';
    
    for anas=toAnalyze
        assignin('base', 'processed', eval(anas{1}));
        extractForJosh
    end
end