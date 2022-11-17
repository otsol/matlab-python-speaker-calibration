%{
ELEC-C5341 - SASP - Äänen ja Puheenkäsittely
Projektityö: Kaiuttimien kalibrointi
%}
clear;
clc;
close all;
%x = readcell("Nov 9 11_00_58_no_intro.txt");
% x signal, Fs sampling frequency
%parameters
speakerMinFreq=53; %Minimum frequency speaker is capable of playing
speakerMaxFreq=20000; %Maximum frequency speaker is capable of playing
maxBoostPower=10; %Maximum multiplier for quiet frequencies
%end parameters
[x, Fs] = audioread("speaker-front-impulse.wav");
%x = x.^-1;
[test, fs_test] = audioread('testaudio.wav');
test = test(1:60000,:);
subplot(5,1,1)
plot(x)
title("Speaker impulse response")

%FFT
disp("Calculating FFT...")
T = 1/Fs;             % Sampling period
L = length(x);        % Length of signal
t = (0:L-1)*T;        % Time vector

Y = fft(x);           % Fourier transform
Y = Y.^-1;
indexOf1000Hz = floor(length(x)/2/24);
normFactor = Y(indexOf1000Hz);
normFactor = abs(normFactor);


idx = abs(Y)>(normFactor*maxBoostPower);
Y(idx) = normFactor*maxBoostPower;
subplot(5,1,2)
loglog(abs(Y))
title("fft(x), loglog")

P2 = abs(Y/L);        % Power spectrum
P1 = P2(1:L/2+1);     % Single-sided spectrum
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
disp("FFT calculation done")

%subplot(5,1,2)
%plot(f,P1)
%title("Single-Sided Amplitude Spectrum of X(t)")
%xlabel("f (Hz)")
%ylabel("|P1(f)|")

subplot(5,1,3)
indexOf1000Hz = floor(length(P1)*(1000/(Fs/2)));
normFactor = P1(indexOf1000Hz);
P1 = P1/normFactor;
loglog(f,P1) %plot amplitude spectrum
title("Single-Sided Amplitude Spectrum of X(t), log")
xlabel("f (Hz)")
ylabel("|P1(f)|")
xlim([speakerMinFreq speakerMaxFreq])
axis padded

disp("Smoothing spectrum...")
%P1_smoothed = smoothSpectrum(P1,f',30);
P1_smoothed=P1;
disp("Smoothing spectrum done")
%process spectrum
idx = P1_smoothed<(1/maxBoostPower);
P1_smoothed(idx) = 1/maxBoostPower; %raise low values
P1_smoothed(1:floor(length(P1)*(speakerMinFreq/(Fs/2))))=0; %set values below speaker freq response to zero
P1_smoothed(floor(length(P1)*(speakerMaxFreq/(Fs/2))):end)=0; %set values above speaker freq response to zero

%plot processed spectrum
subplot(5,1,4)
loglog(f,P1_smoothed) %plot amplitude spectrum
title("Single-Sided Amplitude Spectrum of X(t), log, processed")
xlabel("f (Hz)")
ylabel("|P1(f)|")
xlim([speakerMinFreq speakerMaxFreq])
axis padded

disp("Calculating IFFT...")
%y = ifft(P1_smoothed);
%f2 = Fs*(0:L-1)/L;
%Y_smoothed = smoothSpectrum(abs(Y),f2',30);
y=ifft(Y);
%y=y.*(1/max(y));
y=0.00001.*y;
disp("IFFT calculation done")

subplot(5,1,5)
plot(y)
title("Modified speaker impulse response")

%calculate result audio
disp("Calculating result...")
result = [conv(y,test(:,1)) conv(y,test(:,2))];
result = result * (1/max(max(result)));
disp("Result calculation done")

disp("Play original audio...")
%play original sound
player = audioplayer(test,fs_test); %init player
play(player) %play
waitfor(player,'Running') %wait until done
disp("Original audio played")
disp("Play modified audio...")
%play modified sound
player = audioplayer(result,fs_test); %init player
play(player) %play
waitfor(player,'Running') %wait until done
disp("modified audio played")