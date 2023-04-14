for gCounter=1:length(groupsToAnalyze)
    if ~exist(groupsToAnalyze{gCounter}, "var")
        disp([groupsToAnalyze{gCounter} ' not found in memory'])
        if exist([groupsToAnalyze{gCounter} '.mat'], "file")
            disp('   loading from disk')
            load([groupsToAnalyze{gCounter} '.mat'])
            neededToReload=true;
        else
            error('   file not found')
        end
    end
end
