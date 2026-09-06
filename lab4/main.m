%{
    Lab 4 - FIR Filter Design and Analysis

    name: antonio
    date: 06/09/2026
%}

close all
clear all
clc

pkg load signal

%% Plot Spectrum of a Signal
function plot_spectrum(sig, Fs, fig_id, ttl)
    m = length(sig);
    n = pow2(nextpow2(m));
    S = fft(sig, n);
    f = (0:n-1)*(Fs/n);

    figure(fig_id);
    plot(f(1:n/2), abs(S(1:n/2)));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title(ttl);
    grid on;
end

%% Filter Design
function [h, M] = design_fir(type, specs, Fs);
    % FIR filter design: lowpass, highpass, bandpass, stopband
    % window: hanning

    switch type
        % lowpass
        case 'low'
            wp = 2*pi*specs.fp/Fs;
            ws = 2*pi*specs.fs/Fs;

            % cutoff frequency
            wc = (wp + ws)/2;

            dw = ws - wp;

            M  = ceil(8*pi/abs(dw));
            % normalized frequencies
            h  = fir1(M, wc/pi, 'low', hanning(M+1));

        % highpass
        case 'high'
            wp = 2*pi*specs.fp/Fs;
            ws = 2*pi*specs.fs/Fs;

            % cutoff frequency
            wc = (wp + ws)/2;
            dw = wp - ws;

            M  = ceil(8*pi/abs(dw));
            M  = M + mod(M, 2); % even order
            % normalized frequencies
            h  = fir1(M, wc/pi, 'high', hanning(M+1));

        % bandpass
        case 'bandpass'
            fp1 = specs.fp1; fp2 = specs.fp2; fs1 = specs.fs1;
            fs2 = fp1*fp2/fs1; % symmetry

            wp1 = 2*pi*fp1/Fs; wp2 = 2*pi*fp2/Fs;
            ws1 = 2*pi*fs1/Fs; ws2 = 2*pi*fs2/Fs;

            % cutoff frequencies
            wc1 = (wp1+ws1)/2; wc2 = (wp2+ws2)/2;

            dw1 = wp1-ws1;     dw2 = ws2-wp2;

            M = max(ceil(8*pi/dw1), ceil(8*pi/dw2));
            % normalized frequencies
            h = fir1(M, [ wc1/pi wc2/pi ], hanning(M+1));

        % stopband
        case 'stop'
            fp1 = specs.fp1; fp2 = specs.fp2;
            fs1 = specs.fs1; fs2 = specs.fs2;

            wp1 = 2*pi*fp1/Fs; wp2 = 2*pi*fp2/Fs;
            ws1 = 2*pi*fs1/Fs; ws2 = 2*pi*fs2/Fs;

            % cutoff frequencies
            wc1 = (wp1+ws1)/2; wc2 = (wp2+ws2)/2;

            dw1 = ws1-wp1;     dw2 = wp2-ws2;

            M = max(ceil(8*pi/dw1), ceil(8*pi/dw2));
            M = M + mod(M, 2); % even order

            % normalized frequencies
            h = fir1(M, [ wc1/pi wc2/pi ], 'stop', hanning(M+1));

        otherwise
            error('design_fir: unknown filter type: %s', type);
    end
end

file = 'all_star.wav';

% read samples
[x,Fs] = audioread(file);
x = x(:,1);

%% Spectrum of the original signal
plot_spectrum(x, Fs, 1, 'Spectrum of x(n)');
saveas(gcf, 'img/spectrum_x.png');

% struct to pack filter specifications
filters = struct('name', {}, 'type', {}, 'specs', {});

%% Filter Specifications
% |------------|-----------------|-----------------|------------------> f(Hz)
% 0  lowpass  600   stopband   7800   bandpass   12500   highpass 

% Lowpass filter: fp=600 Hz, fs=900 Hz
filters(1).name  = 'Lowpass';
filters(1).type  = 'low';   
filters(1).specs = struct('fp', 600, 'fs', 900);

% Highpass filter: fp=12500 Hz, fs=12000 Hz
filters(2).name  = 'Highpass';
filters(2).type  = 'high';
filters(2).specs = struct('fp', 12500, 'fs', 12000);

% Bandpass filter: fp1=7800 Hz, fp2=12500 Hz, fs1=7000 Hz (fs2 by symmetry)
filters(3).name  = 'Bandpass';
filters(3).type  = 'bandpass';
filters(3).specs = struct('fp1', 7800, 'fp2', 12500, 'fs1', 7000);

% Stopband filter: fp1=300 Hz, fs1=600 Hz, fs2=7800 Hz, fp2=8100 Hz
filters(4).name  = 'Stopband';
filters(4).type  = 'stop';
filters(4).specs = struct('fp1', 300, 'fs1', 600, 'fs2', 7800, 'fp2', 8100);

%% Filter Design
nfilt = numel(filters); % 4
h     = cell(1, nfilt);     % h(i) with different sizes
M     = zeros(1, nfilt);

for k = 1:nfilt
    fprintf('Designing filter %d/%d: %s\n', k, nfilt, filters(k).name);
    [h{k}, M(k)] = design_fir(filters(k).type, filters(k).specs, Fs);
end

%% Frequency Responses
figure(2);
hold on;
legend_names = cell(1, nfilt);
for k = 1:nfilt
    [H, w] = freqz(h{k}, 1, 2048, Fs);
    plot(w, 20*log10(abs(H) + eps));
    legend_names{k} = sprintf('%s (M=%d)', filters(k).name, M(k));
end
hold off;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Frequency Responses of FIR Filters');
legend(legend_names);
grid on;
saveas(gcf, 'img/freq_responses.png');

%% Group Delay
for k = 1:nfilt
    figure(2+k);

    subplot(2,1,1);
    [gd, w] = grpdelay(h{k}, 1, 2048, Fs);
    plot(w, gd);
    xlabel('Frequency (Hz)');
    ylabel('Group Delay (samples)');
    title(sprintf('%s - Group Delay', filters(k).name));
    grid on;

    subplot(2,1,2);
    zplane(h{k}, 1);
    if strcmp(filters(k).type, 'stop')
        axis([-2 2 -2 2]); % zoom on stopband plot
    end
    title(sprintf('%s - Poles and Zeros', filters(k).name));
    saveas(gcf, sprintf('img/filter_%d_pz.png', k));
end

%% Filtering and Filter Spectrum
y_k = cell(1, nfilt);

for k = 1:nfilt
    fprintf('Filtering with %s...\n', filters(k).name);
    y_k{k} = filter(h{k}, 1, x);
    plot_spectrum(y_k{k}, Fs, 6+k, sprintf('Spectrum of y%d(n) - %s', k, filters(k).name));
    saveas(gcf, sprintf('img/spectrum_y%d.png', k));
end

%% Diagram
%     lp  hp  bp  sb
G = [  1   1   1   1 ]; % gains for each filter (lp, hp, bp, sb)
y = zeros(size(x));

for k = 1:nfilt
    y = y + G(k) * y_k{k};
end

%% Play Filtered Signals

player_lp = audioplayer(y_k{1}, Fs); % som claro, da pra entender o vocal. Os intrumentos parecem mais misturados e a musica abafada. Parece que estou escutando de outro comodo.
player_hp = audioplayer(y_k{2}, Fs); % som bem baixo e agudo. É no ritmo da música, mas não da pra dicernir o vocal e nem os instrumentos.
player_bp = audioplayer(y_k{3}, Fs); % som bem baixo e nada fluido (meio rangido), mas ainda no ritmo da musica. Nao da pra dicernir os instrumentos
player_sb = audioplayer(y_k{4}, Fs); % da pra dicernir o vocal e um pouco os instrumentos, mas a musica parece abafada e com um pouco de ruido. Parece que estou escutando debaixo da agua.

player_y  = audioplayer(y, Fs);    % nao ficoou a mesma coisa. O audio claramente perdeu qualidade.
player_clean = audioplayer(x, Fs); % audio original, sem filtragem.