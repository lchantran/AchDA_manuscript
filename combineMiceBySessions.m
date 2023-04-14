%%
%close all
%clear all

resaveAfterAnalysis=false; % do you want to resave the data to disk after doing the analysis?

doPlot=false; % 0 plot nothing, 1 plot basics, 2 plot everything

saveFolder='/Volumes/BS Office/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';

%saveFolder='/Users/bernardosabatini/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';

%cd(saveFolder)


%% set up one of the following two lines to find the sessions to process
%D=dir('processed_WT6*'); % to get from disk
groupsToAnalyze=who('processed_S*')'; % search in memory

mouseIDs=unique(cellfun(@(x) betweenDashes(x), groupsToAnalyze, 'UniformOutput', false));
extraSavePrefix='';

%% Loop through all the files
for dfCounter=1:length(mouseIDs)
    mouseID=mouseIDs{dfCounter};
    if ~isempty(mouseID) && ~strcmp(mouseID, 'sum')
        varSearchList={[mouseID '*']}
    
        processed_sum=[];
        toAnalyze={};
        disp(['Combining mouse ' mouseID])
        alignmentCodeList=fieldnames(processed.ph)';
        condCodeListList=fieldnames(processed.ph.(alignmentCodeList{1}))';
        sumAll
        assignin('base', ['processed_' mouseID '_sum'], processed_sum);
        save(['processed_' mouseID '_sum.mat'], ['processed_' mouseID '_sum'])

    end
end
