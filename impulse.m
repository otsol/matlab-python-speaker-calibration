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
maxBoostPower=3; %Maximum multiplier for quiet frequencies
%end parameters
[x, Fs] = audioread("speaker-front-impulse.wav");
%x = x.^-1;
[test, fs_test] = audioread('testaudio/sweep.wav');
test=repmat(test,1,2);
%t = 0:1/1e3:4;
%test = chirp(t,40,4,4000);
%test = test(1:100000,:);
subplot(5,1,1)
plot(x)
title("Speaker impulse response")

%FFT
disp("Calculating FFT...")
T = 1/Fs;             % Sampling period
L = length(x);        % Length of signal
t = (0:L-1)*T;        % Time vector

Y = fft(x);           % Fourier transform
%cool1 = real(Y);
%cool2 = imag(Y);
%Y = cool1+cool2*i;
Y = Y.^-1;
indexOf1000Hz = floor(length(x)/2/((Fs/2)/1000));
normFactor = Y(indexOf1000Hz);
normFactor = abs(normFactor);


idx = abs(Y)>(normFactor*maxBoostPower);
Y(idx) = normFactor*maxBoostPower;
test1 = real(Y(50600:80400));
test2 = imag(Y(50600:80400));
%Y(50600:80400)=test2*1i-0.5*test1;
%Y(50600:80400)=0.99*Y(50600:80400);
%Y=Y(65537:end);
%MinFreqIndex = floor(length(x)/2/((Fs/2)/speakerMinFreq));
%Y(1:MinFreqIndex)=0; %set values below speaker freq response to zero
%Y(length(Y)-MinFreqIndex:end)=0; %set values below speaker freq response to zero
%Y(floor(length(x)/2/(speakerMaxFreq/(Fs/2))):end)=0; %set values above speaker freq response to zero

subplot(5,1,2)
plot(abs(Y))
title("abs(fft(x))")

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
y=y(1:2500);
disp("IFFT calculation done")
subplot(5,1,5)
plot(y)
title("Modified speaker impulse response")

%calculate result audio
disp("Calculating result...")
test = [conv(x,test(:,1)) conv(x,test(:,2))];
result = [conv(y,test(:,1)) conv(y,test(:,2))];
result = result * (1/max(max(result)));
result = bandpass(result,[speakerMinFreq speakerMaxFreq],Fs);
disp("Result calculation done")

figure(2);
subplot(2,1,1)
M = 200;
L = 11;
g = bartlett(M);
Ndft = 1024;

spectrogram(test(:,1),g,L,Ndft,fs_test)
subplot(2,1,2)
M = 200;
L = 11;
g = bartlett(M);
Ndft = 1024;

spectrogram(result(:,1),g,L,Ndft,fs_test)

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