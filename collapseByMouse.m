
%%
% Get the conditions and alignments to calculate and store
conditionsList={'RR', 'RNR', 'LR', 'LNR', 'R', 'L', 'Rew', 'NoRew', 'Hi', 'Low', 'Hi_NoRew', 'Low_NoRew', 'Hi_Rew', 'Low_Rew'};
conditionsList={'Rew', 'NoRew', 'Hi_NoRew', 'Low_NoRew', 'Hi_Rew', 'Low_Rew'};

alignmentCodeList={'SI', 'SO', 'CI', 'CO', 'FL'};
aligmentColumn={ ...
    'photometrySideInIndex', ...
    'photometrySideOutIndex', ...
    'photometryCenterInIndex', ...
    'photometryCenterOutIndex', ...
    'photometryFirstLickIndex' ...
    };

%% set up one of the following two lines to find the sessions to process
%D=dir('processed_WT6*'); % to get from disk
D=who('processed_*')'; % search in memory

output=zeros(4, length(D));

dU=unique(cellfun(@(x) betweenDashes(x), D,  'UniformOutput', false));

usePresets=true;

%% Loop through all the files
for dfCounter=1:length(dU)

    mName=dU{dfCounter};
    if ~isempty(mName)
        extraSavePrefix=[mName '_'];
        varSearchList={{[mName '*']}};
        sumAll;
    end
end
   
