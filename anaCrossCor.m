%% get data and set variables

useCurrent=1;
doPlot=0;

% these are the pairs of photometry channels to analyze
indexPairs=[[1 6]' [5 1]' [5 6]']; %[[1 2]' [5 6]' [1 5]' [2 6]' [1 6]' [5 2]'];

chansToAnalyze=sort(unique(indexPairs))';
maxChan=max(chansToAnalyze);

if ~useCurrent
    doPlot=1;
    
    mouse='WT63';
    date='11082021';
    
    loadPath='/Volumes/BS Office/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';
    saveFolder='/Volumes/BS Office/Dropbox (HMS)/2ABT_data_bernardo/new_analysis/';
    
    loadFile=fullfile(loadPath, ['processed_' mouse '_' date], '.mat');
    
    disp('*** Loading data')
    
    load(loadFile);
else
    loadFile='';
    mouse=processed.params.mouse;
    date=processed.params.date;
end

%% analysis fields to store

% keepFields={'mouse', 'date',  ...
%     'loadFile', ...
%     'm1Index', 'm1Name', ...
%     'm2Index', 'm2Name', ...
%     'xc_simple_lags', 'xc_simple', 'm1_ac_simple', 'm2_ac_simple',...
%     'xc_trial_lags', 'xc_trial', 'm1_ac_trial', 'm2_ac_trial',...
%     'xcv_norm_pp', 'm1_norm_acv_pp', 'm2_norm_acv_pp', 'xcv_norm_shuffle_pp' ...
%     };

%% Run the loop

expName=[mouse ' ' date];
pNotes={};
tic
%% the conditions to run through
for condEntry={'Hi_NoRew', 'Low_NoRew', 'Hi_Rew', 'Low_Rew'},;% conditionsList %{'RR', 'LR', 'RNR', 'LNR', 'R', 'L', 'Rew', 'NoRew', 'Hi', 'Low', 'Hi_NoRew', 'Low_NoRew', 'Hi_Rew', 'Low_Rew'} %{'CSdT_q1','CSdT_q2', 'CSdT_q3' } %expandWords({'a', 'A'}, prefix='w_'); %
    condCode=condEntry{1};
    
    %% the behavioral events to align the data
    %   based on on the condition and alighment, we look for the data in
    %   processed.signals{channel} and the trial alignment times in
    %   processed.ph.(alignmentCode).(condCode).trialIds and
    %   processed.ph.(alignmentCode).(condCode).eventIndices
    %   extractMatrix is used to pull out the data around the events and
    %   format as 2D
    %   Results are stored in
    %   processed.ph.(alignmentCode).(condCode).XXX with
    %   ac_signal{channel} - the simple auto correlation
    %   ac_noise{channel} - the 2d auto correlation of residuals
    %   xc_signal{ch1, ch2} - simple cross correl Ch1 to Ch2
    %   xc_noise{ch1, ch2} - 2D cross correl of residuals
    
    
%    for alignmentEntry=alignmentCodeList(1) %{'SI'} %{'CI', 'CO', 'SI', 'SO', 'FL'}
    for alignmentEntry={'SI'} %{'CI', 'SI', 'SO', 'FL'} %alignmentCodeList 
        alignmentCode=alignmentEntry{1};
        
        trialIds=processed.ph.(alignmentCode).(condCode).trialIndices;
        finalEventIndices=processed.ph.(alignmentCode).(condCode).eventIndices;
        
        processed.ph.(alignmentCode).(condCode).xc_signal=cell(maxChan, maxChan);
        processed.ph.(alignmentCode).(condCode).xc_noise=cell(maxChan, maxChan);
        processed.ph.(alignmentCode).(condCode).xc2_noise=cell(maxChan, maxChan);
        processed.ph.(alignmentCode).(condCode).xc_lags=[];
        
        m_matrix=cell(1, maxChan);
        m_linear_norm=cell(1, maxChan);
        m_matrix_noise=cell(1, maxChan);
        m_linear_noise=cell(1, maxChan);       
        
        if isempty(trialIds) || isempty(finalEventIndices)
            pNotes=statusUpdate(pNotes, ...
                ['WARNING: Alignment missing: ' expName ' ' condCode ' ' alignmentCode ' ']);
        else
            for pChan=chansToAnalyze
                if isempty(processed.signals{pChan})
                    pNotes=statusUpdate(pNotes, ...
                        ['WARNING: Channel ' num2str(pChan) ' fluorescence signal is empty']);
                else
                    [rMatrix, returnError]=...
                        extractMatrix(processed.signals{pChan}, finalEventIndices, params.ptsKeep_before, params.ptsKeep_after);
                    
                    pNotes=statusUpdate(pNotes, ...
                        returnError);
                    m_matrix{pChan}=rMatrix;
                    
                    if ~isempty(rMatrix)
                        if isempty(processed.ph.(alignmentCode).(condCode).photometry_mean{pChan}) ...
                                || isempty(processed.ph.(alignmentCode).(condCode).photometry_std{pChan})
                            processed.ph.(alignmentCode).(condCode).photometry_mean{pChan}=mean(rMatrix, 1);
                            processed.ph.(alignmentCode).(condCode).photometry_std{pChan}=std(rMatrix, 1);
                        end
                        
                        m_linear_norm{pChan}=normalize(reshape(rMatrix', 1, numel(rMatrix)));
                        m_matrix_noise{pChan}=...
                            (rMatrix-processed.ph.(alignmentCode).(condCode).photometry_mean{pChan})...
                            ./processed.ph.(alignmentCode).(condCode).photometry_std{pChan};
                        
                        maxlag=floor(size(rMatrix, 2)/2);
                        [ac, ac_lags]=xcorr(m_linear_norm{pChan}, maxlag, 'normalize');
                        processed.ph.(alignmentCode).(condCode).xc_signal{pChan, pChan}=ac;
                        
                        if isempty(processed.ph.(alignmentCode).(condCode).xc_lags)
                            processed.ph.(alignmentCode).(condCode).xc_lags=ac_lags*processed.params.finalTimeStep;
                        end
                        
                        m_linear_noise{pChan}=reshape(m_matrix_noise{pChan}', 1, numel(m_matrix_noise{pChan}));
                        processed.ph.(alignmentCode).(condCode).xc_noise{pChan, pChan}=...
                            xcorr(m_linear_noise{pChan}, maxlag, 'normalize');
                        
                        ac=zeros(size(rMatrix, 2), size(rMatrix, 2));
                        
                        for counter1=1:size(rMatrix, 2)
                            for counter2=1:size(rMatrix, 2)
                                ac(counter1, counter2)=...
                                    mean(m_matrix_noise{pChan}(:,counter1).*m_matrix_noise{pChan}(:,counter2));
                            end
                        end
                        processed.ph.(alignmentCode).(condCode).xc2_noise{pChan, pChan}=ac;
                        
                    end
                end
            end
            
            for indexCounter=1:size(indexPairs,2)
                m1Index=indexPairs(1, indexCounter);
                m2Index=indexPairs(2, indexCounter);
                corrCode=['c_' num2str(m1Index) '_' num2str(m2Index)];
                descriptiveName=[expName ' ' alignmentCode ' ' condCode ' ' num2str(m1Index) 'x' num2str(m2Index)];
                
                pNotes=statusUpdate(pNotes, ...
                    ['Running ' descriptiveName]);
                
                if isempty(m_matrix{m1Index}) || isempty(m_matrix{m2Index}) || any(size(m_matrix{m1Index})~=size(m_matrix{m2Index}))
                    pNotes=statusUpdate(pNotes, ...
                        ['WARNING: Matrices must be full and the same size. Skipping...']);
                else
                    mSize=size(m_matrix{m1Index});
                    mNumel=numel(m_matrix{m1Index});
                    nTrials=size(m_matrix{m1Index}, 1);
                    nSamples=size(m_matrix{m1Index}, 2);
                    maxlag=floor(nSamples/2);
                    
                    %% compute signal and noise xcorr on linearized data
                    processed.ph.(alignmentCode).(condCode).xc_signal{m1Index, m2Index}=...
                        xcorr(m_linear_norm{m1Index}, m_linear_norm{m2Index}, maxlag, 'normalize');
                    processed.ph.(alignmentCode).(condCode).xc_noise{m1Index, m2Index}=...
                        xcorr(m_linear_noise{m1Index}, m_linear_noise{m2Index}, maxlag, 'normalize');
                      
                    %% Point by point covariance                  
                    xc=zeros(nSamples, nSamples);

                    for counter1=1:nSamples
                        for counter2=1:nSamples
                            xc(counter1, counter2)=...
                                mean(m_matrix_noise{m1Index}(:,counter1).*m_matrix_noise{m2Index}(:,counter2));
                        end
                    end
                    
                    processed.ph.(alignmentCode).(condCode).xc2_noise{m1Index, m2Index}=xc;
                    
                    %% calculate off diagonals in the 2D XC to see if it is stable during the trial
                    mDiag=xc;
                    sampleStep=1;
                    nLagSamples=10;
                    nSampleRange=-nLagSamples:sampleStep:nLagSamples;
                    nSamples=size(mDiag, 1);
                    
                    imm=nan(length(nSampleRange), nSamples);
                    
                    ccc=0;
                    for dSamples=nSampleRange
                        ccc=ccc+1;
                        if dSamples<0
                            minX=1;
                            maxX=nSamples+dSamples;
                            dY=-dSamples;
                        else
                            minX=dSamples+1;
                            maxX=nSamples;
                            dY=-dSamples;
                        end
                        
                        nDiagPoints=maxX-minX+1;
                        dData=zeros(1, nDiagPoints);
                        for counterX=minX:maxX
                            dData(counterX-minX+1)=mDiag(counterX+dY, counterX).*abs(mDiag(counterX+dY, counterX));
                        end
                        
                        imm(ccc, minX:maxX)=dData;
                    end
                    processed.ph.(alignmentCode).(condCode).xc2_diags{m1Index, m2Index}=imm;
                end
            end
        end
    end
end
toc
processed.crossCorNotes=pNotes;
