%% Concatenate data files into an array
% find folder with data files from labjack 

clear all
D=dir('Raw_*.mat');
filename={D.name};
dataArray=zeros(1,(length(filename)*(26000)));
for i=1:length(D)
    load(filename{i});
    dataArray(((i-1)*(26000)+1):(i*(26000)))=temp;
end


% access scanned data
output=dataArray;
totalLen = length(dataArray);
numChannels=13; % number of channels 

% In the order of scanning
Ch1=find(mod(1:totalLen,numChannels)==1); % GFP signal
Ch2=find(mod(1:totalLen,numChannels)==2); % RFP signal
Ch3=find(mod(1:totalLen,numChannels)==3); % GFP LED modulation 
Ch4=find(mod(1:totalLen,numChannels)==4); % RFP LED modulation
Ch5=find(mod(1:totalLen,numChannels)==11); % Side LEDs
Ch6=find(mod(1:totalLen,numChannels)==5); % Center port IR Beam
Ch7=find(mod(1:totalLen,numChannels)==6); % Right port IR Beam
Ch8=find(mod(1:totalLen,numChannels)==7); % Left port IR Beam
Ch9=find(mod(1:totalLen,numChannels)==8); % Left port lick sensor
Ch10=find(mod(1:totalLen,numChannels)==9); % Right port lick sensor
Ch11=find(mod(1:totalLen,numChannels)==10); % Center port LED
Ch12=find(mod(1:totalLen,numChannels)==12); % left valve
Ch13=find(mod(1:totalLen,numChannels)==0); % right valve


%% plot all raw data


figure;
ax = []
ax(1) = subplot(13,1,1);plot(output(Ch1));title('GFP')
ax(2) =subplot(13,1,2);plot(output(Ch2));title('RFP')
ax(3) =subplot(13,1,3);plot(output(Ch3)); title('GFP mod')
ax(4) =subplot(13,1,4);plot(output(Ch4));title('RFP mod')
ax(5) =subplot(13,1,5);plot(output(Ch11));title('Center LED'), ylim([-0.2 1.2])
ax(6) =subplot(13,1,6);plot(output(Ch6)); title('Centerport'), ylim([-0.2 1.2])
ax(7) =subplot(13,1,7);plot(output(Ch5)); title('Side LEDs'), ylim([-0.2 1.2])
ax(8) =subplot(13,1,8);plot(output(Ch7)); title('Rightport'), ylim([-0.2 1.2])
ax(9) =subplot(13,1,9);plot(output(Ch13));title('Right valve'), ylim([-0.2 1.2])
ax(10) =subplot(13,1,10);plot(output(Ch10)); title('Right Lick'), ylim([-0.2 1.2])
ax(11) =subplot(13,1,11);plot(output(Ch8));title('Leftport'), ylim([-0.2 1.2])
ax(12) =subplot(13,1,12);plot(output(Ch12));title('Left valve'), ylim([-0.2 1.2])
ax(13) =subplot(13,1,13);plot(output(Ch9));title('Left Lick'), ylim([-0.2 1.2])


linkaxes(ax,'x');