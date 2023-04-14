%% calculate errors for the sumIn channels

%p1Names={'photometry_mean', 'photometry_var', 'xc_signal', 'xc_noise', 'xc2_noise' 'risingEdge_mean', 'fallingEdge_mean', 'occupance_mean'};
conditionsList={'Rew', 'NoRew'};

for alignmentEntry=alignmentCodeList
    alignmentCode=alignmentEntry{1};

    for fIndex=1:length(p1Names)
        fName=p1Names{fIndex};

        for condCodeEntry=conditionsList
            condCode=condCodeEntry{1};
            saveCode=[extraSavePrefix condCodeEntry{1}];

            comps=processed_sum.ph.(alignmentCode).(saveCode).components{outputChannel};
            compChannels=processed_sum.ph.(alignmentCode).(saveCode).components_chan{outputChannel};
            for anaCounter=1:length(comps)
                anaName=comps{anaCounter};
                pName=[anaName '.ph.' alignmentCode '.' condCode ];
                pEval=eval(pName);

                signalChannel=compChannels(anaCounter);
                if isfield(processed_sum.ph.(alignmentCode).(saveCode), fName) && isfield(pEval, fName)
                    if isnumeric(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                        if anaCounter==1
                            processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var'])=...
                                (pEval.(fName)-processed_sum.ph.(alignmentCode).(saveCode).(fName)).^2;
                  %          processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])= 1;

                        else
                            processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var'])=...
                                processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']) ...
                                + (pEval.(fName)-processed_sum.ph.(alignmentCode).(saveCode).(fName)).^2;
                  %          processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])= ...
                  %              processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])+1;
                        end
                    elseif iscell(processed_sum.ph.(alignmentCode).(saveCode).(fName)) && ~isempty(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                        if size(processed_sum.ph.(alignmentCode).(saveCode).(fName),1)==1 % 1D
                            c1o=1;
                            c2o=outputChannel;
                            c1s=1;
                            c2s=signalChannel;
                        else
                            c1o=outputChannel;
                            c2o=outputChannel;
                            c1s=signalChannel;
                            c2s=signalChannel;
                        end
                        if all(size(pEval.(fName))>=[c1s c2s]) && ~isempty(pEval.(fName){c1s, c2s})
                            if ~isempty(processed_sum.ph.(alignmentCode).(saveCode).(fName){c1o, c2o})
                                if anaCounter==1
                                    processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){c1o,c2o}=...
                                        (pEval.(fName){c1s, c2s}-processed_sum.ph.(alignmentCode).(saveCode).(fName){c1o,c2o}).^2;
                      %              processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])(c1o,c2o)=1;
                                else
                                    processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){c1o,c2o}=...
                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){c1o,c2o} ...
                                        +(pEval.(fName){c1s, c2s}-processed_sum.ph.(alignmentCode).(saveCode).(fName){c1o,c2o}).^2;
                       %             processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])(c1o,c1o)=...
                        %                processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])(c1o,c2o)+1;
                                end
                            end
                        end
                    end
                end
            end

            %%
            %% Normalize the summed Var, calulate, the STD and Hi, Low bounds

            if isfield(processed_sum.ph.(alignmentCode).(saveCode), [fName '_sa_var']) && ...
                    ~isempty(processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']))
                if isnumeric(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                    nComponents=processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n']);
                    processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var'])= ...
                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']) ...
                        /nComponents;
                    processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_std'])= ...
                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']).^0.5;
                    processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_hi_sem'])= ...
                        processed_sum.ph.(alignmentCode).(saveCode).(fName)...
                        + processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_std'])./ ...
                        sqrt(nComponents);
                    processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_low_sem'])= ...
                        processed_sum.ph.(alignmentCode).(saveCode).(fName) ...
                        - processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_std'])./ ...
                        sqrt(nComponents);
                elseif iscell(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                    if size(processed_sum.ph.(alignmentCode).(saveCode).(fName),1)==1 % 1D
                        c1o=1;
                        c2o=outputChannel;
                    else
                        c1o=outputChannel;
                        c2o=outputChannel;
                    end

                    if ~isempty(processed_sum.ph.(alignmentCode).(saveCode).(fName){c1o, c2o}) ...
                            && all(size(processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']))>=[c1o c2o]) ...
                            && ~isempty(processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){c1o,c2o})
                        nComponents=processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])(c1o,c2o);

                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){c1o,c2o}= ...
                            (processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){c1o,c2o}) ...
                            /nComponents;
                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_std']){c1o,c2o}= ...
                            (processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){c1o,c2o}).^0.5;
                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_hi_sem']){c1o,c2o}= ...
                            processed_sum.ph.(alignmentCode).(saveCode).(fName){c1o,c2o} ...
                            + (processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_std']){c1o,c2o})./ ...
                            sqrt(nComponents);
                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_low_sem']){c1o,c2o}= ...
                            processed_sum.ph.(alignmentCode).(saveCode).(fName){c1o,c2o} ...
                            - (processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_std']){c1o,c2o})./ ...
                            sqrt(nComponents);
                    end
                end
            end
        end
    end
end


