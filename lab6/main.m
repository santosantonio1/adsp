close all
clear all
clc

pkg load signal
pkg load image

VIS = 'on';

filters = struct('name', {}, 'weights', {});

filters(1).name     = 'Lowpass';
filters(1).weights  = [  1  1  1;  1  1  1;  1  1  1 ];

filters(2).name     = 'Highpass';
filters(2).weights  = [ -1 -1 -1; -1  8 -1; -1 -1 -1 ];

filters(3).name     = 'Prewitt - Vertical';
filters(3).weights  = [ -1  0  1; -1  0  1; -1  0  1 ];

filters(4).name     = 'Sobel - Vertical';
filters(4).weights  = [ -1  0  1; -2  0  2; -1  0  1 ];

filters(5).name     = 'Prewitt - Horizontal';
filters(5).weights  = [ -1 -1 -1;  0  0  0;  1  1  1 ];

filters(6).name     = 'Sobel - Horizontal';
filters(6).weights  = [ -1 -2 -1;  0  0  0;  1  2  1 ];

filters(7).name     = 'Kirsch';
filters(7).weights  = [  5  5  5; -3  0 -3; -3 -3 -3 ];

filters(8).name     = 'Laplacian';
filters(8).weights  = [  1 -2  1; -2  4 -2;  1 -2  1 ];
