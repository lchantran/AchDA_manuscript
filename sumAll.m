if exist('usePresets', 'var') && usePresets
    disp('using presets')
else
    extraSavePrefix=''; % e.g. 'Jax_cre_'
    %varSearchList={{'S1542*', 'S1544*', 'S1546*', 'S1550*', 'S1552*'}}; % what subset of mice to analyze.  Leave at '' to get all the ones in memory
    %varSearchList={{'S1542*', 'S1544*', 'S1546*', 'S1550*', 'S1552*'}}; % what subset of mice to analyze.  Leave at '' to get all the ones in memory
%     varSearchList={{'S1543*', 'S1549*', 'S1551*'}}; %b2del
%     varSearchList={{'WT61*'}};
    varSearchList={{'*'}};

end

% leave it empty to run all conditions
condCodeListList={};
%condCodeListList={{'RR'}, {'LR'}, {'RNR'}, {'LNR'}, {'Rew'}, {'NoRew'}};
% condCodeListList={{'Hi_Rew'}};%;, {'Low_NoRew'}, {'Hi_NoRew'}, {'Low_Rew'}};

alignmentCodeList={'CI', 'CO', 'SI', 'SO', 'FL'};
aligmentColumn={ ...
    'photometryCenterInIndex', ...
    'photometryCenterOutIndex', ...
    'photometrySideInIndex', ...
    'photometrySideOutIndex', ...
    'photometryFirstLickIndex' ...
    };

alignmentCodeList={'SI'};
aligmentColumn={ ...
    'photometrySideInIndex', ...
    };



saveCondCodeList=condCodeListList;

for cIndex=1:length(varSearchList)
    vsl=varSearchList{cIndex};
    if ischar(vsl)
        toAnalyze=[toAnalyze who(['processed_' vsl])'];
    elseif iscell(vsl)
        toAnalyze={};
        for searchCounter=1:length(vsl)
            newVars=who(['processed_' vsl{searchCounter}])';
            toAnalyze=[toAnalyze newVars];
        end
    end

    %    disp(toAnalyze)

    if isempty(condCodeListList)
        temp_p=eval(toAnalyze{1});
        temp_p_fields=fieldnames(temp_p.ph.(alignmentCodeList{1}))';
        condCodeListList=cellfun(@(a) {a}, temp_p_fields);
        saveCondCodeList=condCodeListList;
        clear temp_p temp_p_fields
    end

    for condIndex=1:length(condCodeListList)
        condCodeList=condCodeListList{condIndex};
        if ischar(condCodeList)
            condCodeList={condCodeList};
        end

        if iscell(saveCondCodeList{condIndex})
            saveCondCode=saveCondCodeList{condIndex}{1};
        else
            saveCondCode=saveCondCodeList{condIndex};
        end

        for alignmentEntry=alignmentCodeList
            alignmentCode=alignmentEntry{1};

            %      saveCode=[removeDash(varSearchList{cIndex}, 'X', '*') ...
            %          '_' saveCondCode];
            saveCode=[extraSavePrefix saveCondCode];

            processed_sum.params=eval([toAnalyze{1} '.params']);
            processed_sum.params.mouse='SUMMED';
            pName=[toAnalyze{1} '.ph.' alignmentCode '.' condCodeList{1}];
            pEval=eval(pName);
            p1Names=fieldnames(pEval);

            processed_sum.ph.(alignmentCode).(saveCode)=struct;
            processed_sum.ph.(alignmentCode).(saveCode).components={};

            %% Averages
            for fIndex=1:length(p1Names)
                fName=p1Names{fIndex};
                if strcmp(fName, 'photometry_mean')
                    countComponents=true;
                else
                    countComponents=false;
                end
                nComponents=0;

                if ~strcmp(fName, 'trialIndices') && ~strcmp(fName, 'eventIndices')
                    for condCodeEntry=condCodeList
                        condCode=condCodeEntry{1};
                        disp(['processing ' alignmentCode ' ' condCode ' ' fName]);
                        for anas=toAnalyze
                            disp(anas{1})
%                            disp([anas{1} ' ' fName ' ' condCode ' ' num2str(nComponents)])
                            if nComponents>=0
                                anaName=anas{1};
                                pName=[anaName '.ph.' alignmentCode '.' condCode];
                                aObject=eval([anaName '.ph.' alignmentCode]);
                                %disp([anas{1} ' ' fName ' ' condCode ' ' num2str(nComponents)])


                                %%%% DO SOME PLOTS
                                if fIndex==3 && condIndex==1 && alignmentCode=="SI"
                                    pGraphSummary(aObject, {'Hi_Rew', 'Low_NoRew'}, [5 6], tRange=[-41 0.054])
                                    title(anaName)
                                    figure; plot(aObject.Hi_Rew.xc_lags, aObject.Hi_Rew.xc_signal{5,6})
                                    title(anaName)
                                    disp([anaName ' XC min ' num2str(min(aObject.Hi_Rew.xc_signal{5,6}))])
                                end
                                if isfield(aObject, condCode)
                                    pEval=eval(pName);
                                    oldParams=eval([anaName '.params']);

                                    if countComponents
                                        processed_sum.ph.(alignmentCode).(saveCode).components{end+1}=anaName;
                                    end

                                    if isfield(pEval, fName) && ~isempty(pEval.(fName))
                                        if ~isfield(processed_sum.ph.(alignmentCode).(saveCode), fName) ...
                                                || isempty(processed_sum.ph.(alignmentCode).(saveCode).(fName))

                                            processed_sum.ph.(alignmentCode).(saveCode).(fName)=pEval.(fName);

                                            if ~isempty(pEval.(fName))
                                                if isnumeric(pEval.(fName))
                                                    nComponents=1;
                                                elseif iscell(pEval.(fName))
                                                    nComponents=zeros(size(pEval.(fName)));
                                                    for counter1=1:size(pEval.(fName),1)
                                                        for counter2=1:size(pEval.(fName),2)
                                                            if ~isempty(pEval.(fName){counter1,counter2})
                                                                nComponents(counter1, counter2)=1;
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        else
                                            if isnumeric(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                                                if ~isempty(pEval.(fName))
                                                    if all(size(pEval.(fName))==size(processed_sum.ph.(alignmentCode).(saveCode).(fName)))...
                                                            processed_sum.ph.(alignmentCode).(saveCode).(fName)=...
                                                            processed_sum.ph.(alignmentCode).(saveCode).(fName) ...
                                                            + pEval.(fName);
                                                        nComponents=nComponents+1;
                                                    else
                                                        %      disp(['Cannot add ' fName ' due to different sizes. Erasing this entry... ']);
                                                        processed_sum.ph.(alignmentCode).(saveCode).(fName)=[];
                                                        nComponents=-1;
                                                    end
                                                end
                                            elseif iscell(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                                                for counter1=1:size(processed_sum.ph.(alignmentCode).(saveCode).(fName),1)
                                                    for counter2=1:size(processed_sum.ph.(alignmentCode).(saveCode).(fName),2)
                                                        if any(size(pEval.(fName))<[counter1 counter2])
                                                            pEval.(fName){counter1,counter2}=[];
                                                        end
                                                        if ~isempty(pEval.(fName){counter1,counter2})
                                                            if isempty(processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2})
                                                                processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2}=...
                                                                    pEval.(fName){counter1, counter2};
                                                                nComponents(counter1, counter2)=1;
                                                            else
                                                                minLen=min(length(processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2}), ...
                                                                    length(pEval.(fName){counter1, counter2}));
                                                                processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2}(1:minLen)=...
                                                                    processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2}(1:minLen) ...
                                                                    +pEval.(fName){counter1, counter2}(1:minLen);
                                                                nComponents(counter1, counter2)=nComponents(counter1, counter2)+1;
                                                            end

                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end %new one
                        end
                    end

                    %% divide the sum by the nComponents to get avg
                    %   setup arrays for the var and std
                    if isfield(processed_sum.ph.(alignmentCode).(saveCode), fName) && ...
                            ~isempty(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                        if isnumeric(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                            processed_sum.ph.(alignmentCode).(saveCode).(fName)=...
                                processed_sum.ph.(alignmentCode).(saveCode).(fName)...
                                /nComponents;
                            processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var'])=...
                                0*processed_sum.ph.(alignmentCode).(saveCode).(fName);
                        elseif iscell(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                            for counter1=1:size(processed_sum.ph.(alignmentCode).(saveCode).(fName),1)
                                for counter2=1:size(processed_sum.ph.(alignmentCode).(saveCode).(fName),2)
                                    if nComponents(counter1, counter2)>0
                                        processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2}=...
                                            processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2}...
                                            /nComponents(counter1,counter2);
                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){counter1,counter2}=...
                                            0*processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2};
                                    end
                                end
                            end
                        end
                    end

                    for condCodeEntry=condCodeList
                        condCode=condCodeEntry{1};

                        %          disp([alignmentCode '.' condCode]);

                        for anas=toAnalyze
                            if nComponents>=0
                                anaName=anas{1};
                                pName=[anaName '.ph.' alignmentCode '.' condCode];
                                pEval=eval(pName);

                                % disp(pName);

                                if isfield(processed_sum.ph.(alignmentCode).(saveCode), fName) ...
                                        && isfield(pEval, fName) ...
                                        && ~isempty(processed_sum.ph.(alignmentCode).(saveCode).(fName)) ...
                                        && ~isempty(pEval.(fName))
                                    if isnumeric(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var'])=...
                                            processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']) ...
                                            + (pEval.(fName)-processed_sum.ph.(alignmentCode).(saveCode).(fName)).^2;
                                    elseif iscell(processed_sum.ph.(alignmentCode).(saveCode).(fName)) && ~isempty(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                                        for counter1=1:size(processed_sum.ph.(alignmentCode).(saveCode).(fName),1)
                                            for counter2=1:size(processed_sum.ph.(alignmentCode).(saveCode).(fName),2)
                                                if all(size(pEval.(fName))>=[counter1 counter2]) && ~isempty(pEval.(fName){counter1,counter2})
                                                    if ~isempty(processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2})
                                                        minLen=min(length(processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){counter1,counter2}), ...
                                                            length(pEval.(fName){counter1, counter2}));

                                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){counter1,counter2}(1:minLen)=...
                                                            processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){counter1,counter2}(1:minLen) ...
                                                            +(pEval.(fName){counter1, counter2}(1:minLen)-processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2}(1:minLen)).^2;
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    end
                    %% Normalize the summed Var, calulate, the STD and Hi, Low bounds

                    if isfield(processed_sum.ph.(alignmentCode).(saveCode), [fName '_sa_var']) && ...
                            ~isempty(processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']))
                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])= ...
                            nComponents;
                        if isnumeric(processed_sum.ph.(alignmentCode).(saveCode).(fName))
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
                            for counter1=1:size(processed_sum.ph.(alignmentCode).(saveCode).(fName),1)
                                for counter2=1:size(processed_sum.ph.(alignmentCode).(saveCode).(fName),2)
                                    if all([counter1 counter2]<=size(processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']))) && ...
                                            ~isempty(processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){counter1,counter2})
                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){counter1,counter2}= ...
                                            (processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){counter1,counter2}) ...
                                            /nComponents(counter1, counter2);
                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_std']){counter1,counter2}= ...
                                            (processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){counter1,counter2}).^0.5;
                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_hi_sem']){counter1,counter2}= ...
                                            processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2} ...
                                            + (processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_std']){counter1,counter2})./ ...
                                            sqrt(nComponents(counter1, counter2));
                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_low_sem']){counter1,counter2}= ...
                                            processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2} ...
                                            - (processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_std']){counter1,counter2})./ ...
                                            sqrt(nComponents(counter1, counter2));
                                    end
                                end
                            end
                        end
                    end
                end % new one

            end

        end
    end
end

