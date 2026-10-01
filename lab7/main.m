close all
clear all
clc

pkg load signal
pkg load image

global VIS = 'off';

if ~exist('plots', 'dir'), mkdir('plots'); end

fig = 'lena_c.jpg';

function img = read_img(name)
    root = './img/';
    X = imread([root name]);
    X = rgb2gray(X);
    img = double(X)./255;
end

img = read_img(fig);

