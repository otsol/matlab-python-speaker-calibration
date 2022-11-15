%x = readcell("Nov 9 11_00_58_no_intro.txt");
% x signal, Fs sampling frequency
[x, Fs] = audioread("Nov 9 10_44_41.wav");                  
T = 1/Fs;             % Sampling period       
L = length(x);        % Length of signal
t = (0:L-1)*T;        % Time vector

Y = fft(x);           % Fourier transform

P2 = abs(Y/L);        % Power spectrum
P1 = P2(1:L/2+1);     % Single-sided spectrum
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
subplot(2,1,1)
plot(f,P1) 
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")

subplot(2,1,2)
plot(log10(f),log10(P1))
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")


%y = cell2mat(x);
%figure(1)

%plot(y)