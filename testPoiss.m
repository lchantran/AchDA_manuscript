keepRows=1:7;
nEventTypes=length(keepRows);
events=behEvents(1:20000,:)';
%events=[diff(behEvents(keepRows,:), 1, 2)>0 repmat(false, nEventTypes, 1)];
bins=size(events, 2);

neuronFiring=neuron_data_matrix(1:20000,:)'; %round(neuron_data_matrix*0.06/0.43);
anaNeurons=1:size(neuronFiring, 1); %206; %[32 33 148 174];
neuronFiring=neuronFiring(anaNeurons, :);

%neuronFiring(isnan(neuronFiring))=0;
nNeurons=size(neuronFiring, 1);

useAllData=true;

%% make some event types to reconstruct standard trajectories

% 1. CueStart (whether the bin contains a cue)
% 2. LickNum (whether the bin contains a lick or not)
% 3. AllTrial_FirstLick
% 4. AllTrial_LastLick
% 5. HitTrial_EnforcedLick
% 6. HitTrial_TriggerLick
% 7. HitTrial_ConsumptionLick'

nReconTrialTypes=2;
sTimePoints=10000/50; % 4s of 50 ms bins
eventTypes=zeros(nReconTrialTypes, nEventTypes, sTimePoints);

offsetI=20;

eventTypes(:, 1, offsetI+10)=1; % the cue
eventTypes(1, 2, offsetI+(13:3:46))=1; % consumption licks on reward
eventTypes(2, 2, offsetI+(13:3:28))=1; % consumption licks on no reward
eventTypes(:, 3, offsetI+13)=1; % first (enforced) lick
eventTypes(1, 4, offsetI+46)=1; % last lick on reward
eventTypes(2, 4, offsetI+28)=1; % last lick on no reward
eventTypes(:, 5, offsetI+(13:3:19))=1; % enforced licks
eventTypes(:, 2, offsetI+22)=1; % trigger lick
eventTypes(:, 6, offsetI+22)=1; % trigger lick
eventTypes(1, 7, offsetI+(25:3:46))=1; % consumption licks on reward
eventTypes(2, 7, offsetI+(25:3:28))=1; % consumption licks on no reward

nReconTraj=zeros(nReconTrialTypes, nNeurons, sTimePoints);


%% split data into test and training by taking out one large chunk for test
oneFourth=floor(bins/4);
startTest=randi([oneFourth 2*oneFourth]); % start at least 25% of the way in
endTest=startTest+2*oneFourth-1; % take some piece of the data

testEvents=events(:, startTest:endTest);
testFiring=neuronFiring(:, startTest:endTest);
testBins=size(testEvents, 2);

if ~useAllData
    disp('removing test data from trianing set')
    events(:, startTest:endTest)=[];
    neuronFiring(:, startTest:endTest)=[];
    bins=size(events, 2);
else
    disp('KEEPING test data in training set')
end

%% prepare time shift matrix of events for the glm
maxShifts=10; % how many +/- bins to consider for glm
shifts=0:maxShifts;
nShifts=length(shifts);
allEvents=zeros(nEventTypes*length(shifts), bins);
for counter=1:nShifts
    e2=circshift(events, shifts(counter), 2);
    allEvents(nShifts*((1:nEventTypes)-1)+counter, :)=e2;
end

testAllEvents=zeros(nEventTypes*length(shifts), testBins);
for counter=1:nShifts
    e2=circshift(testEvents, shifts(counter), 2);
    testAllEvents(nShifts*((1:nEventTypes)-1)+counter, :)=e2;
end

eventTypesShifts=zeros(nReconTrialTypes, nEventTypes*length(shifts), sTimePoints);
for eCounter=1:nReconTrialTypes
    rAllEvents=zeros(nEventTypes*length(shifts), sTimePoints);
    rEvents=squeeze(eventTypes(eCounter, :, :));
    for counter=1:nShifts
        e2=circshift(rEvents, shifts(counter), 2);
        rAllEvents(nShifts*((1:nEventTypes)-1)+counter, :)=e2;
    end
    eventTypesShifts(eCounter, :, :)=rAllEvents;
end

%% do glms
% we fit the spiking rate but look at the reconstruction of the
% underlying time varying rates.  I guess we really model the lambdas, but
% same thing here

modelRates=0*neuronFiring;
testModelRates=0*testFiring;

firstRun=true;

glmRuns=cell(1, nNeurons);

for neuronIndex=1:nNeurons
    disp(['fitting neuron ' num2str(neuronIndex)])
    mdl=fitglm(allEvents', neuronFiring(neuronIndex,:)', 'linear', 'Link', 'identity'); %, 'Distribution', 'poisson' );
    % You can add 'Distribution', 'poisson' but I find that I get identical
    % results and without it, it runs much faster and converges better
    % Maybe it gets the right answer with a linear link
    % because of the smearing and summing across multiple poisson
    % processes?

    glmRuns{neuronIndex}=mdl;

    % reconstruct the underlying rates, not the spiking!
    yy=predict(mdl, allEvents');
    modelRates(neuronIndex, :)=yy.*(yy>0); % contains the model output in spikes per bin for the training data
    yy=predict(mdl, testAllEvents');
    testModelRates(neuronIndex, :)=yy.*(yy>0); % same for the testing data

    if firstRun
        nCoeffs=size(mdl.Coefficients.Estimate(1:end), 1);
        glmCoeffs=zeros(nNeurons, nCoeffs);
        firstRun=false;
    end
    glmCoeffs(neuronIndex, :)=glmRuns{neuronIndex}.Coefficients.Estimate(1:end)';

    for eCounter=1:nReconTrialTypes
        nReconTraj(eCounter, neuronIndex, :)=predict(mdl, squeeze(eventTypesShifts(eCounter, :, :))');
    end
end


%% plot the glm outputs
for neuronIndex=1:nNeurons
    figure('NumberTitle','off', 'Name', ['neuron ' num2str(neuronIndex)])
    set(gcf, 'Position', [  99         549        1386         317])

    subplot(1, 4, 1)
    plot(glmRuns{neuronIndex}.Coefficients.Estimate(2:end)', 'DisplayName', 'model coeffs')
    hold on
    legend

    % reconstruct the underlying rates, not the spiking!
    yy=modelRates(neuronIndex, :);

    subplot(1, 4, 2:4)
    plot(yy, 'DisplayName','recon rate')

    legend
    title(['reconstruction ' num2str(floor(100*mean(1./(modelRates(neuronIndex, :).^0.5))))]);
end


%% plot PSTHs
beforePts=40;
afterPts=40;

for eventIndex=[4] %nEventTypes
    figure('NumberTitle','off', 'Name', ['event ' num2str(eventIndex)])
    hold on
    % set(gcf, 'Position', [  99         549        1386         317])
    nActivityAligned=extractMatrix(neuronFiring, find(events(eventIndex, :)), beforePts, afterPts);
    nPSTH=squeeze(mean(nActivityAligned, 1));
    nPSTHStd=squeeze(std(nActivityAligned, 1, 1));

    nReconRateAligned=extractMatrix(modelRates, find(events(eventIndex, :)), beforePts, afterPts);
    nReconRatePSTH=squeeze(mean(nReconRateAligned, 1));
    nReconRatePSTHStd=squeeze(std(nReconRateAligned, 1, 1));

    testActivityAligned=extractMatrix(testFiring, find(testEvents(eventIndex, :)), beforePts, afterPts);
    testPSTH=squeeze(mean(testActivityAligned, 1));
    testPSTHStd=squeeze(std(testActivityAligned, 1, 1));

    testReconRateAligned=extractMatrix(testModelRates, find(testEvents(eventIndex, :)), beforePts, afterPts);
    testReconRatePSTH=squeeze(mean(testReconRateAligned, 1));
    testReconRatePSTHStd=squeeze(std(testReconRateAligned, 1, 1));

    extraVar=(nPSTHStd.^2-nReconRatePSTHStd.^2);
    extraVar=extraVar.*(extraVar>0);
    extraStd=extraVar.^0.5;
    for nCounter=[1 7 17 29 28 32]%30+[1:10] %1:size(nPSTH, 1)
        figure('NumberTitle','off', 'Name', ['neuron ' num2str(nCounter) ' event ' num2str(eventIndex)])
        hold on
        plot(nReconRatePSTH(nCounter,:), 'DisplayName', ['recon ' num2str(nCounter)]);
        plot(testReconRatePSTH(nCounter,:), 'DisplayName', ['recon test ' num2str(nCounter)]);
        %         fillBetween(...
        %             nPSTH(nCounter,:)-extraStd(nCounter,:), ...
        %             nPSTH(nCounter,:)+extraStd(nCounter,:));
        plot(nPSTH(nCounter,:), 'DisplayName', num2str(nCounter), 'LineWidth', 2);
        plot(testPSTH(nCounter,:), 'DisplayName', ['test ' num2str(nCounter)], 'LineWidth', 2);
        legend
    end
end

%% estimate probability of spike train given reconstruction of rate
probFiring=poisspdf(neuronFiring, modelRates);
testProbFiring=poisspdf(testFiring, testModelRates);

% make PSTHs of probability of firing from the model rates
beforePts=10;
afterPts=20;
for eventIndex=1:nEventTypes
    figure('NumberTitle','off', 'Name', ['P(f) event ' num2str(eventIndex)])
    % set(gcf, 'Position', [  99         549        1386         317])
    nActivityAligned=extractMatrix(probFiring, find(events(eventIndex, :)), beforePts, afterPts);
    nPSTH=squeeze(mean(nActivityAligned, 1));
    plot(nPSTH')
    hold on
    testActivityAligned=extractMatrix(testProbFiring, find(testEvents(eventIndex, :)), beforePts, afterPts);
    testPSTH=squeeze(mean(testActivityAligned, 1));    
    plot(testPSTH', 'LineStyle', '--')
    legend
end


%%

nTraj=zeros(size(eventTypes,1), nNeurons, sTimePoints);
for eventCounter=1:size(eventTypes,1)
    for neuronIndex=1:nNeurons
        figure('NumberTitle','off', 'Name', ['neuron ' num2str(neuronIndex)])
        set(gcf, 'Position', [  99         549        1386         317])
    
        subplot(1, 4, 1)
        plot(glmRuns{neuronIndex}.Coefficients.Estimate(2:end)', 'DisplayName', 'model coeffs')
        hold on
        legend
    
        % reconstruct the underlying rates, not the spiking!
        yy=modelRates(neuronIndex, :);
    
        subplot(1, 4, 2:4)
        plot(yy, 'DisplayName','recon rate')
    
        legend
        title(['reconstruction ' num2str(floor(100*mean(1./(modelRates(neuronIndex, :).^0.5))))]);
    end
end


%% generate random spike trains for empirical unexplained variance calculations
% 
% nRuns=100;
% allSimSpikes=0*repmat(modelRates, 1, 1, nRuns);
% 
% for counter=1:nRuns
%     spikes=poissrnd(modelRates);
%     allSimSpikes(:,:,counter)=spikes;
% end
% 
% allSimProb=poisspdf(allSimSpikes, repmat(modelRates, 1, 1, nRuns));
% 
% allSimMean=mean(allSimSpikes, 3);
% allSimVar=var(allSimSpikes, 1, 3);
% 
% allSimProbMean=mean(allSimProb, 3);
% allSimProbVar=var(allSimProb, 1, 3);
% 
% rrrSpikes=allSimVar./allSimMean;
% rrrSpikes(isnan(rrrSpikes))=1;
% 
% rrrProb=allSimProbVar./allSimProbMean;
% rrrProb(isnan(rrrProb))=1;
% 
% nnnSimVar=mean(modelRates, 2);


