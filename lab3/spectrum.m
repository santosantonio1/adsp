close all;
clear all;
clc;

file = 'shrek.wav';

[x,fs] = audioread(file);
bits = audioinfo(file).BitsPerSample;

bCall = x(:,1);
tb = 0:(1/fs):((length(bCall)-1)/fs);

%% b)

figure(1);
plot(tb, bCall);
xlim([0 tb(end)]);
xlabel('Time (s)');
ylabel('Amplitude');
title('{\bf Audio}');
grid on;

%% c)

m = length(bCall);       
n = pow2(nextpow2(m));   
Y = fft(bCall, n);       
f = (0:n-1)*(fs/n);      

figure(2);
subplot(2, 1, 1);
plot(f(1:(n/2)), abs(Y(1:(n/2))));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('{\bf Magnitude}');
grid on;

subplot(2, 1, 2);
plot(f(1:(n/2)), angle(Y(1:(n/2))));
xlabel('Frequency (Hz)');
xlim([0 10]);
ylabel('Phase');
ylim([-5 5]);
yline([-pi pi], '--r');
text(1.5, 4, '\pi');
text(1.5, -4, '-\pi');
title('{\bf Phase}');
grid on;

%% d)
