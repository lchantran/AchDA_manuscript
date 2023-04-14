function processingNotes=statusUpdate(processingNotes, errorStrings, reportStatus)
    if nargin<3
        reportStatus=1;
    end
    if ~isempty(errorStrings)
        if ischar(errorStrings)
            errorStrings={errorStrings};
        end
        
        if isempty(processingNotes)
            processingNotes=errorStrings;
        else
            processingNotes=[processingNotes errorStrings];
        end
        if reportStatus
            for s=errorStrings
                disp(s{1});
            end
        end
    end
end

