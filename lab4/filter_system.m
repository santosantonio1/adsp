close all
clear all
clc

pkg load signal

% ---------------------------------------------------------------------
% Pratica 4 - Sistema de filtragem FIR
%
% Implementa o diagrama da Figura 1 do enunciado: 4 filtros FIR em
% paralelo (passa-baixas/altas/banda/rejeita-banda), cada um com um
% ganho Gk, somados para formar y(n) = sum Gk*yk(n).
%
% As bandas de cada filtro estao definidas em `filters` abaixo (specs em
% Hz). Ajuste esses valores apos analisar o espectro de x(n) para que as
% 4 bandas cubram 0..Fa/2 sem se sobrepor.
% ---------------------------------------------------------------------

file = 'all_star.wav';
[x, Fs] = audioread(file);
x = x(:,1); % mono

%% Espectro do sinal de entrada x(n)
plot_spectrum(x, Fs, 1, 'Espectro de x(n)');

%% ---------------------------------------------------------------------
%  Especificacao dos 4 filtros
%
%  Bordas escolhidas a partir do espectro de x(n): forte energia abaixo
%  de 600 Hz, vale quase vazio entre 600 Hz e 7.8 kHz, "corcova" de
%  harmonicos entre 7.8 kHz e 16.3 kHz, e quase nada acima de 16.3 kHz.
%
%  As margens de transicao (300 Hz, e os 7000/800 Hz ja usados no
%  passa-banda) foram escolhidas para manter a ordem dos filtros baixa
%  (poucas centenas de coeficientes) e assim a filtragem do audio
%  inteiro roda em segundos, nao minutos.
% ---------------------------------------------------------------------

filters = struct('name', {}, 'type', {}, 'specs', {}, 'G', {});

filters(1).name  = 'Passa-baixas';
filters(1).type  = 'low';
filters(1).specs = struct('fp', 600, 'fs', 900);
filters(1).G     = 1;

filters(2).name  = 'Rejeita-banda';
filters(2).type  = 'stop';
filters(2).specs = struct('fp1', 300, 'fs1', 600, 'fs2', 7800, 'fp2', 8100);
filters(2).G     = 1;

filters(3).name  = 'Passa-banda';
filters(3).type  = 'bandpass';
filters(3).specs = struct('fp1', 7800, 'fp2', 16300, 'fs1', 7000); % fs2 por simetria geometrica
filters(3).G     = 1;

filters(4).name  = 'Passa-altas';
filters(4).type  = 'high';
filters(4).specs = struct('fp', 16300, 'fs', 16000);
filters(4).G     = 1;

nfilt = numel(filters);
h = cell(1, nfilt);
M = zeros(1, nfilt);

for k = 1:nfilt
    [h{k}, M(k)] = design_fir(filters(k).type, filters(k).specs, Fs);
end

%% Respostas em frequencia sobrepostas
figure;
hold on;
legend_names = cell(1, nfilt);
for k = 1:nfilt
    [H, w] = freqz(h{k}, 1, 2048, Fs);
    plot(w, 20*log10(abs(H) + eps));
    legend_names{k} = sprintf('%s (M=%d)', filters(k).name, M(k));
end
hold off;
xlabel('Frequencia (Hz)');
ylabel('Magnitude (dB)');
title('Respostas em frequencia dos filtros FIR');
legend(legend_names);
grid on;

%% Atraso de grupo e diagrama de polos e zeros, por filtro
for k = 1:nfilt
    figure;

    subplot(2,1,1);
    [gd, w] = grpdelay(h{k}, 1, 2048, Fs);
    plot(w, gd);
    xlabel('Frequencia (Hz)');
    ylabel('Atraso de grupo (amostras)');
    title(sprintf('%s - Atraso de grupo', filters(k).name));
    grid on;

    subplot(2,1,2);
    zplane(h{k}, 1);
    title(sprintf('%s - Polos e zeros', filters(k).name));
end

%% Filtragem individual e espectro de cada saida yk(n)
y_k = cell(1, nfilt);
for k = 1:nfilt
    y_k{k} = filter(h{k}, 1, x);
    plot_spectrum(y_k{k}, Fs, 4+k, sprintf('Espectro de y%d(n) - %s', k, filters(k).name));
end

%% Sistema completo: y(n) = sum Gk*yk(n)
G = [filters.G];
y = zeros(size(x));
for k = 1:nfilt
    y = y + G(k) * y_k{k};
end

plot_spectrum(y, Fs, 4+nfilt+1, 'Espectro de y(n)');

player_x = audioplayer(x, Fs);
player_y = audioplayer(y, Fs);
players_yk = cellfun(@(s) audioplayer(s, Fs), y_k, 'UniformOutput', false);

% Item d) teste individual dos filtros: altere filters(k).G entre 0 e 1
% e rode o script novamente, ou reproduza players_yk{k} isoladamente.
%
% Funcoes auxiliares usadas acima: design_fir.m, plot_spectrum.m
% (arquivos separados nesta mesma pasta).
