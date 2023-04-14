
% Set the conditions and alignments to calculate and store
conditionsList={};

alignmentCodeList={'CI', 'CO', 'SI', 'SO', 'FL'};
aligmentColumn={ ...
    'photometryCenterInIndex', ...
    'photometryCenterOutIndex', ...
    'photometrySideInIndex', ...
    'photometrySideOutIndex', ...
    'photometryFirstLickIndex' ...
    };

% alignmentCodeList={'SI'};
% aligmentColumn={ ...
%     'photometrySideInIndex' ...
%     };

sessionsToAnalyze=who('processed_WT*')';

% how many levels to consider? 2 levels means aA, aB, Aa, etc...
levels=2;

% keepAll means to keep all levels on the way to the max vs. only the last
% level
keepAll=true;

% separate into R and L
keepRL=true;

for session=sessionsToAnalyze
    disp(['Processing ' session{1}]);

    assignin('base', 'processed', eval(session{1}));

    % add trials since last switch and until next switch to the trial Table
    nTrials=size(processed.trialTable, 1);

    lastSwitch=0;
    lastSwitchBackwards=1e6;
    processed.trialTable.trialsSinceSwitch=0*(1:nTrials)';
    processed.trialTable.trialsToSwitch=0*(1:nTrials)';
    processed.trialTable.wordLabel(1:nTrials)=repmat("", nTrials, 1);
    lastLeftProb=-1;
    lastLeftProbBackwards=processed.trialTable.leftRewardProb(nTrials);

    for trialCounter=1:nTrials
        if lastLeftProb~=processed.trialTable.leftRewardProb(trialCounter) % a switch
            lastSwitch=trialCounter;
            lastLeftProb=processed.trialTable.leftRewardProb(trialCounter);
        end
        processed.trialTable.trialsSinceSwitch(trialCounter)=trialCounter-lastSwitch;

        backTrial=nTrials+1-trialCounter;
        if lastLeftProbBackwards~=processed.trialTable.leftRewardProb(backTrial) % a switch
            lastSwitchBackwards=backTrial;
            lastLeftProbBackwards=processed.trialTable.leftRewardProb(backTrial);
        end
        processed.trialTable.trialsToSwitch(backTrial)=lastSwitchBackwards-backTrial;      

        if trialCounter>=levels
            initialTrial=trialCounter-levels+1;
            if processed.trialTable.wasRewarded(initialTrial) % was the first one rewarded
                actionWord='A';
            else
                actionWord='a';
            end

            for actionCounter=2:levels
                actionTrial=trialCounter-levels+actionCounter;
                if processed.trialTable.choseLeft(actionTrial)==processed.trialTable.choseLeft(initialTrial)  ...% same direction
                    && processed.trialTable.choseRight(actionTrial)==processed.trialTable.choseRight(initialTrial) % double check to be sure
                    if processed.trialTable.wasRewarded(actionTrial)
                        actionWord=[actionWord 'A'];
                    else
                        actionWord=[actionWord 'a'];
                    end
                else
                    if processed.trialTable.wasRewarded(actionTrial)
                        actionWord=[actionWord 'B'];
                    else
                        actionWord=[actionWord 'b'];
                    end
                end
            end
            processed.trialTable.wordLabel(trialCounter)=actionWord;
        end
    end

    if max(processed.trialTable.leftRewardProb)>0.9 %==1 % skip
        disp('   skipping reward probability >0.9 session')
        eval(['clear '  session{1}]);
    else
        params=processed.params;
%         params.ptsKeep_before=40;
%         params.ptsKeep_after=60;

        imTimes=params.finalTimeStep*(-params.ptsKeep_before:params.ptsKeep_after);
        totalPointsToKeep=params.ptsKeep_before+params.ptsKeep_after+1;

        minPtsOffset=params.signalDetrendWindow/2;
        finalSamples=max(params.final_samples);

        hasP=find(...
            processed.trialTable.isPhotometryTrial ...
            & (processed.trialTable.photometryCenterInIndex>(params.ptsKeep_before+minPtsOffset)) ...
            & (processed.trialTable.photometrySideOutIndex<(finalSamples-params.ptsKeep_after))...
            );

%         trialBounds=find(processed.trialTable.trialsSinceSwitch>=10);
%         hasP=intersect(hasP, trialBounds);

        lastWords={};
        lastTrials={};
        words={};
        wordTrials={};

        % put this back in to work on the derivatives - a hack 
%       processed.signals{1}=diff(processed.signals{1});

        % put this back in to deconvolve with decaying exp - a hack 
%         f1=fft(processed.signals{1});
%         kPoints=3;
%         ss=exp(-((1:length(processed.signals{1}))-1)/kPoints);
%         f2=fft(ss);
%         f3=f1./f2;
%         processed.signals{1}=normalize(ifft(f3));

        for level=1:levels
            level_Rew=intersect(find(processed.trialTable.wasRewarded(level:end)==1), hasP);
            level_NoRew=intersect(find(processed.trialTable.wasRewarded(level:end)==0), hasP);
            level_R=find(processed.trialTable.choseRight(level:end)==1);
            level_L=find(processed.trialTable.choseLeft(level:end)==1);

            newWords=cell(1, max(1, 4*length(words)));
            newTrials=cell(1, max(1, 4*length(words)));
            for wordCounter=1:max(1, length(words))
                if isempty(words)
                    word=[];
                    trials=1:length(processed.trialTable.wasRewarded)';
                else
                    word=words{wordCounter};
                    trials=wordTrials{wordCounter};
                end
                wordOffset=(wordCounter-1)*4;
                newWords{wordOffset+1}=[word 'r'];
                newTrials{wordOffset+1}=intersect(trials, intersect(level_R, level_NoRew));
                newWords{wordOffset+2}=[word 'R'];
                newTrials{wordOffset+2}=intersect(trials, intersect(intersect(trials, level_R), level_Rew));
                newWords{wordOffset+3}=[word 'l'];
                newTrials{wordOffset+3}=intersect(trials, intersect(intersect(trials, level_L), level_NoRew));
                newWords{wordOffset+4}=[word 'L'];
                newTrials{wordOffset+4}=intersect(trials, intersect(intersect(trials, level_L), level_Rew));
            end
            lastTrials=newTrials;
            lastWords=newWords;
            if keepAll
                words=[words newWords];
                wordTrials=[wordTrials newTrials];
            else
                words=newWords;
                wordTrials=newTrials;
            end
        end

        doneGenericWords={};
        for wordCounter=1:length(words)
            processWord=words{wordCounter};
            [flipWord, genericWord]=flipCeliaWord(processWord);
            disp(['DOING ' processWord ' and collapsing with ' flipWord ' to ' genericWord]);

            if isempty(find(strcmp(doneGenericWords, genericWord), 1)) % we haven't done this one
                doneGenericWords{end+1}=genericWord;
                flipIndex=find(strcmp(words, flipWord));
                if isempty(flipIndex) % there is no match.  huh?
                    error([flipWord ' match for ' processWord ' was not found'])
                else
                    trials=union(wordTrials{wordCounter}, wordTrials{flipIndex});
                end

                level=length(processWord);
                level_switch_r=find(processed.trialTable.choseRight(level:end-1)==1 & processed.trialTable.choseLeft((level+1):end)==1);
                level_switch_l=find(processed.trialTable.choseLeft(level:end-1)==1 & processed.trialTable.choseRight((level+1):end)==1);
                level_switch=union(level_switch_l, level_switch_r);

                level_noswitch_r=find(processed.trialTable.choseRight(level:end-1)==1 & processed.trialTable.choseRight((level+1):end)==1);
                level_noswitch_l=find(processed.trialTable.choseLeft(level:end-1)==1 & processed.trialTable.choseLeft((level+1):end)==1);
                level_noswitch=union(level_noswitch_l, level_noswitch_r);

                trials_switch=intersect(level_switch, trials);
                trials_noswitch=intersect(level_noswitch, trials);

                assignin('base', ['w_' genericWord], trials+level-1);
                assignin('base', ['w_' genericWord '_Sw'], trials_switch+level-1);
                assignin('base', ['w_' genericWord '_NoSw'], trials_noswitch+level-1);
                conditionsList={['w_' genericWord], ['w_' genericWord '_Sw'], ['w_' genericWord '_NoSw']};

                if keepRL
                    assignin('base', ['w_' processWord], wordTrials{wordCounter}+level-1);
                    assignin('base', ['w_' flipWord], wordTrials{flipIndex}+level-1);
                    conditionsList=[conditionsList {['w_' processWord] ['w_' flipWord]}];
                end

                processConditions;
                assignin('base', session{1}, processed);

                %             assignin('base', session{1}, processed);
                %             pGraph(processed.ph.SI, conditionsList, [6]);
                %             title(removeDash(session{1}))
                %             drawnow
            end

        end
        params=processed.params;
        mouse=params.mouse;
        date=params.date;
  %      anaCrossCor
        assignin('base', session{1}, processed);
    end
end



