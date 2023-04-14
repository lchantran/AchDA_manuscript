

%% find the mice, to plot

dataColumns=[13:16 29:46 48:65];
avgIndices=find(contains(statsTable.mouseID, 'AVG'));

%% loop through the mice
for aIndex=avgIndices'
    indices=find(...
        statsTable.genotype==statsTable.genotype(aIndex) & ...
        statsTable.channel==statsTable.channel(aIndex) & ...
        statsTable.condition==statsTable.condition(aIndex)  ...
        );
    indices=setdiff(indices, aIndex);
    for colIndex=dataColumns
        colName=statsTable.Properties.VariableNames{colIndex};
        colVals=statsTable.(colName)(indices);
        if contains(colName, '_sd')
            vProp=sqrt(sum(colVals.^2))/(length(indices));
        else
            vProp=mean(colVals);
        end
        statsTable.(colName)(aIndex)=vProp;        
    end
end