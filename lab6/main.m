close all
clear all
clc

pkg load signal
pkg load image

global VIS = 'off';

if ~exist('plots', 'dir'), mkdir('plots'); end

fig = 'lena_c.jpg';

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

function img = read_img(name)
    root = './img/';
    X = imread([root name]);
    X = rgb2gray(X);
    img = double(X)./255;
end

function [X,Y] = plot_comparison(fig_id, name, spec)
    global VIS
    X = read_img(name);
    Y = filter2(spec.weights, X);

    figure(fig_id, 'visible', VIS);
    subplot(1,2,1);
    colormap(gray(256));
    imshow(X);
    title(name);

    subplot(1,2,2);
    colormap(gray(256));
    imshow(Y);
    title(spec.name);

    [~, base] = fileparts(name);
    tag = strrep(spec.name, ' - ', '_');
    saveas(gcf, ['plots/' base '_' tag '.jpg']);
end

function sweep(name, filters)
    for i = 1:numel(filters)
        plot_comparison(i, name, filters(i));
    end
end

sweep(fig, filters);
