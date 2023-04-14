subsetTable=table;


scaleFactor=1;

keepColumns={...
    'hasAllPhotometryData', ...
    'photometryCenterInIndex', ...
    'photometryCenterOutIndex', ...
    'photometrySideInIndex', ...
    'photometrySideOutIndex', ...
    'photometryFirstLickIndex', ...
    'choseLeft', ...
    'choseRight', ...
    'leftRewardProb', ...
    'rightRewardProb', ...
    'wasRewarded' ...
    };

nPoints=length(processed.behavior.risingEdge(1,:));

for cc=keepColumns
    subsetTable.(cc{1})=processed.trialTable.(cc{1});
end

disp([min(subsetTable.leftRewardProb) max(subsetTable.leftRewardProb)])

bTable=table;

for channel=1; %[1 2 5 6]
    if ~isempty(processed.signals{channel})
        bTable.(['Ch' num2str(channel)])=scaleFactor*double(processed.signals{channel}');
    else
        bTable.(['Ch' num2str(channel)])=zeros(nPoints,1);
    end
end

if isfield(processed, 'gpModels')
    for channel=[1 2 5 6]
        if ~isempty(processed.gpModels{channel})
            extraPoints=nPoints-length(processed.gpModels{channel});
            bTable.(['GP_' num2str(channel)])=scaleFactor*[double(processed.gpModels{channel}) zeros(1, extraPoints)]';
        else
            bTable.(['GP_' num2str(channel)])=zeros(nPoints,1);
        end
    end
end

if isfield(processed, 'gpSkewModels')
    for channel=[1 2 5 6]
        if ~isempty(processed.gpModels{channel})
            extraPoints=nPoints-length(processed.gpModels{channel});
            bTable.(['SGP_' num2str(channel)])=scaleFactor*[double(processed.gpModels{channel}) zeros(1, extraPoints)]';
        else
            bTable.(['SGP_' num2str(channel)])=zeros(nPoints,1);
        end
    end
end

bTable.centerOcc=processed.behavior.occupance(1,:)';
bTable.centerIn=processed.behavior.risingEdge(1,:)';
bTable.centerOut=processed.behavior.fallingEdge(1,:)';
bTable.centerOutToLeft=0*bTable.centerOut;
bTable.centerOutToRight=0*bTable.centerOut;

bTable.rightOcc=processed.behavior.occupance(2,:)';
bTable.rightIn=processed.behavior.risingEdge(2,:)';
bTable.rightOut=processed.behavior.fallingEdge(2,:)';
%bTable.rightLick=processed.behavior.risingEdge(5,:)';

bTable.leftOcc=processed.behavior.occupance(3,:)';
bTable.leftIn=processed.behavior.risingEdge(3,:)';
bTable.leftOut=processed.behavior.fallingEdge(3,:)';
%bTable.leftLick=processed.behavior.risingEdge(4,:)';

bTable.reward=0*processed.behavior.risingEdge(4,:)';
bTable.noreward=0*processed.behavior.risingEdge(4,:)';

subsetTable.word=strings(height(subsetTable), 1);

% was the last trial rewarded?
subsetTable.word(1+find(subsetTable.wasRewarded(1:end-1)))='A';
subsetTable.word(1+find(~subsetTable.wasRewarded(1:end-1)))='a';

% find switches
switchTrials=1+find(subsetTable.choseLeft(1:end-1)~=subsetTable.choseLeft(2:end));
noSwitchTrials=1+find(subsetTable.choseLeft(1:end-1)==subsetTable.choseLeft(2:end));

% switch trials
inds=intersect(switchTrials, find(subsetTable.wasRewarded));
subsetTable.word(inds)=subsetTable.word(inds)+'B';
inds=intersect(switchTrials, find(~subsetTable.wasRewarded));
subsetTable.word(inds)=subsetTable.word(inds)+'b';

% no switch trials
inds=intersect(noSwitchTrials, find(subsetTable.wasRewarded));
subsetTable.word(inds)=subsetTable.word(inds)+'A';
inds=intersect(noSwitchTrials, find(~subsetTable.wasRewarded));
subsetTable.word(inds)=subsetTable.word(inds)+'a';


% fix an error in the center out times
dupInd=1+find(subsetTable.photometryCenterOutIndex(1:end-1)==subsetTable.photometryCenterOutIndex(2:end));
dupInd=intersect(dupInd, find(subsetTable.photometryCenterInIndex>0));

if ~isempty(dupInd)
    subsetTable.photometryCenterOutIndex(dupInd)=subsetTable.photometryCenterInIndex(dupInd);
end

for counter=1:height(subsetTable)
    if subsetTable.photometrySideInIndex(counter)>0 ...
            && subsetTable.photometrySideOutIndex(counter)>0 ...
            && subsetTable.photometrySideOutIndex(counter)<=nPoints
        if subsetTable.choseLeft(counter)
            bTable.centerOutToLeft(...
                subsetTable.photometryCenterOutIndex(counter))=1;
        elseif subsetTable.choseRight(counter)
            bTable.centerOutToRight(...
                subsetTable.photometryCenterOutIndex(counter))=1;
        end

        if subsetTable.wasRewarded(counter)
            bTable.reward(...
                subsetTable.photometrySideInIndex(counter):...
                subsetTable.photometrySideOutIndex(counter)) ...
                =1;
            %     disp([counter 1 subsetTable.photometrySideInIndex(counter) subsetTable.photometrySideOutIndex(counter)]);
        else
            bTable.noreward(...
                subsetTable.photometrySideInIndex(counter):...
                subsetTable.photometrySideOutIndex(counter)) ...
                =1;
            %          disp([counter 0 subsetTable.photometrySideInIndex(counter) subsetTable.photometrySideOutIndex(counter)]);
        end
    end
end

bTable.noreward((bTable.leftOcc | bTable.rightOcc) & ~bTable.reward & ~bTable.noreward)=...
    1;

% find first trial with valid photometry
ff=find(subsetTable.hasAllPhotometryData);
%get rid of extradata
lastDummy=ff(1)-1;
lastPoint=subsetTable.photometryCenterInIndex(ff(1))-20;
bTable{1:lastPoint,:}=0;
subsetTable(1:lastDummy,:)=[];

% find last trial with valid photometry
ff=find(subsetTable.hasAllPhotometryData);
%get rid of extradata
firstDummy=ff(end)+1;
firstPoint=subsetTable.photometryCenterOutIndex(ff(end))+20;
bTable{firstPoint:end,:}=0;
subsetTable(firstDummy:end,:)=[];


writetable(subsetTable, ['GLM_TABLE_' processed.params.mouse '_' processed.params.date]);
writetable(bTable, ['GLM_SIGNALS_' processed.params.mouse '_' processed.params.date]);



