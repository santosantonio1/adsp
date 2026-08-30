close all;
clear all;
clc;

file = 'shrek.wav';

[y,Fs] = audioread(file);

%% d)

y_flip = flipud(y);

player = audioplayer(y_flip, Fs);
play(player);

[~, name, ext] = fileparts(file);
audiowrite([name '_flip' ext], y_flip, Fs);

