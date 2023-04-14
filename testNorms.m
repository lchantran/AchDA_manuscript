
% get random gaussian data
data1=normrnd(0,1,100000,1);

% scale some of it to make a skew to large values
data2=data1; 
data2(1:20000)=data2(1:20000)*5; 
data2=normalize(data2);

% scale some of it to make a skew to large values
data3=data1; 
data3(1:20000)=data3(1:20000)*10+1; 
data3=normalize(data3);

%%
binRange=-10:0.1:10;

% look at histograms
figure; 
histogram(data1, 'BinEdges', binRange);

hold on
histogram(data2, 'BinEdges', binRange);

hold on
histogram(data3, 'BinEdges', binRange);

% look only at portions from -1 to 1 z-score
figure; 
histogram(data1(data1>-1 & data1<1), 'BinEdges', binRange, 'Normalization', 'pdf');

hold on
histogram(data2(data2>-1 & data2<1), 'BinEdges', binRange, 'Normalization', 'pdf');

hold on
histogram(data3(data3>-1 & data3<1), 'BinEdges', binRange, 'Normalization', 'pdf');

% take data2 and warp it to make the data betwen +/- 1 z-score look "normal"
data2norm=normData(data2, zCut=1, cutLowToo=true, iterations=50);
data3norm=normData(data3, zCut=1, cutLowToo=true, iterations=50);

%% plot the +/- 1 z-score part of the histograms
figure; 
histogram(data1(data1>-1 & data1<1), 'BinEdges', binRange, 'Normalization', 'pdf');
hold on
histogram(data2norm(data2norm>-1 & data2norm<1), 'BinEdges', binRange, 'Normalization', 'pdf');
hold on
histogram(data3norm(data3norm>-1 & data3norm<1), 'BinEdges', binRange, 'Normalization', 'pdf');

%% plot the all of the histograms
figure; 
histogram(data1, 'BinEdges', binRange, 'Normalization', 'pdf');
hold on
histogram(data2norm, 'BinEdges', binRange, 'Normalization', 'pdf');
hold on
histogram(data3norm, 'BinEdges', binRange, 'Normalization', 'pdf');





