

%conditionList
% these should already by set:
% conditionsList={'Rew', 'NoRew', ...
% alignmentCodeList={'CI', 'CO', 'SI', 'SO', 'FL'};
% aligmentColumn={'photometryCenterInIndex', ...

% signalChannel: should already be set - from what channel to get data
% in processed
% outputChannel: into what channel to put data in processed_sum
% extraSavePrefix: what prefix to add to the conditions e.g. 'dLight'
% forceReset: do we overwrite anything in there or add on top

conditionsList={'Rew', 'NoRew'};
signalChannel=5;
outputChannel=8;
extraSavePrefix='new';
forceReset=1;

if ~exist('processed_sum', 'var')
    processed_sum=[];
end

alignmentCodeList={'SI'}; %{'CI', 'CO', 'SI', 'SO', 'FL'};
aligmentColumn={ ...
    'photometryCenterInIndex', ...
    'photometryCenterOutIndex', ...
    'photometrySideInIndex', ...
    'photometrySideOutIndex', ...
    'photometryFirstLickIndex' ...
    };

toAnalyze=who('processed_WT6*')';

for alignmentEntry=alignmentCodeList
    alignmentCode=alignmentEntry{1};

    pName=[toAnalyze{1} '.ph.' alignmentCode '.' conditionsList{1}];
    pEval=eval(pName);
    p1Names={'photometry_mean', 'photometry_var', 'xc_signal', 'xc_noise', 'xc2_noise' 'risingEdge_mean', 'fallingEdge_mean', 'occupance_mean'};

    for fIndex=1:length(p1Names)
        fName=p1Names{fIndex};
        if strcmp(fName, 'photometry_mean')
            countComponents=true;
        else
            countComponents=false;
        end

        for condCodeEntry=conditionsList
            condCode=condCodeEntry{1};
            saveCode=[extraSavePrefix condCode];

            if countComponents && forceReset
                processed_sum.ph.(alignmentCode).(saveCode)=struct;
                processed_sum.ph.(alignmentCode).(saveCode).components={};
            end

            disp(['processing ' alignmentCode ' ' condCode ' ' fName]);

            for anaCounter=1:length(toAnalyze)
                chanToGet=signalChannel;

                anaName=toAnalyze{anaCounter};

                if exist(anaName, 'var')
                    disp(['   ' anaName])
                    pName=[anaName '.ph.' alignmentCode '.' condCode];
                    pEval=eval(pName);

                    if countComponents
                        if ~isfield(processed_sum.ph, alignmentCode) || ...
                                ~isfield(processed_sum.ph.(alignmentCode), saveCode) || ...
                                ~isfield(processed_sum.ph.(alignmentCode).(saveCode), 'components') || ...
                                ~iscell(processed_sum.ph.(alignmentCode).(saveCode).components)
                            processed_sum.ph.(alignmentCode).(saveCode).components={};
                            processed_sum.ph.(alignmentCode).(saveCode).components{outputChannel}={anaName};
                            processed_sum.ph.(alignmentCode).(saveCode).components_chan={};
                            processed_sum.ph.(alignmentCode).(saveCode).components_chan{outputChannel}=chanToGet;
                        else
                            if length(processed_sum.ph.(alignmentCode).(saveCode).components)<outputChannel
                                processed_sum.ph.(alignmentCode).(saveCode).components{outputChannel}={anaName};
                                processed_sum.ph.(alignmentCode).(saveCode).components_chan{outputChannel}=chanToGet;
                            else
                                cList=processed_sum.ph.(alignmentCode).(saveCode).components{outputChannel};
                                cList{end+1}=anaName;
                                processed_sum.ph.(alignmentCode).(saveCode).components{outputChannel}=cList;
                                chArray=processed_sum.ph.(alignmentCode).(saveCode).components_chan{outputChannel};
                                chArray(end+1)=chanToGet;
                                processed_sum.ph.(alignmentCode).(saveCode).components_chan{outputChannel}=chArray;
                            end
                        end
                    end

                    if isfield(pEval, fName) && ~isempty(pEval.(fName))
                        if ~isfield(processed_sum.ph.(alignmentCode).(saveCode), fName) ...
                                || isempty(processed_sum.ph.(alignmentCode).(saveCode).(fName))
                            itsBlank=true;
                            processed_sum.ph.(alignmentCode).(saveCode).(fName)={};
                            processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])=[];
                        else
                            itsBlank=false;
                        end

                        if size(pEval.(fName), 1)==1 && ~isempty(pEval.(fName){chanToGet})% 1D thing
                            if itsBlank
                                processed_sum.ph.(alignmentCode).(saveCode).(fName){outputChannel}=...
                                    pEval.(fName){chanToGet};
                                processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])(outputChannel)=1;
                            else
                                if length(processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n']))<outputChannel
                                    nPrevious=0;
                                    processed_sum.ph.(alignmentCode).(saveCode).(fName){outputChannel}=...
                                        pEval.(fName){chanToGet};
                                else
                                    nPrevious=processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])(outputChannel);
                                    processed_sum.ph.(alignmentCode).(saveCode).(fName){outputChannel}=...
                                        (processed_sum.ph.(alignmentCode).(saveCode).(fName){outputChannel}*nPrevious ...
                                        +pEval.(fName){chanToGet})...
                                        /(nPrevious+1);
                                end
                                processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])(outputChannel)=nPrevious+1;
                            end
                        elseif size(pEval.(fName), 1)>1 % must be 2D
                            if iscell(pEval.(fName))
                                if ~isempty(pEval.(fName){chanToGet, chanToGet})
                                    if itsBlank
                                        processed_sum.ph.(alignmentCode).(saveCode).(fName){outputChannel, outputChannel}=...
                                            pEval.(fName){chanToGet, chanToGet};
                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])(outputChannel, outputChannel)=1;
                                    else
                                        if any(size(processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n']))<outputChannel)
                                            nPrevious=0;
                                            processed_sum.ph.(alignmentCode).(saveCode).(fName){outputChannel, outputChannel}=...
                                                pEval.(fName){chanToGet, chanToGet};
                                        else
                                            nPrevious=processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])(outputChannel, outputChannel);
                                            processed_sum.ph.(alignmentCode).(saveCode).(fName){outputChannel, outputChannel}=...
                                                (processed_sum.ph.(alignmentCode).(saveCode).(fName){outputChannel, outputChannel}*nPrevious ...
                                                +pEval.(fName){chanToGet, chanToGet})...
                                                /(nPrevious+1);
                                        end
                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])(outputChannel, outputChannel)=nPrevious+1;
                                    end
                                end

                            elseif isnumeric(pEval.(fName))
                                if itsBlank
                                    processed_sum.ph.(alignmentCode).(saveCode).(fName)=pEval.(fName);
                                    processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])=1;
                                else
                                    if any(size(processed_sum.ph.(alignmentCode).(saveCode).(fName)) ~= ...
                                            size(pEval.(fName))) % wrong size
                                        disp('  wrong size. skipping')
                                    else
                                        nPrevious=processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n']);
                                        processed_sum.ph.(alignmentCode).(saveCode).(fName)=...
                                            (processed_sum.ph.(alignmentCode).(saveCode).(fName)*nPrevious ...
                                            +pEval.(fName))...
                                            /(nPrevious+1);
                                        processed_sum.ph.(alignmentCode).(saveCode).([fName '_sa_n'])=nPrevious+1;
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

