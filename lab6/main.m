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
filters(1).weights  = 1/9 * [  1  1  1;  1  1  1;  1  1  1 ];

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

% ---------------------------------------------------------------- helpers

function img = read_img(name)
    root = './img/';
    X = imread([root name]);
    X = rgb2gray(X);
    img = double(X)./255;
end

function save_fig(tag)
    saveas(gcf, ['plots/' tag '.jpg']);
end

function show_spectrum(fig_id, img, tag)
    global VIS
    S = log(1 + abs(fftshift(fft2(img))));
    figure(fig_id, 'visible', VIS);
    colormap(gray(256));
    imshow(mat2gray(S));
    title(['Spectrum - ' tag]);
    save_fig(['spectrum_' tag]);
end

function [X,Y] = plot_comparison(fig_id, name, spec)
    global VIS
    X = read_img(name);
    Y = filter2(spec.weights, X);

    figure(fig_id, 'visible', VIS);
    subplot(1,2,1);
    colormap(gray(256));
    imshow(X);
    title(name, 'interpreter', 'none');

    subplot(1,2,2);
    colormap(gray(256));
    imshow(Y, []);
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

% Masks below are centered, i.e. they live in the fftshift layout, so the
% spectrum has to be shifted before the product and unshifted afterwards.
function y = freq_filter(img, H)
    y = real(ifft2(ifftshift(fftshift(fft2(img)) .* H)));
end

function [Hi, Hb] = lp_masks(D, D0, n)
    Hi = double(D <= D0);
    Hb = 1 ./ (1 + (D ./ D0).^(2*n));
end

% Fraction of the spectral energy that survives the mask.
function e = energy_kept(img, H)
    F = fftshift(fft2(img));
    e = sum(sum(abs(F.*H).^2)) / sum(sum(abs(F).^2));
end

function compare_freq(fig_id, img, D, D0, n, tag)
    global VIS
    [Hi, Hb] = lp_masks(D, D0, n);
    yi  = freq_filter(img, Hi);
    yb  = freq_filter(img, Hb);
    yh  = freq_filter(img, 1 - Hb);

    figure(fig_id, 'visible', VIS);
    colormap(gray(256));
    subplot(2,2,1); imshow(img, []); title('Original');
    subplot(2,2,2); imshow(yi, []);  title(sprintf('Ideal LP  D0=%g', D0));
    subplot(2,2,3); imshow(yb, []);  title(sprintf('Butter LP  D0=%g  n=%d', D0, n));
    subplot(2,2,4); imshow(yh, []);  title(sprintf('Butter HP  D0=%g  n=%d', D0, n));
    save_fig(sprintf('%s_D0-%g_n-%d', tag, D0, n));

    printf('%-10s D0=%5.1f n=%d | energy kept: ideal %.4f  butter %.4f  butter HP %.4f\n', ...
           tag, D0, n, energy_kept(img, Hi), energy_kept(img, Hb), energy_kept(img, 1-Hb));
end

% ================================================================= Part 1

img = read_img(fig);

show_spectrum(100, img, 'original');
sweep(fig, filters);

% ================================================================= Part 2

filters(9).name    = 'Blurr - Horizontal';
filters(9).weights = 1/16 * ones(1,16);

filters(10).name    = 'Blurr - Vertical';
filters(10).weights = 1/16 * ones(16,1);

plot_comparison(9,  fig, filters(9));
plot_comparison(10, fig, filters(10));

[M,N] = size(img);
u = -M/2 : (M/2)-1;
v = -N/2 : (N/2)-1;
[V,U] = meshgrid(v, u);
D = sqrt(U.^2 + V.^2);

% (D0, n) pairs: the one required by the spec plus three variations.
configs = [ 50 2; 10 2; 120 2; 50 8 ];

printf('\n--- sharp image ---\n');
for k = 1:rows(configs)
    compare_freq(200+k, img, D, configs(k,1), configs(k,2), 'lena');
end

% Masks themselves, for reference.
[Hi, Hb] = lp_masks(D, 50, 2);
figure(300, 'visible', VIS);
colormap(gray(256));
subplot(1,3,1); imshow(Hi, []);     title('Ideal LP  D0=50');
subplot(1,3,2); imshow(Hb, []);     title('Butter LP  D0=50  n=2');
subplot(1,3,3); imshow(1 - Hb, []); title('Butter HP  D0=50  n=2');
save_fig('masks_D0-50_n-2');

% --- items 8 to 10: horizontally blurred image ---

blur = filter2(filters(9).weights, img);
show_spectrum(101, blur, 'blur');

printf('\n--- horizontally blurred image ---\n');
for k = 1:rows(configs)
    compare_freq(400+k, blur, D, configs(k,1), configs(k,2), 'blur');
end

% Unsharp masking: add back the high frequencies the blur attenuated.
figure(500, 'visible', VIS);
colormap(gray(256));
subplot(1,3,1); imshow(blur, []); title('Blurred');
printf('\nrms(blur - original) %.4f\n', sqrt(mean((blur(:)-img(:)).^2)));
sharp_cfg = [ 10 0.25; 5 1.0 ];
for i = 1:rows(sharp_cfg)
    D0 = sharp_cfg(i,1); k = sharp_cfg(i,2);
    [~, Hb] = lp_masks(D, D0, 2);
    sharp = blur + k * freq_filter(blur, 1 - Hb);
    subplot(1,3,i+1); imshow(sharp, []);
    title(sprintf('Unsharp D0=%g k=%g', D0, k), 'fontsize', 9);
    printf('unsharp D0=%5.1f n=2 k=%.2f | rms(sharp - original) %.4f\n', ...
           D0, k, sqrt(mean((sharp(:)-img(:)).^2)));
end
save_fig('blur_unsharp');
