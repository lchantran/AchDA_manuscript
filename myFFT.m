function [P1,f]=myFFT(X, Fs, plotRaw, ax)

if nargin<4
    ax=[];
end

if nargin<3
    plotRaw=0;
end

if nargin<2
    Fs=1;
end

if mod(length(X),2)~=0
    X=X(1:end-1);
end

T = 1/Fs;             % Sampling period       
L = length(X);        % Length of signal
t = (0:L-1)*T;        % Time vector

Y=fft(X);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

if plotRaw
    figure;
    plot(t, X);
end

f = Fs*(0:(L/2))/L;
if ishandle(ax)
    plot(ax, f,P1, 'marker', '.') 
else
    figure;
    plot(f,P1, 'marker', '.') 
    title('Single-Sided Amplitude Spectrum of X(t)')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    set(gca, 'XScale', 'log')
    set(gca, 'YScale', 'log')

end
