
temp_virusInd=find(strcmp(virusCodes(:,1), virusToFind));
if ~isempty(temp_virusInd)
    virusName=virusCodes{temp_virusInd(1), 2};
else
    virusName='';
end    