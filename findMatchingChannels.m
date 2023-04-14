function [newTable, keepRow, keepChannel]=findMatchingChannels(dataTable, options)
arguments
    dataTable
    options.mouse cell={}
    options.genotype cell={}
    options.virus cell={}
    options.dilution cell={}
    options.LEDOff double=[]
    options.channels double=[1 2 5 6]
end

keepRow=true(size(dataTable, 1), 1);
keepChannel=true(size(dataTable, 1), length(options.channels));

if ~isempty(options.mouse)
    keepRow=keepRow & selectBy(dataTable.Mouse, options.mouse);
end

if ~isempty(options.genotype)
    keepRow=keepRow & selectBy(dataTable.Genotype, options.genotype);
end

if ~isempty(options.virus)
    selectionChannels=false(size(dataTable, 1), length(options.channels));
    for chCounter=1:length(options.channels)
        channel=options.channels(chCounter);
        selectionChannels(:,chCounter)=selectBy(dataTable{:, ['Ch' num2str(channel) 'virus']}, options.virus);
    end
    keepRow=keepRow & any(selectionChannels, 2);
    keepChannel=keepChannel & selectionChannels;
end

if ~isempty(options.dilution)
    selectionChannels=false(size(dataTable, 1), length(options.channels));
    for chCounter=1:length(options.channels)
        channel=options.channels(chCounter);
        selectionChannels(:,chCounter)=selectBy(dataTable{:, ['Ch' num2str(channel) 'dilutionNum']}, options.dilution);
    end
    keepRow=keepRow & any(selectionChannels, 2);
    keepChannel=keepChannel & selectionChannels;
end

if ~isempty(options.LEDOff)
    keepRow=keepRow & selectBy(dataTable.LEDOff, options.LEDOff);
end

keepChannel=keepChannel(keepRow,:);

newTable=dataTable(keepRow, :);
end

function keepRow=selectBy(dataColumn, valueList)
keepRow=false(length(dataColumn), 1);

if ischar(valueList)
    valueList={valueList};
end

if isnumeric(valueList)
    for counter=1:length(dataColumn)
        keepRow(counter)=any(dataColumn(counter)==valueList);
    end
elseif iscell(valueList) || isstring(valueList)
    for counter=1:length(dataColumn)
        keepRow(counter)=ismember(lower(char(dataColumn(counter))), lower(valueList));
    end
end
end


