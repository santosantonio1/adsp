close all
clear all
clc

file = 'all_star.wav';

[x,Fs] = audioread(file);
bits = audioinfo(file).BitsPerSample;

m = length(x(:,1));
n = pow2(nextpow2(m));
X = fft(x(:,1), n);
f = (0:n-1)*(Fs/n);

figure(1);
plot(f(1:(n/2)), abs(X(1:(n/2))));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;
saveas(gcf, 'spectrum.png');