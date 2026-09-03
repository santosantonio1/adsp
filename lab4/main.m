close all
clear all
clc

pkg load signal

file = 'all_star.wav';

[x,Fs] = audioread(file);
bits = audioinfo(file).BitsPerSample;

m = length(x(:,1));
n = pow2(nextpow2(m));
X = fft(x(:,1), n);
f = (0:n-1)*(Fs/n);

%% Spectrum
%{
%}

figure(1);
plot(f(1:(n/2)), abs(X(1:(n/2))));
xlabel('Frequency (Hz)');
xlim([0 1500]);
ylabel('Magnitude');
grid on;
%saveas(gcf, 'spectrum.png');

player_clean = audioplayer(x, Fs);

fp1 = 7800;
fp2 = 16300;
fs1 = 7000;

fp1 = 300;
fp2 = 900;
fs1 = 200;

fs2 = fp1*fp2/fs1; % symmetry 

wp1 = 2*pi*fp1/Fs;
wp2 = 2*pi*fp2/Fs;
ws1 = 2*pi*fs1/Fs;
ws2 = 2*pi*fs2/Fs;

%{
wp1 = 2*fp1/Fs;
wp2 = 2*fp2/Fs;
ws1 = 2*fs1/Fs;
ws2 = 2*fs2/Fs;
%}

wc1 = (wp1+ws1)/2;
wc2 = (wp2+ws2)/2;

dw1 = wp1 - ws1;
dw2 = ws2 - wp2;


%{
    hanning 
%}

M1 = ceil(8*pi/dw1);
M2 = ceil(8*pi/dw2);

M = max(M1, M2);

h = fir1(M, [ wc1/pi wc2/pi ], hanning(M+1));
y = filter(h, 1, x(:,1));
player_f1 = audioplayer(y, Fs);

% -------------------

m1 = length(y(:,1));
n1 = pow2(nextpow2(m1));
Y1 = fft(y(:,1), n1);
f1 = (0:n1-1)*(Fs/n1);

%{
%}

figure(2);
plot(f1(1:(n1/2)), abs(Y1(1:(n1/2))));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;
% saveas(gcf, 'spectrum.png');