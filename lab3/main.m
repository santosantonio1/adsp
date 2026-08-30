close all;
clear all;
clc;

% file = 'fahhh.wav'; % https://www.youtube.com/watch?v=-vH2b55TSHI
% file = 'shrek.wav'; % https://www.youtube.com/watch?v=SWFA0d2vIUk
% file = 'stereo_love.wav'; % https://www.youtube.com/watch?v=bfl76Sr-Rsk
file = 'haunted.wav';

%=== Part I  ====

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
y = fft(bCall, n);
f = (0:n-1)*(fs/n);
p = y.*conj(y)/n;

figure(2);
plot(f(1:floor(n/2)), p(1:floor(n/2)));
xlabel('Frequency (Hz)');
ylabel('Power');
title('{\bf Frequency Components of an Audio}');
grid on;

%=== Part II ====

%% a)

[y,Fs] = audioread(file);

%% b)

clc;

% K = [ 0.1 0.5 1 2 5 10 100 ];
K = [ 0.01 0.1 0.5 1 2 ];

for i = 1:length(K)
  fprintf('=== applying gain %6.2f ===\n', K(i));

  player = audioplayer(K(i)*y, Fs);
  play(player);

  input('press [ENTER] to stop...\n');
  stop(player);

  fprintf('=== done ===\n');
end

%% c)

clc;

% f = [ 0.01 0.1 0.5 1 2 ]; % apparently, the minimum is 8kHz
f = [ 0.5 1 2 5];

for i = 1:length(f)
  Fs_mod = f(i)*Fs;
  fprintf('=== applying Fs_mod %10.2f ===\n', Fs_mod);

  player = audioplayer(y, Fs_mod);
  play(player);

  input('press [ENTER] to stop...\n');
  stop(player);

  fprintf('=== done ===\n');
end

%% d)

y_flip = flipud(y);

player = audioplayer(y_flip, Fs);
play(player);

[~, name, ext] = fileparts(file);
audiowrite([name '_flip' ext], y_flip, Fs);

%% e) f) g) h)

if size(y, 2) ~= 2
    error('the music must be stereo (found %d channel(s))', size(y, 2));
end

L = y(:,1);
R = y(:,2);

player = audioplayer(y, Fs);
