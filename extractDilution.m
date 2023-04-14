function dilution = extractDilution(dilutionString)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    if ischar(dilutionString)
        dilution=extractOne(dilutionString);
    elseif iscell(dilutionString) || isstring(dilutionString)
        dilution=zeros(length(dilutionString),1);
        for counter=1:length(dilutionString)
            dilution(counter)=extractOne(dilutionString{counter});
        end
    else
        disp('unknown type');
    end
end
    
    
    
function dilution=extractOne(dilutionString)
    ff=strfind(dilutionString, ':');
    if ~isempty(ff)
        ff=ff(1);
        dilution=str2double(dilutionString(ff(1)+1:end));
    else
        dilution=NaN;
    end
end

