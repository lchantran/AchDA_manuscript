%%
%close all
%clear all

resaveAfterAnalysis=false; % do you want to resave the data to disk after doing the analysis?

doPlot=true; % 0 plot nothing, 1 plot basics, 2 plot everything

% saveFolder='/Volumes/BS Office/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';

%saveFolder='/Users/bernardosabatini/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';

%cd(saveFolder)

%%
% Get the conditions and alignments to calculate and store
conditionsList={'RR', 'RNR', 'LR', 'LNR', 'R', 'L', 'Rew', 'NoRew', 'Hi', 'Low', 'Hi_NoRew', 'Low_NoRew', 'Hi_Rew', 'Low_Rew'};

alignmentCodeList={'SI', 'SO', 'CI', 'CO', 'FL'};
aligmentColumn={ ...
    'photometrySideInIndex', ...
    'photometrySideOutIndex', ...
    'photometryCenterInIndex', ...
    'photometryCenterOutIndex', ...
    'photometryFirstLickIndex' ...
    };

alignmentCodeList={'SI'};
aligmentColumn={ ...
    'photometrySideInIndex' ...
    };

%% set up one of the following two lines to find the sessions to process
D=dir('processed_WT21_03102020*'); % to get from disk
% D=who('processed_sum')'; % search in memory

%% Loop through all the files
for dfCounter=1:length(D)
    if isstruct(D(dfCounter)) && isfield(D(dfCounter), 'name')
        fileName=D(dfCounter).name;

        disp(['Working on ' fileName]);
        disp('RELOADING')
        temp= load(fileName);
        ff=fieldnames(temp);
        processed=temp.(ff{1});
        clear temp
    elseif iscell(D)
        fileName=D{dfCounter};
        disp(['Working on ' fileName]);
        assignin('base', 'processed', eval(fileName));
    end

    params=processed.params;
    processed.signals=processed.signals_raw;
    
    mouse=params.mouse;
    date=params.date;

    if contains({'S766'}, mouse) % switch left and right for this one
        processed.signals{1}=processed.signals_raw{5};
        processed.signals{5}=processed.signals_raw{1};
        processed.signals{2}=processed.signals_raw{6};
        processed.signals{6}=processed.signals_raw{2};
    end

    conditionsList=fieldnames(processed.ph.SI)';
    conditionsList={'Rew', 'NoRew'};

    useOldEvents=true;

    processConditions_new;

    chanList=[1 2 5 6];
    
    for condCounter=1:length(conditionsList)
    
        cond=conditionsList{condCounter};
        for chan=chanList
            if ~isempty(processed.ph.SI.(cond).photometry_mean{chan})
                mm=mean(processed.ph.SI.(cond).photometry_mean{chan}(1:params.ptsKeep_before));
                disp(['   ' fileName ' ' cond ' chan' num2str(chan) ' F0: ' num2str(mm)]);
                processed.ph.SI.(cond).photometry_mean{chan}=processed.ph.SI.(cond).photometry_mean{chan}/mm;
                processed.ph.SI.(cond).photometry_std{chan}=processed.ph.SI.(cond).photometry_std{chan}/mm;
            end
         end
    end

    pGraphSummary(processed.ph.SI, {'Rew', 'NoRew'}, [1 5 2 6],  tRange=[-41 0.054])    
    set(gcf, 'NumberTitle', 'off', 'Name', mouse);

%     %% resave the file, if desired
    processed.params=params;
    assignin('base', ['processed_'  mouse '_' date], processed);
    if resaveAfterAnalysis
        save(fileName, ['processed_'  mouse '_' date])
    end
    
    %% clear out memory
%   eval(['clear processed_'  mouse '_' date]);
%   clear processed
%   clear params
end
