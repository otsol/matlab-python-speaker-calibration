%{
ELEC-C5341 - SASP - Äänen ja Puheenkäsittely
Projektityö: Kaiuttimien kalibrointi
%}
clear;
clc;
close all;
%parameters
speakerMinFreq=53; %Minimum frequency speaker is capable of playing
speakerMaxFreq=20000; %Maximum frequency speaker is capable of playing
maxBoostPowerdB=3; %Maximum multiplier for quiet frequencies
numberOfPlots1=7;
%end parameters
%[x, Fs] = audioread("speaker-front-impulse.wav");
[x, Fs] = audioread("inf_beta50_couchsit_impulse.wav");
[test, fs_test] = audioread('testaudio/testaudio.wav');
test = test(1:80000,:); %shorten test audio

%normalize impulse response to 1
x=x./max(x);
%x = circshift(x, -47950);

subplot(numberOfPlots1,1,1)
plot(x)
title("Speaker impulse response")

%FFT
disp("Calculating and normalizing FFT...")
T = 1/Fs;             % Sampling period
L = length(x);        % Length of signal
t = (0:L-1)*T;        % Time vector
X = fft(x);           % Fourier transform
X=abs(X);
%plot abs fft(x)
subplot(numberOfPlots1,1,2)
semilogx(X)
title("abs(X)")
axis padded

X=mag2db(X);
indexOf1000Hz = floor(length(X)/2/((Fs/2)/1000));
normFactor = X(indexOf1000Hz);
X=X-normFactor;
X_norm=X;
%plot normalized Y
subplot(numberOfPlots1,1,3)
semilogx(X)
title("normalized mag2db(X))")
axis padded

%idx = abs(Y)>(normFactor*maxBoostPowerdB);
%Y(idx) = normFactor*maxBoostPowerdB;
disp("FFT calculation and normalization done")

disp("Spectrum manipulation...")
X=X.*-1;
X_inverted=X;
%X=X-min(X);
%plot negated Y
subplot(numberOfPlots1,1,4)
semilogx(X)
title("normalized and negated Y")
axis padded

indexOfLowHz = floor(length(X)/2/((Fs/2)/speakerMinFreq));
indexOfHighHz = floor(length(X)/2/((Fs/2)/speakerMaxFreq));
%Y(1:indexOfLowHz)=0;
%Y(end-indexOfLowHz:end)=0;

%modified Y
subplot(numberOfPlots1,1,5)
semilogx(X)
title("modified Y")
axis padded

disp("Spectrum manipulation done")

%P2 = abs(Y/L);        % Power spectrum
%P1 = P2(1:L/2+1);     % Single-sided spectrum
%P1(2:end-1) = 2*P1(2:end-1);

%f = Fs*(0:(L/2))/L;

%subplot(5,1,2)
%plot(f,P1)
%title("Single-Sided Amplitude Spectrum of X(t)")
%xlabel("f (Hz)")
%ylabel("|P1(f)|")

%subplot(6,1,4)
%indexOf1000Hz = floor(length(P1)*(1000/(Fs/2)));
%normFactor = P1(indexOf1000Hz);
%P1 = P1/normFactor;
%loglog(f,P1) %plot amplitude spectrum
%title("Single-Sided Amplitude Spectrum of X(t), log")
%xlabel("f (Hz)")
%ylabel("|P1(f)|")
%xlim([speakerMinFreq speakerMaxFreq])
%axis padded

%disp("Smoothing spectrum...")
%P1_smoothed = smoothSpectrum(P1,f',30);
%P1_smoothed=P1;
%disp("Smoothing spectrum done")
%process spectrum
%idx = P1_smoothed<(1/maxBoostPowerdB);
%P1_smoothed(idx) = 1/maxBoostPowerdB; %raise low values
%P1_smoothed(1:floor(length(P1)*(speakerMinFreq/(Fs/2))))=0; %set values below speaker freq response to zero
%P1_smoothed(floor(length(P1)*(speakerMaxFreq/(Fs/2))):end)=0; %set values above speaker freq response to zero

%plot processed spectrum
%subplot(6,1,5)
%loglog(f,P1_smoothed) %plot amplitude spectrum
%title("Single-Sided Amplitude Spectrum of X(t), log, processed")
%xlabel("f (Hz)")
%ylabel("|P1(f)|")
%xlim([speakerMinFreq speakerMaxFreq])
%axis padded

disp("Calculating IFFT...")
%y = ifft(P1_smoothed);
%f2 = Fs*(0:L-1)/L;
%Y_smoothed = smoothSpectrum(abs(Y),f2',30);
y=ifft(X);
y=y.*(1/max(y));
%y=y.*(1/max(y));
%y=0.00001.*y;
%y=y(1:2500);
disp("IFFT calculation done")
subplot(numberOfPlots1,1,6)
plot(y)
title("Modified speaker impulse response")
subplot(numberOfPlots1,1,7)
plot(X-X_inverted)
title("X-X_inverted")

%calculate result audio
disp("Calculating result...")
test_impulse = [conv(test(:,1),x) conv(test(:,2),x)]; %conv testaudio with measured freq response
test_impulse = test * (1/max(max(test)));
test_corrected = [conv(test_impulse(:,1),y) conv(test_impulse(:,2),y)]; %conv again with room correction filter
test_corrected = test_corrected * (1/max(max(test_corrected)));
disp("Result calculation done")

M = 200;
L = 11;
g = bartlett(M);
Ndft = 1024;

figure(2);
subplot(3,1,1)
spectrogram(test(:,1),g,L,Ndft,fs_test)
title("Original audio")
subplot(3,1,2)
spectrogram(test_impulse(:,1),g,L,Ndft,fs_test)
title("Original audio convoluted with measured impulse response")
subplot(3,1,3)
spectrogram(test_corrected(:,1),g,L,Ndft,fs_test)
title("Response fixed audio")

disp("Play original audio...")
%play original sound
player = audioplayer(test,fs_test); %init player
play(player) %play
waitfor(player,'Running') %wait until done
disp("Original audio played")
disp("Play audio convoluted with measured response...")
%play modified sound
player = audioplayer(test_impulse,fs_test); %init player
play(player) %play
waitfor(player,'Running') %wait until done
disp("Audio convoluted with measured response played")
disp("Play audio convoluted and then fixed...")
%play modified sound
player = audioplayer(test_corrected,fs_test); %init player
play(player) %play
waitfor(player,'Running') %wait until done
disp("Convoluted and fixed audio played")