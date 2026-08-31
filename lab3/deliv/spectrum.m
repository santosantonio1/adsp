close all;
clear all;
clc;

file = 'all_star.wav';

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

f_int = 4000;                             % interference frequency (Hz)
A_int = 0.05*max(abs(bCall));             % 5% of the signal peak

ti = tb(:);                          
bCall_int = bCall + A_int*sin(2*pi*f_int*ti);

Y_int = fft(bCall_int, n);

figure(3);
subplot(2, 1, 1);
plot(f(1:(n/2)), abs(Y_int(1:(n/2))));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('{\bf Magnitude with 4 kHz interference}');
xline(f_int, '--r');
text(f_int + 0.02*fs/2, 0.9*max(abs(Y_int(1:(n/2)))), sprintf('%d Hz', f_int));
grid on;

subplot(2, 1, 2);
plot(f(1:(n/2)), angle(Y_int(1:(n/2))));
xlabel('Frequency (Hz)');
ylabel('Phase');
ylim([-5 5]);
yline([-pi pi], '--r');
text(1.5, 4, '\pi');
text(1.5, -4, '-\pi');
xline(f_int, '--r');
title('{\bf Phase with 4 kHz interference}');
grid on;

%% e)

Y_normalized = abs(Y(1:(n/2 + 1)))/max(abs(Y(1:(n/2 + 1))));
Y_int_normalized = abs(Y_int(1:(n/2 + 1)))/max(abs(Y_int(1:(n/2 + 1))));

figure(4);
subplot(2, 1, 1);
plot(f(1:(n/2 + 1)), Y_normalized);
xlim([0 fs/2]);
ylim([0 1.05]);
xlabel('Frequency (Hz)');
ylabel('Normalized magnitude');
title('{\bf Normalized spectrum - original}');
grid on;

subplot(2, 1, 2);
plot(f(1:(n/2 + 1)), Y_int_normalized);
xlim([0 fs/2]);
ylim([0 1.05]);
xlabel('Frequency (Hz)');
ylabel('Normalized magnitude');
title('{\bf Normalized spectrum - with 4 kHz interference}');
xline(f_int, '--r');
grid on;

player_clean = audioplayer(bCall, fs);
player_int = audioplayer(bCall_int, fs);

%% save the graphs

[~, name] = fileparts(file);
outdir = 'figures';
if ~exist(outdir, 'dir')
  mkdir(outdir);
end

graphs = { 1, 'b_time'
           2, 'c_spectrum'
           3, 'd_interference'
           4, 'e_normalized' };

for i = 1:rows(graphs)
  out = fullfile(outdir, sprintf('%s_%s.png', name, graphs{i,2}));
  print(figure(graphs{i,1}), out, '-dpng');
  fprintf('saved %s\n', out);
end
