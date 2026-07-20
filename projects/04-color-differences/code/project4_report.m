%% Project 4 report 
% Zhen Lai 10/22/2024
%
% This project develops a workflow for converting spectral reflectance data
% into CIE XYZ and CIELAB values and then measuring perceptual color
% differences with Delta E*ab.
%
% * Step 2 uses a vectorized |ref2XYZ| function so multiple reflectance
%   spectra can be converted to XYZ simultaneously.
% * Step 3 tests that conversion with the 24 patches of a ColorChecker under
%   CIE illuminant D65 and the CIE 1931 2-degree standard observer.
% * Steps 4 and 5 introduce |XYZ2Lab| and use the D65 perfect-diffuser white
%   point to convert the ColorChecker XYZ values to CIELAB.
% * Step 6 repeats the conversion after reducing the ColorChecker
%   reflectances to 2 percent of their original values. This demonstrates
%   CIELAB behavior for very dark samples.
% * Steps 7 and 8 introduce the CIE 1976 Delta E*ab calculation and compare
%   the ColorChecker with a MetaChecker under D65 and illuminant A. The
%   MetaChecker contains different reflectance spectra designed to produce
%   similar colors under one illuminant but different colors under another,
%   demonstrating illuminant metamerism.
% * Step 9 applies the same XYZ, CIELAB, and Delta E*ab calculations to the
%   physical/real, imaged, and visually matched paint-patch measurements 
%   collected in Project 2.
% * Step 10 plots the paint-patch results in the CIELAB a*-b* plane, including
%   reference circles that provide visual context for the color differences.

repo_dir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(repo_dir, 'shared'));
paths = imgs351Paths(repo_dir);
addpath(paths.p03.code, paths.p04.code);

%% step 2 - modify function ref2XYZ
% Modify the ref2XYZ function so it can simultaneously process multiple
% reflectance spectra (ref(s)). 
%
% <include>ref2XYZ.m</include>

%% step 3 - test function ref2XYZ 
% test the modified ref2XYZ function with ColorChecker reflectance values

% load CIE data
cie = loadCIEdata;

% load ColorChecker spectra data
CC_spectra = load(fullfile(paths.p04.data, ...
    'ColorChecker_380-780-5nm.txt'));

% calculate XYZ values for ColorChecker patches
CC_XYZs = ref2XYZ(CC_spectra(:, 2:25), cie.cmf2deg, cie.illD65);

% display ColorChecker XYZ values
CC_XYZs

%% step 4 - create function XYZ2Lab
% Create a function that takes as inputs XYZ and XYZn and returns CIELab. 
%
% <include>XYZ2Lab.m</include>

%% step 5 - test XYZ2Lab function using ColorChecker

% compute the XYZ values of D65 for XYZn in XYZ2Lab
XYZn_D65 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD65);

% calculate the Lab values
CC_Labs = XYZ2Lab(CC_XYZs, XYZn_D65);

% read in the names of the ColorChecker patches 
names = cellstr(readlines(fullfile(paths.p04.data, ...
    'ColorChecker_names.txt')));

% print the formatted table
% header
fprintf('\n%s\n', "ColorChecker XYZ and Lab values (D65 illuminant and 2 deg. observer)");
fprintf('%5s %2s %5s %7s %7s %7s %7s %7s    %-13s\n', 'Patch', '#', ...
    'X', 'Y', 'Z', 'L*', 'a*', 'b*', 'Patch Name');
% loop to print the patch values
for i = 1:size(CC_Labs, 2)
    fprintf('      %2d %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f  %-13s\n', i, ...
        CC_XYZs(1,i), CC_XYZs(2,i), CC_XYZs(3,i), ...
        CC_Labs(1,i), CC_Labs(2,i), CC_Labs(3,i), names{i});
end

%% step 6 - test XYZ2Lab function using darker ColorChecker

% multiply all the ColorChecker spectra by 0.02
CC_spectra_darker = CC_spectra .* 0.02;

% calculate the XYZ values for darker ColorChecker
CC_XYZs_darker = ref2XYZ(CC_spectra_darker(:, 2:25), cie.cmf2deg, cie.illD65);

% calculate the Lab values for darker ColorChecker
CC_Labs_darker = XYZ2Lab(CC_XYZs_darker, XYZn_D65);

% read in the names of the ColorChecker patches 
names = cellstr(readlines(fullfile(paths.p04.data, ...
    'ColorChecker_names.txt')));

% print the formatted table
% header
fprintf('\n%s\n', "ColorChecker(Dark) XYZ and Lab values (D65 illuminant and 2 deg. observer)");
fprintf('%5s %2s %5s %7s %7s %7s %7s %7s    %-13s\n', 'Patch', '#', ...
    'X', 'Y', 'Z', 'L*', 'a*', 'b*', 'Patch Name');
% loop to print the patch values
for i = 1:size(CC_Labs, 2)
    fprintf('      %2d %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f  %-13s\n', i, ...
        CC_XYZs_darker(1,i), CC_XYZs_darker(2,i), CC_XYZs_darker(3,i), ...
        CC_Labs_darker(1,i), CC_Labs_darker(2,i), CC_Labs_darker(3,i), names{i});
end

%% step 7 - create function deltaEab
% Create a function that takes 2 sets of CIELAB values and return the DEab
% values
%
% <include>deltaEab.m</include>

%% step 8 - test deltaEab function

% calculate the XYZ of the standard ColorChecker and the MetaChecker 
% under illuminant D65 and illuminant A

% compute the XYZ values of A
XYZn_A = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illA);

% ColorChecker XYZ value under D65
CC_XYZs_D65 = CC_XYZs;
% calculate ColorChecker XYZ value under A
CC_XYZs_A = ref2XYZ(CC_spectra(:, 2:25), cie.cmf2deg, cie.illA);
% CIELab values of ColorChecker under D65
CC_Labs_D65 = CC_Labs;
% calculate the CIELab values of ColorChecker under A
CC_Labs_A = XYZ2Lab(CC_XYZs_A, XYZn_A);

% load MetaChecker spectra data 
MetaCC_spectra = load(fullfile(paths.p04.data, ...
    'MetaChecker_380-780-5nm.txt'));
% calculate MetaChecker XYZ value under D65
MetaCC_XYZs_D65 = ref2XYZ(MetaCC_spectra(:, 2:25), cie.cmf2deg, cie.illD65);
% calculate MetaChecker XYZ value under A
MetaCC_XYZs_A = ref2XYZ(MetaCC_spectra(:, 2:25), cie.cmf2deg, cie.illA);
% calculate the Lab values of MetaChecker under D65
MetaCC_Labs_D65 = XYZ2Lab(MetaCC_XYZs_D65, XYZn_D65);
% calculate the Lab values of MetaChecker under A
MetaCC_Labs_A = XYZ2Lab(MetaCC_XYZs_A, XYZn_A);

% compute the color difference under D65
deltaEab_D65 = deltaEab(CC_Labs_D65, MetaCC_Labs_D65);
% compute the color difference under A
deltaEab_A = deltaEab(CC_Labs_A, MetaCC_Labs_A);

% print the color difference under different illuminants
% header
fprintf('\n%s\n', "ColorChecker and MetaChecker color difference");
fprintf('%5s %2s  %9s  %9s\n', 'Patch', '#', 'DEab(D65)', 'DEab(illA)');
% loop to print the patch values
for i = 1:size(deltaEab_D65, 2)
    fprintf('      %2d  %9.3e  %6.3f\n', i, deltaEab_D65(i), deltaEab_A(i));
end

%% step 9 - calculate CIELab and color difference for paint patches

% define ColorMunki/Argyll/spotread measurement wavelengths
cm_lams = 380:10:730;

% define header offsets for reading the .sp files
cm_g_offset_spotread = 19;
cm_g_offset_spotreadt = 18;

% load and normalize the measured spectral data for the patch 3.1
data_real31 = importdata(fullfile(paths.p02.data, 'colormunki_data', ...
    'real', '3.1_real.sp'), ' ', ...
    cm_g_offset_spotread);
real_31 = data_real31.data/100;

data_imaged31 = importdata( ...
    fullfile(paths.p02.data, 'colormunki_data', 'imaged', ...
    '3.1_imaged.sp'), ' ', ...
    cm_g_offset_spotreadt);
imaged_31 = data_imaged31.data/100;

data_matching31 = importdata( ...
    fullfile(paths.p02.data, 'colormunki_data', 'matched', ...
    '3.1_matching.sp'), ' ', ...
    cm_g_offset_spotreadt);
matching_31 = data_matching31.data/100;

% load and normalize the measured spectral data for the patch 3.2
data_real32 = importdata(fullfile(paths.p02.data, 'colormunki_data', ...
    'real', '3.2_real.sp'), ' ', ...
    cm_g_offset_spotread);
real_32 = data_real32.data/100;

data_imaged32 = importdata( ...
    fullfile(paths.p02.data, 'colormunki_data', 'imaged', ...
    '3.2_imaged.sp'), ' ', ...
    cm_g_offset_spotreadt);
imaged_32 = data_imaged32.data/100;

data_matching32 = importdata( ...
    fullfile(paths.p02.data, 'colormunki_data', 'matched', ...
    '3.2_matching.sp'), ' ', ...
    cm_g_offset_spotreadt);
matching_32 = data_matching32.data/100;


% INTERPOLATE/EXTRAPOLATE DATA

interpolated_real_31 = interp1(cm_lams, transpose(real_31), cie.lambda(:), 'linear', ...
    'extrap');
interpolated_imaged_31 = interp1(cm_lams, transpose(imaged_31), cie.lambda(:), ...
    'linear', 'extrap');
interpolated_matching_31 = interp1(cm_lams, transpose(matching_31), cie.lambda(:), ...
    'linear', 'extrap');

interpolated_real_32 = interp1(cm_lams, transpose(real_32), cie.lambda(:), 'linear', ...
    'extrap');
interpolated_imaged_32 = interp1(cm_lams, transpose(imaged_32), cie.lambda(:), ...
    'linear', 'extrap');
interpolated_matching_32 = interp1(cm_lams, transpose(matching_32), cie.lambda(:), ...
    'linear', 'extrap');


% CALCULATING XYZ

% Calculate the tristimulus values and chromaticity coordinates 
% for patch 3.1
XYZ_real_31 = ref2XYZ(interpolated_real_31, cie.cmf2deg, cie.illD50);
% XYZ_real_31 = reshape(XYZ_real_31, 3, 1);

XYZ_imaged_31 = ref2XYZ(interpolated_imaged_31, cie.cmf2deg, cie.illD50);
% XYZ_imaged_31 = reshape(XYZ_imaged_31, 3, 1);

XYZ_matching_31 = ref2XYZ(interpolated_matching_31, cie.cmf2deg, cie.illD50);
% XYZ_matching_31 = reshape(XYZ_matching_31, 3, 1);

% Calculate the tristimulus values and chromaticity coordinates 
% for patch 3.2
XYZ_real_32 = ref2XYZ(interpolated_real_32, cie.cmf2deg, cie.illD50);
% XYZ_real_32 = reshape(XYZ_real_32, 3, 1);

XYZ_imaged_32 = ref2XYZ(interpolated_imaged_32, cie.cmf2deg, cie.illD50);
% XYZ_imaged_32 = reshape(XYZ_imaged_32, 3, 1);

XYZ_matching_32 = ref2XYZ(interpolated_matching_32, cie.cmf2deg, cie.illD50);
% XYZ_matching_32 = reshape(XYZ_matching_32, 3, 1);


% CALCULATE CIELab

% compute the XYZ values of D50
XYZn_D50 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD50);

% patch 3.1
Lab_real_31 = XYZ2Lab(XYZ_real_31, XYZn_D50);
Lab_imaged_31 = XYZ2Lab(XYZ_imaged_31, XYZn_D50);
Lab_matching_31 = XYZ2Lab(XYZ_matching_31, XYZn_D50);

% patch 3.2
Lab_real_32 = XYZ2Lab(XYZ_real_32, XYZn_D50);
Lab_imaged_32 = XYZ2Lab(XYZ_imaged_32, XYZn_D50);
Lab_matching_32 = XYZ2Lab(XYZ_matching_32, XYZn_D50);


% CALCULATE DELTAEAB

% compute the color difference for patch 3.1
deltaEab_imaged_31 = deltaEab(Lab_real_31, Lab_imaged_31);
deltaEab_matching_31 = deltaEab(Lab_real_31, Lab_matching_31);

% compute the color difference for patch 3.2
deltaEab_imaged_32 = deltaEab(Lab_real_32, Lab_imaged_32);
deltaEab_matching_32 = deltaEab(Lab_real_32, Lab_matching_32);


% LISTING MEASURED AND CALCULATED XYZ

% print title
fprintf('\n%s\n', "Calculated XYZ, Lab, and deltaE values (w.r.t. real patches)")

% print first table for patch 3.1
fprintf('\n                                   %8s\n', 'patch 3.1')
fprintf('%5s  %8s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', 'X', 'Y', 'Z', 'L', 'a', 'b', 'dEab')
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'real', XYZ_real_31, Lab_real_31)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f %8.4f\n', 'imaged', XYZ_imaged_31, Lab_imaged_31, deltaEab_imaged_31)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f %8.4f\n', 'matching', XYZ_matching_31, Lab_matching_31, deltaEab_matching_31)

% print second table for patch 3.2
fprintf('\n                                   %8s\n', 'patch 3.2')
fprintf('%5s  %8s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', 'X', 'Y', 'Z', 'L', 'a', 'b', 'dEab')
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'real', XYZ_real_32, Lab_real_32)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f %8.4f\n', 'imaged', XYZ_imaged_32, Lab_imaged_32, deltaEab_imaged_32)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f %8.4f\n', 'matching', XYZ_matching_32, Lab_matching_32, deltaEab_matching_32)

%% step 10 - visualize color difference of paint patches

figure;
hold on
grid on

% patch 3.1
plot(Lab_real_31(2,1), Lab_real_31(3,1), 'o', 'MarkerFaceColor', 'b', ...
    'Color', 'b', 'MarkerSize', 4)
plot(Lab_imaged_31(2), Lab_imaged_31(3),'square', 'MarkerFaceColor', 'b', ...
    'Color', 'b', 'MarkerSize', 4)
plot(Lab_matching_31(2), Lab_matching_31(3),'diamond','MarkerFaceColor', 'b', ...
    'Color', 'b', 'MarkerSize', 4)

% patch 3.2
plot(Lab_real_32(2),Lab_real_32(3),'o','MarkerFaceColor', 'r', 'Color', ...
    'r', 'MarkerSize', 4)
plot(Lab_imaged_32(2),Lab_imaged_32(3),'square','MarkerFaceColor', 'r','Color', ...
    'r', 'MarkerSize', 4)
plot(Lab_matching_32(2),Lab_matching_32(3),'diamond','MarkerFaceColor', 'r', 'Color', ...
    'r', 'MarkerSize', 4)

% JND reference circles for the Lab of the real patches
axis square
viscircles([Lab_real_31(2) Lab_real_31(3)], 2.5, 'Color','b', 'LineWidth', 0.5);
viscircles([Lab_real_32(2),Lab_real_32(3)], 2.5, 'Color','r', 'LineWidth', 0.5);

fontsize(gcf, scale=0.9)

hold off

xlim([-60 60])
ylim([-60 60])
xticks(-60:10:60)
yticks(-60:10:60)
xlabel('a*')
ylabel('b*')
legend({'3.1 real', '3.1 imaged', '3.1 matching', '3.2 real', '3.2 imaged',  ...
    '3.2 matching'}, 'Location', 'southeast');
