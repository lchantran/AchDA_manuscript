%%
%close all
%clear all

resaveAfterAnalysis=false; % do you want to resave the data to disk after doing the analysis?

doPlot=false; % 0 plot nothing, 1 plot basics, 2 plot everything

saveFolder='./'; %/Volumes/BS Office/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';

%saveFolder='/Users/bernardosabatini/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';

%cd(saveFolder)

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


% alignmentCodeList={'SI'};
% aligmentColumn={ ...
%     'photometrySideInIndex' ...
%     };

%% set up one of the following two lines to find the sessions to process
%D=dir('processed_WT6*'); % to get from disk
D=who('processed_*')'; % search in memory

output=zeros(4, length(D));

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
    
    mouse=params.mouse;
    date=params.date;

    %% Moments - calculate if they are not there

%     if ~isfield(processed, 'signalMoments')
%         disp('Calculated moments of signals')
%         for ccc=1:length(processed.signals)
%             if ~isempty(processed.signals{ccc})
%                 processed.signalMoments(ccc, 1)=mean(processed.signals{ccc});
%                 processed.signalMoments(ccc, 2)=var(processed.signals{ccc});
%                 processed.signalMoments(ccc, 3)=skewness(processed.signals{ccc}, 1);
%                 processed.signalMoments(ccc, 4)=kurtosis(processed.signals{ccc}, 1);
%                 processed.signalMoments(ccc, 5)=skewness(processed.signals{ccc}, 0); % correct bias
%                 processed.signalMoments(ccc, 6)=kurtosis(processed.signals{ccc}, 0); % correct bias
%             end
%         end
%     end

    %% DO want you want to do to each file
%    disp([fileName '    ' num2str(processed.signalMoments(1,3)) '     ' num2str(processed.signalMoments(1,4))])

    switch_trials=1+find(processed.trialTable.choseLeft(1:end-1)~=processed.trialTable.choseLeft(2:end));
    no_switch_trials=1+find(processed.trialTable.choseLeft(1:end-1)==processed.trialTable.choseLeft(2:end));
% 
%     Rtrials=find(processed.trialTable.choseRight);
%     Ltrials=find(processed.trialTable.choseLeft);
%     
%     LtoR=intersect(switch_trials, Ltrials);
%     LtoL=intersect(no_switch_trials, Ltrials);
% 
%     RtoL=intersect(switch_trials, Rtrials);
%     RtoR=intersect(no_switch_trials, Rtrials);
%     
    Sw=intersect(switch_trials, find(processed.trialTable.hasAllPhotometryData));
    NoSw=intersect(no_switch_trials, find(processed.trialTable.hasAllPhotometryData));
% 
%     WillSw=find(processed.trialTable.choseLeft(1:end-1)~=processed.trialTable.choseLeft(2:end));
%     WontSw=find(processed.trialTable.choseLeft(1:end-1)==processed.trialTable.choseLeft(2:end));
% 
%     Rew=intersect(find(processed.trialTable.wasRewarded), find(processed.trialTable.hasAllPhotometryData));
%     NoRew=intersect(find(~processed.trialTable.wasRewarded), find(processed.trialTable.hasAllPhotometryData));
% 
    FRew=intersect(1+find(processed.trialTable.wasRewarded), find(processed.trialTable.hasAllPhotometryData));
    FNoRew=intersect(1+find(~processed.trialTable.wasRewarded), find(processed.trialTable.hasAllPhotometryData));
    
    FRewSw=intersect(FRew, Sw);
    FRewNoSw=intersect(FRew, NoSw);

    FNoRewSw=intersect(FNoRew, Sw);
    FNoRewNoSw=intersect(FNoRew, NoSw);
% 
%     RewWillSw=intersect(Rew, WillSw);
%     RewWontSw=intersect(Rew, WontSw);
% 
%     NoRewWillSw=intersect(NoRew, WillSw);
%     NoRewWontSw=intersect(NoRew, WontSw);
% 
%     conditionsList={'Rew', 'NoRew', 'Sw', 'NoSw', 'FRew', 'FNoRew', ...
%         'FNoRewSw', 'FNoRewNoSw', 'FRewSw', 'FRewNoSw'...
%         'RewWillSw', 'RewWontSw', 'NoRewWillSw', 'NoRewWontSw',...
%         }; % 'LtoR', 'LtoL', 'RtoL', 'RtoR'};
All=find(processed.trialTable.hasAllPhotometryData);

conditionsList={...
        'All', 'FNoRewSw', 'FNoRewNoSw', 'FRewSw', 'FRewNoSw'...
        }; 
     processConditions;


%    extractForJosh;
    %anaCrossCor;
%     channelToAnalyze=5;
%     rRange=60:70;
%     output(1, dfCounter)=mean(processed.ph.SI.Rew.photometry_mean{channelToAnalyze}(rRange));
%     output(2, dfCounter)=mean(processed.ph.SI.Rew.photometry_mean{channelToAnalyze}(rRange)...
%         -processed.ph.SI.NoRew.photometry_mean{channelToAnalyze}(rRange));
%     output(3, dfCounter)=processed.signalMoments(channelToAnalyze, 3);
%     output(4, dfCounter)=processed.signalMoments(channelToAnalyze, 4);
    
%     x=processed.signals{5};y= processed.signals{6};
%     figure;mscohere(x,y,hamming(512),500,2048,1/0.054);
%     title([mouse '_' date])

%    modelNoise;


%    conditionsList={'All'};
%    processConditions;
% disp(size(processed.ph.SI.Hi_NoRew.xc_signal{5,6}))
% pGraphXC(processed.ph.SI, 'Hi_Rew', 5, 6)
% title(['processed_'  mouse '_' date])

    %% resave the file, if desired
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
