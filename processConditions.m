%% given a list of alignments (alignmentCodeList) and conditions (conditionsList)
% this runs through all the combinations and processes the signals as well
% as the behavioral data.  Calculates means and variances along the way.

    %% save the trials and event times for each condition and type of alignment

    if exist('useOldEvents', 'var') && useOldEvents==true
        disp('   using old alignment')
    end    

    for alignmentIndex=1:length(alignmentCodeList)
        alignmentCode=alignmentCodeList{alignmentIndex};

        eventIndices=processed.trialTable.(aligmentColumn{alignmentIndex});
        if  ~isfield(processed, 'ph')|| ~isfield(processed.ph, alignmentCode)
            processed.ph.(alignmentCode)=struct;
        end

        for cond=conditionsList
            condCode=cond{1};
            if ~exist('useOldEvents', 'var') || useOldEvents==false
                trialIds=eval(condCode);

                finalEventIndices=eventIndices(trialIds);
                finalEventIndices=finalEventIndices(finalEventIndices>0); % get rid of 0 times, like when there is not lick

                processed.ph.(alignmentCode).(condCode).trialIndices=trialIds;
                processed.ph.(alignmentCode).(condCode).eventIndices=finalEventIndices;
            end
        end
    end

    %% extract the fluorescence and calcualate means, std, z-scores
    for alignmentEntry=alignmentCodeList
        alignmentCode=alignmentEntry{1};

        for cond=conditionsList
            condCode=cond{1};

            trialIds=processed.ph.(alignmentCode).(condCode).trialIndices;
            finalEventIndices=processed.ph.(alignmentCode).(condCode).eventIndices;

            processed.ph.(alignmentCode).(condCode).photometry_mean={};
            processed.ph.(alignmentCode).(condCode).photometry_std={};
            processed.ph.(alignmentCode).(condCode).photometry_var={};
            processed.ph.(alignmentCode).(condCode).photometry_z={};

            % run through the flourescence data
            for counter=1:length(processed.signals)
                if ~isempty(processed.signals{counter})
                    params.notes=statusUpdate(params.notes, ...
                        ['Running ' num2str(length(finalEventIndices)) ' trials on channel ' num2str(counter) ' condition ' condCode ' aligned to ' alignmentCode ]);

                    [mReturn, returnError]=...
                        extractMatrix(processed.signals{counter}, finalEventIndices, params.ptsKeep_before, params.ptsKeep_after);

                    params.notes=statusUpdate(params.notes, ...
                        returnError);

                    if ~isempty(mReturn)
                        processed.ph.(alignmentCode).(condCode).photometry_mean{counter}=mean(mReturn, 1);
                        processed.ph.(alignmentCode).(condCode).photometry_std{counter}=std(mReturn, 1);
                        processed.ph.(alignmentCode).(condCode).photometry_var{counter}=var(mReturn, 1);
                        processed.ph.(alignmentCode).(condCode).photometry_z{counter}=...
                            processed.ph.(alignmentCode).(condCode).photometry_mean{counter}./ ...
                            processed.ph.(alignmentCode).(condCode).photometry_std{counter};
                    end
                end
            end
        end
    end

    %% run through the behavior data.  Keep only the means and std
    totalPointsToKeep=params.ptsKeep_after+params.ptsKeep_before+1;
    
    for alignmentEntry=alignmentCodeList
        alignmentCode=alignmentEntry{1};

        for cond=conditionsList
            condCode=cond{1};

            trialIds=processed.ph.(alignmentCode).(condCode).trialIndices;
            finalEventIndices=processed.ph.(alignmentCode).(condCode).eventIndices;

            for behaviorCodes={'downSampled', 'risingEdge', 'fallingEdge', 'occupance'}
                behaviorCode=behaviorCodes{1};
                processed.ph.(alignmentCode).(condCode).([behaviorCode '_mean'])=zeros(params.behaviorRangeN, totalPointsToKeep);
                processed.ph.(alignmentCode).(condCode).([behaviorCode '_std'])=zeros(params.behaviorRangeN, totalPointsToKeep);
                processed.ph.(alignmentCode).(condCode).([behaviorCode '_var'])=zeros(params.behaviorRangeN, totalPointsToKeep);

                params.notes=statusUpdate(params.notes, ...
                    ['Running behavior ' behaviorCode ' condition ' condCode ' aligned to ' alignmentCode]);

                for counter=1:params.behaviorRangeN
                    [mReturn, returnError]=...
                        extractMatrix(processed.behavior.(behaviorCode)(counter,:), finalEventIndices, params.ptsKeep_before, params.ptsKeep_after);
                    params.notes=statusUpdate(params.notes, ...
                        returnError);

                    if ~isempty(mReturn)
                        processed.ph.(alignmentCode).(condCode).([behaviorCode '_mean'])(counter, :)=mean(mReturn, 1);
                        processed.ph.(alignmentCode).(condCode).([behaviorCode '_std'])(counter, :)=std(mReturn, 1);
                        processed.ph.(alignmentCode).(condCode).([behaviorCode '_var'])(counter, :)=var(mReturn, 1);
                    end
                end
            end
        end
    end