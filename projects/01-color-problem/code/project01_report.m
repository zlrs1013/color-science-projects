%% project 01
% author Zhen Lai

%%
% a) read in the image you captured
img = imread('../data/SE03_01.jpg');
imshow(img)
%% 
% b) if necessary, rotate the image so the chart is level

% J = imrotate(I,angle,method)
% [j, rect] = imcrop(img)
%% 
% c) crop the chart and samples out of the main image

% use the crop image tool

colorChart= imcrop(img)
% colorChart= imcrop(img_main,[262.5 510.5 2720 1900]);
imshow(colorChart)

% samples = imcrop(img_main, [3046.5 1686.5 520 700]);
samples = imcrop(img)
imshow(samples)
%% 
% d) resize the chart crop to be 1125 X 800 pixels 

% targetSize_chart = [800 1125];
colorChart = imresize(colorChart,[800 1125]);
imshow(colorChart)
% what scaling algorithm used? any impact on color?
%% 
% e) resize the samples crop to be 225 X 300 pixels

samples = imresize(samples,[300 225]);
imshow(samples)
%% 
% f) save the chart crop as "chart.jpg"

imwrite(colorChart, '../results/chart.jpg')
%% 
% g) save the samples crop as "samples.jpg"

imwrite(samples, '../results/samples.jpg')
