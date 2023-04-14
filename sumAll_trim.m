
extraSavePrefix='FF_'; % e.g. 'Jax_cre_'
varSearchList={{'S*'}}; % what subset of mice to analyze.  Leave at '' to get all the ones in memory

condCodeListList=expandWords({'a', 'A'}, prefix='w_', postfix='_NoSw',  doubleWrap=true);
condCodeListList=expandWords({''}, prefix='w_', postfix='_NoSw',  doubleWrap=true);

% condCodeListList={{'Rew_Rew'}, {'Rew_NoRew'}, {'NoRew_Rew'}, {'NoRew_NoRew'}, {'Sw_Rew_Rew'}, {'Sw_Rew_NoRew'}, {'Sw_NoRew_Rew'}, {'Sw_NoRew_NoRew'}, ...
%     {'Rew_Rew_first'}, {'Rew_NoRew_first'}, {'NoRew_Rew_first'}, {'NoRew_NoRew_first'}, {'Sw_Rew_Rew_first'}, {'Sw_Rew_NoRew_first'}, {'Sw_NoRew_Rew_first'}, {'Sw_NoRew_NoRew_first'}, ...
%      {'Rew_Sw_first'}, {'Rew_NoSw_first'}, {'NoRew_Sw_first'}, {'NoRew_NoSw_first'}, ...
 condCodeListList={...
     {'Rew'}, {'NoRew'}, {'Hi'}, {'Low'}, {'L'}, {'R'}, {'RR'}, {'LR'}, {'RNR'}, {'LNR'}, {'Hi_Rew'}, {'Hi_NoRew'}, {'Low_Rew'}, {'Low_NoRew'}};
% 
% 
% condCodeListList=expandWords({'a', 'A'}, prefix='w_',  postfix='_Sw', doubleWrap=true);
% 
% condCodeListList={{'CSdT_q1'}, {'CSdT_q2'}, {'CSdT_q3'}, {'CSdT_q4'}, {'CSdT_q5'}, {'CSdT_q6'}, {'CSdT_q7'}, {'CSdT_q8'}, {'CSdT_q9'}, {'CSdT_q10'}, {'CSdT_q11'}, {'CSdT_q12'}}; %, {'CSdT_q3'}, {'CSdT_q4'}};
    
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
    'photometrySideInIndex'
    };


saveCondCodeList=condCodeListList;

for cIndex=1:length(varSearchList)
    vsl=varSearchList{cIndex};
    if ischar(vsl)
        toAnalyze=[toAnalyse who(['processed_' vsl])'];
    elseif iscell(vsl)
        toAnalyze={};
        for searchCounter=1:length(vsl)
            newVars=who(['processed_' vsl{searchCounter}])';
            toAnalyze=[toAnalyze newVars];
        end
    end
        
    disp(toAnalyze)
    
    for condIndex=1:length(condCodeListList)
        condCodeList=condCodeListList{condIndex};
        if ischar(condCodeList)
            condCodeList={condCodeList};
        end

        if iscell(saveCondCodeList{condIndex})
            saveCondCode=saveCondCodeList{condIndex}{1};
        else
            saveCondCode=saveCondCodeList{condIndex}(1);
        end
        
        for alignmentEntry=alignmentCodeList
            alignmentCode=alignmentEntry{1};
            
      %      saveCode=[removeDash(varSearchList{cIndex}, 'X', '*') ...
      %          '_' saveCondCode];
            saveCode=[extraSavePrefix saveCondCode];
            
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

                for condCodeEntry=condCodeList
                    condCode=condCodeEntry{1};
                    disp(['processing ' alignmentCode ' ' condCode ' ' fName]);
                    for anas=toAnalyze
                        if nComponents>=0
                            anaName=anas{1};
                            pName=[anaName '.ph.' alignmentCode '.' condCode];
                            pEval=eval(pName);
                            
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
                                                        processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2}=...
                                                            processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2} ...
                                                            +pEval.(fName){counter1, counter2};
                                                        nComponents(counter1, counter2)=nComponents(counter1, counter2)+1;
                                                    end

                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
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
                                                    processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){counter1,counter2}=...
                                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_var']){counter1,counter2} ...
                                                        +(pEval.(fName){counter1, counter2}-processed_sum.ph.(alignmentCode).(saveCode).(fName){counter1,counter2}).^2;
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
                
            end
            
        end
    end
end

