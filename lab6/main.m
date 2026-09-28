close all
clear all
clc

pkg load signal
pkg load image

global VIS = 'off';
global curr_img = 1;

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
    global curr_img
    for i = 1:numel(filters)
        plot_comparison(i, name, filters(i));
        curr_img = i;
    end
end

sweep(fig, filters);

%% === Part 2 ===

filters(9).name = 'Blurr - Horizontal';
filters(9).weights = 1/16 * [ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 ];

filters(10).name = 'Blurr - Vertical';
filters(10).weights = 1/16 * [ 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1 ];

plot_comparison(curr_img, fig, filters(9));
plot_comparison(curr_img, fig, filters(10));

img = read_img(fig);
[M,N] = size(img);

u = -M/2 : (M/2)-1;
v = -N/2 : (N/2)-1;
[V,U] = meshgrid(v, u);
D = sqrt(U.^2 + V.^2);

% Butterworth Filter Specs

D0  = 50;       % cutoff frequency
n   = 2;        % order

H_ideal = double(D <= D0);
H_butter = 1./(1 + (D./D0).^(2*n));

fft_img = fft2(img);
x = fft_img .* H_ideal;
y = fft_img .* H_butter;
filtered_img_ideal  = ifft2(x);
filtered_img_butter = ifft2(y);

figure(20);
subplot(1, 3, 1);
colormap(gray(256));
imshow(img);

subplot(1, 3, 2);
colormap(gray(256));
imshow(filtered_img_ideal);

subplot(1, 3, 3);
colormap(gray(256));
%imshow(abs(filtered_img_butter));
%imshow(ifft2(fft2(img)));
imshow(H_butter);