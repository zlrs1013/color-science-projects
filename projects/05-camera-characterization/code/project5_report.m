%% Project 5 report 
% Zhen Lai 11/02/2024
%
% This project characterizes the color response of an iPhone SE camera using
% a photographed ColorChecker and corresponding ColorMunki measurements. The
% resulting model converts camera RGB values into estimated CIE XYZ values.
%
% * Steps 3 and 4 assemble the camera RGB values and measured XYZ/CIELAB
%   reference values for the 24 ColorChecker patches.
% * Steps 5 through 8 use the six neutral patches to visualize the camera's
%   nonlinear tonal response, fit a cubic linearization curve for each RGB
%   channel, and compare the original and linearized patch values.
% * Steps 9 through 11 derive a baseline 3-by-3 linear RGB-to-XYZ matrix and
%   evaluate its accuracy using CIE 1976 Delta E*ab.
% * Steps 12 through 14 construct an extended 3-by-11 model containing RGB
%   interaction, squared, and constant terms, then evaluate its color error.
% * Steps 15 and 16 save the extended model and demonstrate the reusable
%   |camRGB2XYZ| conversion function.
% * Step 17 chromatically adapts the measured and camera-estimated XYZ values
%   from D50 to D65 and renders both sets as sRGB ColorChecker images for a
%   visual comparison.

repo_dir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(repo_dir, 'shared'));
paths = imgs351Paths(repo_dir);
addpath(paths.p03.code, paths.p04.code, paths.p05.code);

%% step 3 - extract camera RGB values for the gray-patch
% use PhotoShop to find the average RGB values for each patch in the chart
cam_RGBs = [89 53 39; 215 158 138; 79 103 147; 62 83 42; 119 114 170; 107 195 179;
            226 125 53; 32 53 146; 205 78 89; 51 22 66; 170 205 77; 236 177 73;
            3 3 103; 53 124 56; 163 23 32; 250 223 82; 182 63 131; 2 100 145;
            234 233 229; 197 196 194; 137 137 137; 86 88 87; 39 43 44; 5 6 8;];
cam_RGBs = cam_RGBs'

% normalize the RGB values by dividing the values by 255
cam_rgbs = cam_RGBs ./ 255

% extract the gray patches and flip their order from black to white
cam_gray_rgbs = fliplr(cam_rgbs(:, 19:end))

%% step 4 - extract measured gray-patch Y values

% load the ColorMunki measured XYZ and Lab values of the ColorChecker chart
% into 2 arrays for XYZ and Lab values respectively
munki_data = importdata(fullfile(paths.p05.data, ...
    'munki_CC_XYZs_Labs.txt'));
munki_XYZs = munki_data(:, 2:4)';
munki_Labs = munki_data(:, 5:end)';

% extract the gray-patch Y values, normalizing the values and flip the order
munki_gray_Ys = fliplr(munki_XYZs(2, 19:end) ./ 100)

%% step 5 - plot measured gray-patch Ys vs. camera RGB values

% assign each row to corresponding RGB channels 
r = 1;
g = 2;
b = 3;

% visualize camera's TTFs
figure;
hold on

% Ys vs Rs
plot(munki_gray_Ys, cam_gray_rgbs(r, :), "Color", 'r');
% Ys vs Gs
plot(munki_gray_Ys, cam_gray_rgbs(g, :), "Color", 'g');
% Ys vs Bs
plot(munki_gray_Ys, cam_gray_rgbs(b, :), "Color", 'b');

% adjust font size
fontsize(gcf, scale=0.9)

hold off

xlim([0 0.9])
ylim([0.1 0.9])
xticks(0:0.1:0.9)
yticks(0:0.1:0.9)
xlabel("munki gray Ys")
ylabel("camera gray RGBs")
title("original grayscale Y to RGB relationship")

%% step 6 - linearize camera's RGB response w.r.t relative luminance (Y)

% fit polynomial functions between the camera-captured gray-patch RGBs and
% the ColorMunk-measured gray-patch Ys
cam_polys(r, :) = polyfit(cam_gray_rgbs(r, :), munki_gray_Ys, 3);
cam_polys(g, :) = polyfit(cam_gray_rgbs(g, :), munki_gray_Ys, 3);
cam_polys(b, :) = polyfit(cam_gray_rgbs(b, :), munki_gray_Ys, 3);

% use the polynomial functions to linearize the camera's responses to the
% ColorChecker's 24 patches
cam_RSs(r, :) = polyval(cam_polys(r, :), cam_rgbs(r, :));
cam_RSs(g, :) = polyval(cam_polys(g, :), cam_rgbs(g, :));
cam_RSs(b, :) = polyval(cam_polys(b, :), cam_rgbs(b, :));

% clip out-of-range values, produced by quantization errors in the
% calculations
cam_RSs(cam_RSs < 0) = 0;
cam_RSs(cam_RSs > 1) = 1;

%% step 7 - plot measured gray-patch Ys vs linearized camera gray-patch RGBs

% extract gray-patch linear RGBs
cam_gray_RSs = fliplr(cam_RSs(:, 19:end));

figure;
hold on

% Ys vs Rs
plot(munki_gray_Ys, cam_gray_RSs(r, :), "Color", 'r');
% Ys vs Gs
plot(munki_gray_Ys, cam_gray_RSs(g, :), "Color", 'g');
% Ys vs Bs
plot(munki_gray_Ys, cam_gray_RSs(b, :), "Color", 'b');

% adjust font size
fontsize(gcf, scale=0.9)

hold off

xlim([0 0.9])
ylim([0.1 0.9])
xticks(0:0.1:0.9)
yticks(0:0.1:0.9)
xlabel("munki gray Ys")
ylabel("linearized camera gray RGBs (RSs)")
title("linearized grayscale Y to RGB relationship")

%% step 8 - visualize the pre- and post- linearization ColorChecker patches

% visualize the original camera RGBs
pix = reshape(cam_rgbs', [6 4 3]);
pix = uint8(pix * 255);
pix = imrotate(pix, -90);
pix = fliplr(pix);
figure;
image(pix);
title("original camera patch RGBs");

% visualize the linearized camera RGBs
pix = reshape(cam_RSs', [6 4 3]);
pix = uint8(pix * 255);
pix = imrotate(pix, -90);
pix = fliplr(pix);
figure;
image(pix);
title("linearized camera patch RGBs");

%% step 9 - derive a matrix to transform from linearized RGBs to XYZs

% use the munki-measured ColorChecker XYZs and camera-captured RGB RSs to
% derive a 3x3 matrix that can be used to estimate XYZs from camera RGBs
cam_matrix3x3 = munki_XYZs * pinv(cam_RSs)

%% step 10 - use the matrix to estimate XYZ values from linearized RGBs

% derive the estimate XYZs from basic 3x3 transformation matrix
cam_XYZs = cam_matrix3x3 * cam_RSs

%% step 11 - evaluate the accuracy of the camera color model

% use the XYZ2Lab function to calculate Lab values from the estimated XYZ 
% values
cie = loadCIEdata;
% use D50 as reference illuminate
XYZn_D50 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD50);
cam_Labs = XYZ2Lab(cam_XYZs, XYZn_D50);
cam_deltaE = deltaEab(munki_Labs, cam_Labs);

% print basic camera model error
print_camera_model_error(munki_Labs,cam_Labs, cam_deltaE)

%% step 12 - compensate for interactions and non-linearities 

% create a vector to represent the original set of radiometric scalars used
% to derive the 3x3 matrix plus additional terms that represent the
% products of the individual RGB channels (interactions) and squares of the
% individual RGB channels (non-linearities)

% split the radiometric scalars (cam_RSs) into r, g, b vectors
RSrgbs = cam_RSs;
RSrs = RSrgbs(r, :);
RSgs = RSrgbs(g, :);
RSbs = RSrgbs(b, :);

% create vectors of these RSs with multiplicative terms to represent
% interactions, and square terms to represent non-linearities in the
% RGB-to-XYZ relationship
RSrgbs_extd = [RSrgbs; RSrs .* RSgs; RSrs .* RSbs; RSgs .* RSbs; 
    RSrs .* RSgs .* RSbs; RSrs .^2; RSgs .^2; RSbs .^2; 
    ones(1, size(RSrgbs, 2))];

% find the extended (3x11) matrix that relates the RS and XYZ datasets
cam_matrix3x11 = munki_XYZs * pinv(RSrgbs_extd)

%% step 13 - estimate XYZs from the extended matrix and RS representation

% estimate XYZs from the RSs using the extended matrix and RS representation
cam_XYZs = cam_matrix3x11 * RSrgbs_extd

%% step 14 - evaluate the extended camera model by using deltaE

cam_Labs = XYZ2Lab(cam_XYZs, XYZn_D50);
cam_deltaE = deltaEab(munki_Labs, cam_Labs);

% print extended camera model error
print_camera_model_error(munki_Labs,cam_Labs, cam_deltaE)

%% step 15 - save the extended camera model

% save the (extended) camera model for use in later projects
save(fullfile(paths.p05.data, 'cam_model.mat'), ...
    "cam_polys", "cam_matrix3x11");

%% step 16 - create camRGB2XYZ function to convert camera RGBs to estimated XYZs
% create a function that converts camera-captured RGBs to XYZs based on the
% camera model derived above
%
% <include>camRGB2XYZ.m</include>

% test the function by using it to estimate XYZs from the cam_RGBs'
cam_XYZs = camRGB2XYZ(fullfile(paths.p05.data, 'cam_model.mat'), ...
    cam_RGBs)

%% step 17 - visualize camera model and camRGB2XYZ function

XYZn_D65 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD65);

% visualize the munki-measured XYZs as an sRGB image
munki_XYZs_D65 = catBradford(munki_XYZs, XYZn_D50, XYZn_D65);
munki_XYZs_sRGBs = XYZ2sRGB(munki_XYZs_D65);
pix = reshape(munki_XYZs_sRGBs', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = fliplr(pix);
figure;
image(pix);
title("munki XYZs chromatically adapted and visualized in sRGB");

% visualize the camera-estimated XYZs as an sRGB image
cam_XYZs_D65 = catBradford(cam_XYZs, XYZn_D50, XYZn_D65);
cam_XYZs_sRGBs = XYZ2sRGB(cam_XYZs_D65);
pix = reshape(cam_XYZs_sRGBs', [6 4 3]);
pix = uint8(pix*255);
pix = imrotate(pix, -90);
pix = fliplr(pix);
figure;
image(pix);
title("estimated XYZs chromatically adapted and visualized in sRGB");
