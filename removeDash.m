function oldS=removeDash(oldS, replS, searchS)
if nargin<2
    replS=' ';
end
if nargin<3
    searchS='_';
end

findDash=strfind(oldS, searchS);
for counter=length(findDash):-1:1
    if isempty(replS)
        oldS(findDash(counter))=[];
    else
        oldS(findDash(counter))=replS;
    end
end