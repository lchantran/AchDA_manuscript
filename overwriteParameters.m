if exist('overwriteParams', 'var') && ~isempty(overwriteParams)
    for temp_fNames=fieldnames(overwriteParams)
        fffName=temp_fNames{1};
        params.(fffName)=overwriteParams.(fffName);
    end
end