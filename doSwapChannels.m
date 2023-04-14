swapChannels={[1 5], [2 6]};

swappedChannelMice={'WT60', 'WT61'}; % make the list here

mouseList='WT*';

toAnalyze=who(['processed_' mouseList])';

fieldsToProcess={...
    'photometry_mean' ...
    'photometry_std' ...
    'photometry_var' ...
    'photometry_z' ...
    'xc_signal' ...
    'xc_noise' ...
    'xc2_noise' ...
    'xc2_diags' ...
    };

for anas=toAnalyze
    anaName=anas{1};
    assignin('base', 'processed', eval(anaName));
    params=processed.params;
    mouse=params.mouse;

    if any(contains(swappedChannelMice, params.mouse))% search if it is a swapped mouse
        disp(['   Swapping ' anaName]);
        for swapCounter=1:length(swapChannels)
            chan1=swapChannels{swapCounter}(1);
            chan2=swapChannels{swapCounter}(2);

            tempChan=processed.signals{1,chan1};
            processed.signals{1,chan1}=processed.signals{1,chan2};
            processed.signals{1,chan2}=tempChan;

            if isfield(processed, 'signals_raw')
                tempChan=processed.signals_raw{1,chan1};
                processed.signals_raw{1,chan1}=processed.signals_raw{1,chan2};
                processed.signals_raw{1,chan2}=tempChan;
            end

            if isfield(processed, 'rawf0')
                tempChan=processed.rawf0{1,chan1};
                processed.rawf0{1,chan1}=processed.rawf0{1,chan2};
                processed.rawf0{1,chan2}=tempChan;
            end

            if isfield(processed, 'signalMoments')
                tempChan=processed.signalMoments(chan1,:);
                processed.signalMoments(chan1,:)=processed.signalMoments(chan2,:);
                processed.signalMoments(chan2,:)=tempChan;
            end
        end

        alignmentCodeList=fieldnames(processed.ph);

        for alignmentEntry=alignmentCodeList'
            alignmentCode=alignmentEntry{1};

            conditionsCodeList=fieldnames(processed.ph.(alignmentCode));

            for condCounter=1:length(conditionsCodeList)
                conditionCode=conditionsCodeList{condCounter};

                p1Names=intersect(...
                    fieldnames(processed.ph.(alignmentCode).(conditionCode)), ...
                    fieldsToProcess' ...
                );

                %% Averages
                for fIndex=1:length(p1Names)
                    fName=p1Names{fIndex};
             %       disp([alignmentCode '.' conditionCode '.' fName])

                    if any(contains(fieldsToProcess, fName))
                        swapObject=processed.ph.(alignmentCode).(conditionCode).(fName);
                        for swapCounter=1:length(swapChannels)
                            chan1=swapChannels{swapCounter}(1);
                            chan2=swapChannels{swapCounter}(2);
                            
                            if ~isempty(swapObject)
                                if isnumeric(swapObject)
                                    if isvector(swapObject)
                                        tempChan=swapObject(chan1);
                                        swapObject(chan1)=swapObject(chan2);
                                        swapObject(chan2)=tempChan;
                                    else
                                        disp('numeric array with >2 dimensions')
                                    end
                                elseif iscell(swapObject)
                                    if isvector(swapObject)
                                        tempChan=swapObject{chan1};
                                        swapObject{chan1}=swapObject{chan2};
                                        swapObject{chan2}=tempChan;
                                    elseif ismatrix(swapObject)
                                        if all(size(swapObject)>=max(chan1, chan2))
                                            tempChan=swapObject{chan1, chan1};
                                            swapObject{chan1, chan1}=swapObject{chan2, chan2};
                                            swapObject{chan2, chan2}=tempChan;

                                            tempChan=swapObject{chan1, chan2};
                                            swapObject{chan1, chan2}=swapObject{chan2, chan1};
                                            swapObject{chan2, chan1}=tempChan;
                                        end
                                    else
                                        disp('cell array with >2 dimensions')
                                    end
                                end

                            end
                        end

                        processed.ph.(alignmentCode).(conditionCode).(fName)=swapObject;
                    end
                end
            end
        end
        assignin('base', anaName, processed);
    end
end

