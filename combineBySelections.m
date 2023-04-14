%% load basics
saveFolder='/Volumes/BS Office/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';
%saveFolder='/Users/bernardosabatini/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';
cd(saveFolder)

load('ABT_Table.mat')  % load the animal experiment
ABT_virusCode %load the virus codes

%%  Set parameters
resaveAfterAnalysis=true;
forceReload=false;
reloadFromDisk=true;

% forceReset=true;
% outputChannel=1;
% viruses=dLightViruses;
% forceReset=false;
% outputChannel=2;
% viruses=rDAhViruses;
% forceReset=false;
% outputChannel=3;
% viruses=Ach3Viruses;
forceReset=false;
outputChannel=4;
viruses=jrCamp1bViruses;

% pick what you want to process
[keepTable, keepRow, keepChannel]=findMatchingChannels(ABTmice, genotype={'WT C57'}, virus=viruses);
% if you want to select on multiple viruses, for example, then run previous
% line again
% [keepTable, keepRow, keepChannel]=findMatchingChannels(ABTmice, mouse={'WT63'}, genotype={'WT C57'}, virus=rDAhViruses);
% and then AND the results

%% Setup up conditions and alighments

conditionsList={'RR', 'RNR', 'LR', 'LNR', 'R', 'L', 'Rew', 'NoRew', 'Hi', 'Low', 'Hi_NoRew', 'Low_NoRew', 'Hi_Rew', 'Low_Rew'};
conditionsList=expandWords({'a', 'A'}, prefix='w_',  postfix='');

alignmentCodeList={'CI', 'CO', 'SI', 'SO', 'FL'};
aligmentColumn={ ...
    'photometryCenterInIndex', ...
    'photometryCenterOutIndex', ...
    'photometrySideInIndex', ...
    'photometrySideOutIndex', ...
    'photometryFirstLickIndex' ...
    };

extraSavePrefix='pool_';


%% Run through all the mice that met criteria
toAnalyze={};
toAnalyzeChan=[];

chanDefs=[1 2 5 6];

for row=1:size(keepTable, 1)
    mouse=char(keepTable.Mouse(row));
    date=char(keepTable.Date(row));
    mouseFiles=dir(['processed_' mouse '_' date '*']); % find all the files for this mouse

    %% Loop through all the files
    for dfCounter=1:length(mouseFiles)
        fileName=mouseFiles(dfCounter).name;

        varName=fileName(1:(strfind(fileName, '.')-1));
 
        if forceReload || (~exist(varName, 'var') && reloadFromDisk)
            disp(['Loading ' varName]);
            temp=load(fileName);
            assignin('base', varName, temp.(varName));
            clear temp
        end

        if exist(varName, 'var')
            disp([varName ' is in memory'])
            chanMatch=find(keepChannel(row,:));
            for chanCounter=1:length(chanMatch)
                toAnalyze{end+1}=varName;
                toAnalyzeChan(end+1)=chanDefs(chanMatch(chanCounter));
            end
        else
            disp([varName ' is missing']);
        end
    end
end
% sumIn



