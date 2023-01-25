%{
ELEC-C5341 - SASP - Äänen ja Puheenkäsittely
Projektityö: Kaiuttimien kalibrointi
%}
clear;
clc;
close all;

%[x, Fs] = audioread("speaker-front-impulse.wav");
[x, Fs] = audioread("Impulse_responses/sasp_2022_eq_jblxtreme3_11122022_measurement2.wav");
[test, fs_test] = audioread('testaudio/testaudio.wav');
test = test(1:80000,:); %shorten test audio

%parameters
speakerMinFreq=53; %Minimum frequency speaker is capable of playing
speakerMaxFreq=20000; %Maximum frequency speaker is capable of playing
maxBoostPowerdB=3; %Maximum multiplier for quiet frequencies
numberOfPlots1=7;
fftSize=length(x);
%end parameters

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
X = fft(x,fftSize);           % Fourier transform

X_abs=abs(X);
%plot abs fft(x)
subplot(numberOfPlots1,1,2)
semilogx(X_abs)
title("X abs")
axis padded

X_db=mag2db(X_abs);
indexOf1000Hz = floor(length(X_db)/2 / ((fftSize/2)/1000));
normFactor = X_db(indexOf1000Hz);
X_db_norm=X_db-normFactor;
%plot normalized Y
subplot(numberOfPlots1,1,3)
semilogx(X_db_norm)
title("X db norm")
axis padded

disp("FFT calculation and normalization done")

disp("Spectrum manipulation...")
X_db_inverted=-X_db_norm;
%plot negated Y
subplot(numberOfPlots1,1,4)
semilogx(X_db_inverted)
title("X inverted")
axis padded

%Write csv for Python script
writematrix(X_db_inverted(1:floor(131072/2)), "Matlab_output/X_db_inverted_Xtreme3_OK18.csv") %write inverted response in db-scale to a file
%commands for later Matlab versions, R2020b and older don't support pyrunfile
%pyrunfile("createAPOConfig.py ", "Fs", "X_db_inverted.csv", "0.2");
%system("createAPOConfig.py 48000 X_db_inverted.csv 0.2");
disp("Spectrum manipulation done")
disp("Calculating IFFT...")

subplot(numberOfPlots1,1,7)
zeroresponse=X_db_norm+X_db_inverted;
plot(zeroresponse)
title("X db norm.*X inverted")

X_norm_mag=db2mag(X_db_norm);
X_inverted_mag=db2mag(X_db_inverted);

x_resp_norm=ifft(X_norm_mag);
x_resp_mod=ifft(X_inverted_mag);
x_resp_mod(length(x_resp_mod)/2:end)=0; %delete right half of unstable impulse response
disp("IFFT calculation done")
subplot(numberOfPlots1,1,5)
plot(x_resp_norm)
title("Normalized speaker impulse response, x resp norm")
subplot(numberOfPlots1,1,6)
plot(x_resp_mod)
title("Modified speaker impulse response, x resp mod")

%calculate result audio
disp("Calculating result...")
test_impulse = [conv(test(:,1),x_resp_norm) conv(test(:,2),x_resp_norm)]; %conv testaudio with measured freq response
test_impulse = test_impulse * (1/max(max(test_impulse)));
test_impulse = test_impulse(1:length(test))';

test_corrected = [conv(test(:,1),x_resp_mod) conv(test(:,2),x_resp_mod)]; %conv again with room correction filter
test_corrected = test_corrected * (1/max(max(test_corrected)));
test_corrected = test_corrected(1:length(test))';
disp("Result calculation done")

M = 200;
L = 11;
g = bartlett(M);
Ndft = 1024;

figure(2);
subplot(3,1,1)
spectrogram(test(:,1),g,L,Ndft,fs_test)
title("Original audio, test")
subplot(3,1,2)
spectrogram(test_impulse(:,1),g,L,Ndft,fs_test)
title("Original audio convoluted with measured and normalized impulse response, test impulse")
subplot(3,1,3)
spectrogram(test_corrected(:,1),g,L,Ndft,fs_test)
title("Response fixed audio, test conv with correction filt, test corrected")

disp("Play original audio...")
%play original sound
player = audioplayer(test,fs_test); %init player
play(player) %play
waitfor(player,'Running') %wait until done
disp("Original audio played")
disp("Play audio convoluted with measured and normalized response...")
%play modified sound
player = audioplayer(test_impulse,fs_test); %init player
play(player) %play
waitfor(player,'Running') %wait until done
disp("Audio convoluted with measured response played")
disp("Play fixed audio...")
%play modified sound
player = audioplayer(test_corrected,fs_test); %init player
play(player) %play
waitfor(player,'Running') %wait until done
disp("Fixed audio played")