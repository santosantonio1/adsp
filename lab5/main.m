close all
clear all
clc

file = 'all_star.wav'
[x,Fs] = audioread(file);
x = x(:,1);

A_max = 0.5;
A_min = 40;

Ts = 1/Fs;

