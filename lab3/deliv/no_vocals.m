close all;
clear all;
clc;

%% e)

file = 'hotel_california.wav';

[y,Fs] = audioread(file);
% [y,Fs] = audioread(file, round([100 120]*Fs) + 1);  % 100s-120s

%% f)

if size(y, 2) ~= 2
    error('the music must be stereo (found %d channel(s))', size(y, 2));
end

%% g)

L = y(:,1);
R = y(:,2);

%% h) 

y_novoc = R - L;
y_novoc = y_novoc / max(abs(y_novoc)); % normalization

%% i) 

t = (0:size(y,1)-1)' / Fs;

% ~100 samples per pixel column 
step = ceil(size(y,1) / 50e3);
t_plot = t(1:step:end);

sig = { y, y_novoc, L, R  };
names = { 'Original', 'No vocals', 'Left (L)', 'Right (R)' };

figure(1);
for k = 1:4
  subplot(2, 2, k);
  plot(t_plot, sig{k}(1:step:end, :));
  xlim([0 t(end)]);
  ylim([-1 1]);
  xlabel('Time (s)');
  ylabel('Amplitude');
  title(['{\bf ' names{k} '}']);
  grid on;
end

%% j) 

player = audioplayer(y_novoc, Fs);
play(player);
% play(player, round([100 120]*Fs)+1);

[~, name, ext] = fileparts(file);
audiowrite([name '_novocals' ext], y_novoc, Fs);
