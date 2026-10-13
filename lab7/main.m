close all
clear all
clc

pkg load signal
pkg load image

global VIS = 'off';

if ~exist('plots', 'dir'), mkdir('plots'); end

fig = 'lena_c.jpg';

% ---------------------------------------------------------------- helpers

% Spec asks for gray levels in [0,255], so no normalization here.
function img = read_img(name)
    root = './img/';
    X = imread([root name]);
    X = rgb2gray(X);
    img = double(X);
end

function save_fig(tag)
    saveas(gcf, ['plots/' tag '.jpg']);
end

% Zonal mask: ones on the upper-left j x j triangle (u + v <= j + 1).
function A = zonal_mask(j, N)
    A = zeros(N);
    A(1:j,1:j) = fliplr(triu(ones(j)));
end

% ================================================================= items 1-4

img = read_img(fig);
N   = rows(img);
X   = dct2(img);

figure(1, 'visible', VIS);
colormap(gray(256));
imagesc(log(1 + abs(X)));
axis image;
colorbar;
title('DCT2 - log(1 + |X|)');
save_fig('dct_spectrum');

% Zoom on the low-frequency corner, where the energy lives.
figure(2, 'visible', VIS);
colormap(gray(256));
imagesc(log(1 + abs(X(1:32,1:32))));
axis image;
colorbar;
title('DCT2 - log(1 + |X|), 32x32 corner');
save_fig('dct_spectrum_zoom');

% ================================================================= items 5-9

js = [1 2 4 8 16 32 64 128];

figure(3, 'visible', VIS);
colormap(gray(256));
subplot(3,3,1); imshow(img, [0 255]); title('Original');

printf('%5s %8s %10s %10s %8s %8s\n', 'j', 'coefs', 'kept (%)', 'energy', 'RMSE', 'PSNR');
for k = 1:numel(js)
    j = js(k);
    A = zonal_mask(j, N);
    Y = idct2(X .* A);

    subplot(3,3,k+1); imshow(Y, [0 255]); title(sprintf('j = %d', j));
    % Full-resolution copy of each reconstruction (the truesize view).
    imwrite(uint8(Y), sprintf('plots/recon_j-%03d.jpg', j));

    n_kept = sum(A(:));
    energy = sum(sum((X .* A).^2)) / sum(X(:).^2);
    rmse   = sqrt(mean((Y(:) - img(:)).^2));
    printf('%5d %8d %10.4f %10.6f %8.2f %8.2f\n', ...
           j, n_kept, 100 * n_kept / N^2, energy, rmse, 20*log10(255/rmse));
end
set(gcf, 'paperposition', [0 0 6 6.6]);
save_fig('recon_grid');

figure(4, 'visible', VIS);
colormap(gray(256));
subplot(1,3,1); imshow(zonal_mask(8, N)(1:16,1:16));   axis on; title('A, j = 8 (16x16 corner)');
subplot(1,3,2); imshow(zonal_mask(128, N));            axis on; title('A, j = 128');
set(gca, 'xtick', [1 128 256], 'ytick', [1 128 256]);
subplot(1,3,3); imshow(abs(img - idct2(X .* zonal_mask(128, N))), []);
title('|original - recon|, j = 128');
set(gcf, 'paperposition', [0 0 9 3]);
save_fig('masks_and_error');

% ================================================================= block DCT

% MATLAB's blockproc hands the function a struct (b.data); Octave's hands the
% raw block. This keeps the spec's @(b) idct2(b.data) form working in both.
function d = bdata(b)
    if isstruct(b), d = b.data; else, d = b; end
end

funcao_dct  = @(b) dct2(bdata(b));
funcao_idct = @(b) idct2(bdata(b));

printf('\nOriginal, first 8x8 pixels:\n');
disp(img(1:8,1:8));

for B = [4 8 16 32]
    T = blockproc(img, [B B], funcao_dct);

    % Same zonal triangle as before, inside each block: keep u + v <= B/2 + 1.
    M  = zonal_mask(B/2, B);
    Tz = blockproc(T, [B B], @(b) bdata(b) .* M);

    R  = blockproc(T,  [B B], funcao_idct);
    Rz = blockproc(Tz, [B B], funcao_idct);

    % Same 8x8 window for every B: holds 4 blocks when B = 4, part of one otherwise.
    printf('\n--- B = %d ---\n', B);
    printf('Transformed, first 8x8:\n');                     disp(round(T(1:8,1:8)));
    printf('Zeroed, first 8x8:\n');                          disp(round(Tz(1:8,1:8)));
    printf('Reconstructed from zeroed, first 8x8 pixels:\n'); disp(round(Rz(1:8,1:8)));
    printf('max |error| in that window: %.2f\n\n', max(max(abs(Rz(1:8,1:8) - img(1:8,1:8)))));

    rmse = sqrt(mean((Rz(:) - img(:)).^2));
    printf('%5s %10s %12s %8s %8s\n', 'B', 'kept (%)', 'max|rec-x|', 'RMSE', 'PSNR');
    printf('%5d %10.2f %12.2e %8.2f %8.2f\n', B, 100 * sum(M(:)) / B^2, ...
           max(abs(R(:) - img(:))), rmse, 20*log10(255/rmse));

    figure(10+B, 'visible', VIS);
    colormap(gray(256));
    subplot(1,3,1); imagesc(log(1 + abs(T))); axis image off;
    title(sprintf('Block DCT %dx%d', B, B));
    subplot(1,3,2); imshow(Rz, [0 255]); title(sprintf('Zeroed, %dx%d', B, B));
    % Zoom on the eye region, where block edges are easiest to see.
    subplot(1,3,3); imshow(Rz(100:163,100:163), [0 255]); title('Zoom');
    % 1x3 layout: a short page avoids the empty bands above and below.
    set(gcf, 'paperposition', [0 0 9 3]);
    save_fig(sprintf('block_%02d', B));
end
