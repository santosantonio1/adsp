close all;
clear all;
clc;

file = 'all_star.wav'; 

[y,Fs] = audioread(file);

%% c)

% f = [ 0.01 0.1 0.5 1 2 ]; % apparently, the minimum is 8kHz
f = [ 0.5 1 2 5 ];

for i = 1:length(f)
  Fs_mod = f(i)*Fs;
  fprintf('=== applying Fs_mod %10.2f ===\n', Fs_mod);

  player = audioplayer(y, Fs_mod);
  play(player);

  input('press [ENTER] to stop...\n');
  stop(player);

  fprintf('=== done ===\n');
end

