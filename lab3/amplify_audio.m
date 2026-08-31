close all;
clear all;
clc;

file = 'all_star.wav';

[y,Fs] = audioread(file);

%% b)

K = [ 0.01 0.1 0.5 1 2 ];

for i = 1:length(K)
  fprintf('=== applying gain %6.2f ===\n', K(i));

  player = audioplayer(K(i)*y, Fs);
  play(player);

  input('press [ENTER] to stop...\n');
  stop(player);

  fprintf('=== done ===\n');
end
