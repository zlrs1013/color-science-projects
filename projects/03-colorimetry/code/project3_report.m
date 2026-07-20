%% Project 3 report 
% Zhen Lai 10/3/2024

repo_dir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(repo_dir, 'shared'));
paths = imgs351Paths(repo_dir);
addpath(paths.p03.code);

%% step 2 - define function loadCIEdata
% Define a MATLAB function that returns a structure of CIE observer and
% illuminant data. Below is the function.
%
% <include>loadCIEdata.m</include>

%% step 3a - plot blackbody and standard illuminant spectra

% blackbody and standard illuminant spectra
% normalizing standard illuminant SPD data to 1.0 at 560nm
cie = loadCIEdata;
illA = transpose(0.01 * cie.illA);
illD50 = transpose(0.01 * cie.illD50);
illD65 = transpose(0.01 * cie.illD65);

% set x axis
xs = transpose(cie.lambda);

figure;
hold on;
% blackbody (2856K)
plot(xs,blackbody(2856, xs), 'k');

% blackbody (5003K)
plot(xs,blackbody(5003, xs), 'r');

% blackbody 6504K
plot(xs,blackbody(6504, xs), 'b');

% illuminant A
plot(xs, illA, '--k');

% illuminant D50
plot(xs, illD50, '--r');

% illuminant D65
plot(xs, illD65, '--b');
hold off;

xlim([350 800])
ylim([0 2.5])
yticks(0:(2.5/5):2.5)
xlabel('wavelength(nm)')
ylabel('relative power')
legend({'blackbody (2856K)','blackbody (5003K)','blackbody (6504K)', ...
    'illuminant A', 'illuminant D50', 'illuminant D65'}, ...
    'Location','northwest');
title('blackbody and standard illuminant spectra')

%% step 3b -  plot CIE standard observer CMFs

% CIE standard observer CMFs

% set x axis
xs = transpose(cie.lambda);

% get cmf 2 deg. data
cmf2deg_x = transpose(cie.cmf2deg(:,1));
cmf2deg_y = transpose(cie.cmf2deg(:,2));
cmf2deg_z = transpose(cie.cmf2deg(:,3));

% get cmf 10 deg. data
cmf10deg_x = transpose(cie.cmf10deg(:,1));
cmf10deg_y = transpose(cie.cmf10deg(:,2));
cmf10deg_z = transpose(cie.cmf10deg(:,3));

figure;
hold on;

% x_bar 2 deg.
plot(xs, cmf2deg_x, 'r')

% y_bar 2 deg.
plot(xs, cmf2deg_y, 'g')

% z_bar 2 deg.
plot(xs, cmf2deg_z, 'b')

% x_bar 10 deg.
plot(xs, cmf10deg_x, '--r')

% y_bar 10 deg.
plot(xs, cmf10deg_y, '--g')

% z_bar 10 deg.
plot(xs, cmf10deg_z, '--b')
hold off;

xlim([350 800])
ylim([0 2.5])
yticks(0:(2.5/5):2.5)
xlabel('wavelength(nm)')
ylabel('tristimulus values')
legend('x_{bar} 2 deg.','y_{bar} 2 deg.','z_{bar} 2 deg.', ...
    'x_{bar} 10 deg.','y_{bar} 10 deg.','z_{bar} 10 deg.');
title('CIE standard observer CMFs')

%% step 4 - define ref2XYZ function
% Define a MATLAB function that returns XYZ tristimulus values from surface
% reflectance, color matching function and illumination data. Below is the 
% function.
%
% <include>ref2XYZ.m</include>

%% step 5 - calculate ColorChecker XYZ values

% load CIE observer and illuminant data
cie = loadCIEdata;

% load color check reflectance data
cc_spectra = importdata(fullfile(paths.p03.data, ...
    'ColorChecker_380_780_5nm.txt'));

% calculate XYZ tristimulus values for each patch in the color checker
CC_XYZs = zeros(3, 24);
for patch_num = 2:25
    CC_XYZs(:, patch_num-1) = ref2XYZ(cc_spectra(:, patch_num), cie.cmf2deg, cie.illD65);
end

% display the XYZ tristimulus values
CC_XYZs

%% step 6 - define XYZ2xyY function
% Define a MATLAB function that returns the x, y chromaticity coordinates
% and Y luminance factor from XYZ tristimulus values
%
% <include>XYZ2xyY.m</include>

%% step 7 - calculate ColorChecker xyY values

CC_xyYs = XYZ2xyY(CC_XYZs);

% display the xyY values
CC_xyYs

%% step 8 - load painted patches spectra data

% load the CIE observer and illuminant data
cie = loadCIEdata;

% define ColorMunki/Argyll/spotread measurement wavelengths
cm_lams = 380:10:730;

% define header offsets for reading the .sp files
cm_g_offset_spotread = 19;
cm_g_offset_spotreadt = 18;

% load and normalize the measured spectral data for the patch 3.1
data_real31 = importdata(fullfile(paths.p02.data, 'colormunki_data', ...
    'real', '3.1_real.sp'), ...
    ' ', cm_g_offset_spotread);
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
    'real', '3.2_real.sp'), ...
    ' ', cm_g_offset_spotread);
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

%% step 9 - plot the measured and interpolated spectra for paint patches

% INTERPOLATE/EXTRAPOLATE DATA

% patch 3.1
interpolated_real_31 = interp1(cm_lams, transpose(real_31), ...
    cie.lambda(:), 'linear', 'extrap');
interpolated_imaged_31 = interp1(cm_lams, transpose(imaged_31), ...
    cie.lambda(:), 'linear', 'extrap');
interpolated_matching_31 = interp1(cm_lams, transpose(matching_31), ...
    cie.lambda(:), 'linear', 'extrap');

% patch 3.2
interpolated_real_32 = interp1(cm_lams, transpose(real_32), ...
    cie.lambda(:), 'linear', 'extrap');
interpolated_imaged_32 = interp1(cm_lams, transpose(imaged_32), ...
    cie.lambda(:), 'linear', 'extrap');
interpolated_matching_32 = interp1(cm_lams, transpose(matching_32), ...
    cie.lambda(:), 'linear', 'extrap');


% PLOTTING INTERPOLATED SPECTRA
% set x axes
measured_xs = cm_lams;
interpolated_xs =  transpose(cie.lambda);

% measured and interpolated spectra patch 3.1
figure;
hold on;
% measured
plot(measured_xs, real_31, 'or', 'LineWidth', 0.5)
plot(measured_xs, imaged_31, 'og', 'LineWidth', 0.5)
plot(measured_xs, matching_31, 'ob', 'LineWidth', 0.5)

% interpolated
plot(interpolated_xs, interpolated_real_31, ':', 'Color', 'black', 'LineWidth', 1.5)
plot(interpolated_xs, interpolated_imaged_31, ':', 'Color', 'black', 'LineWidth', 1.5)
plot(interpolated_xs, interpolated_matching_31, ':', 'Color', 'black', 'LineWidth', 1.5)
hold off

xlim([350 800])
ylim([0 1])
yticks(0:(1/10):1)
xlabel('wavelength(nm)')
ylabel('reflectance factor')
legend({'real measured', 'imaged measured', 'matching measured', ['real ' ...
    'interpolated'], 'imaged interpolated', 'matching interpolated'}, ...
    'Location', 'southeast');
title('patch 3.1 measured and interpolated spectra')

% measured and interpolated spectra patch 3.2
figure;
hold on;
% measured
plot(measured_xs, real_32, 'or', 'LineWidth', 0.5)
plot(measured_xs, imaged_32, 'og', 'LineWidth', 0.5)
plot(measured_xs, matching_32, 'ob', 'LineWidth', 0.5)

% interpolated
plot(interpolated_xs, interpolated_real_32, ':', 'Color', 'black', 'LineWidth', 1.5)
plot(interpolated_xs, interpolated_imaged_32, ':', 'Color', 'black', 'LineWidth', 1.5)
plot(interpolated_xs, interpolated_matching_32, ':', 'Color', 'black', 'LineWidth', 1.5)
hold off

xlim([350 800])
ylim([0 1])
yticks(0:(1/10):1)
xlabel('wavelength(nm)')
ylabel('reflectance factor')
legend({'real measured', 'imaged measured', 'matching measured', ['real ' ...
    'interpolated'], 'imaged interpolated', 'matching interpolated'}, ...
    'Location', 'northwest');
title('patch 3.2 measured and interpolated spectra')

%% step 10 - list measured and calculated XYZ values for paint patches

% CALCULATING XYZs
% calculate the tristimulus values and chromaticity coordinates 
% for patch 3.1
XYZ_real_31 = ref2XYZ(interpolated_real_31, cie.cmf2deg, cie.illD50);
XYZ_real_31 = reshape(XYZ_real_31, 3, 1);

XYZ_imaged_31 = ref2XYZ(interpolated_imaged_31, cie.cmf2deg, cie.illD50);
XYZ_imaged_31 = reshape(XYZ_imaged_31, 3, 1);

XYZ_matching_31 = ref2XYZ(interpolated_matching_31, cie.cmf2deg, cie.illD50);
XYZ_matching_31 = reshape(XYZ_matching_31, 3, 1);

% calculate the tristimulus values and chromaticity coordinates 
% for patch 3.2
XYZ_real_32 = ref2XYZ(interpolated_real_32, cie.cmf2deg, cie.illD50);
XYZ_real_32 = reshape(XYZ_real_32, 3, 1);

XYZ_imaged_32 = ref2XYZ(interpolated_imaged_32, cie.cmf2deg, cie.illD50);
XYZ_imaged_32 = reshape(XYZ_imaged_32, 3, 1);

XYZ_matching_32 = ref2XYZ(interpolated_matching_32, cie.cmf2deg, cie.illD50);
XYZ_matching_32 = reshape(XYZ_matching_32, 3, 1);

% LISTING MEASURED AND CALCULATED XYZs
% load measured data
load(fullfile(paths.p02.data, 'patchColorimetryData.mat'))

% print title
fprintf('\n%s\n', "Measured and calculated tristimulus values")

% print first table for patch 3.1
fprintf('\n                              %8s\n', 'patch 3.1')
fprintf('                     %8s                    %10s \n', 'measured', 'calculated')
fprintf('%5s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', 'X', 'Y', 'Z', 'X', 'Y', 'Z')
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'real', ...
    XYZLabsreal(1,2:4), XYZ_real_31)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'imaged', ...
    XYZLabsimaged(1,2:4), XYZ_imaged_31)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'matching', ...
    XYZLabsmatching(1,2:4), XYZ_matching_31)

% print second table for patch 3.2
fprintf('\n                              %8s\n', 'patch 3.2')
fprintf('                     %8s                    %10s \n', 'measured', 'calculated')
fprintf('%5s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', 'X', 'Y', 'Z', 'X', 'Y', 'Z')
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'real', ...
    XYZLabsreal(2,2:4), XYZ_real_32)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'imaged', ...
    XYZLabsimaged(2,2:4), XYZ_imaged_32)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'matching', ...
    XYZLabsmatching(2,2:4), XYZ_matching_32)

%% step 11 - list measured and calculated chromaticity coordinates for paint patches

% CALCULATING xyY
% xyY from calculated XYZ 
xyY_real_31 = XYZ2xyY(XYZ_real_31);
xyY_imaged_31 = XYZ2xyY(XYZ_imaged_31);
xyY_matching_31 = XYZ2xyY(XYZ_matching_31);

xyY_real_32 = XYZ2xyY(XYZ_real_32);
xyY_imaged_32 = XYZ2xyY(XYZ_imaged_32);
xyY_matching_32 = XYZ2xyY(XYZ_matching_32);

% xyY from measured XYZ
xyY_real_31_measured = XYZ2xyY(XYZLabsreal(1,2:4)');
xyY_imaged_31_measured = XYZ2xyY(XYZLabsimaged(1,2:4)');
xyY_matching_31_measured = XYZ2xyY(XYZLabsmatching(1,2:4)');

xyY_real_32_measured = XYZ2xyY(XYZLabsreal(2,2:4)');
xyY_imaged_32_measured = XYZ2xyY(XYZLabsimaged(2,2:4)');
xyY_matching_32_measured = XYZ2xyY(XYZLabsmatching(2,2:4)');

% LISTING xyY
% print title
fprintf('\n%s\n', "Measured and calculated chromaticity coordinates")

% print first table for patch 3.1
fprintf('\n%8s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', '', '','patch 3.1', '', '', '')
fprintf('%8s  %8s  %8s  %8s  %8s  %10s  %8s\n', '', '', 'measured','', '', 'calculated', '')
fprintf('%5s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', 'x', 'y', 'Y', 'x', 'y', 'Y')
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'real', ...
    xyY_real_31_measured, xyY_real_31)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'imaged', ...
    xyY_imaged_31_measured, xyY_imaged_31)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'matching', ...
    xyY_matching_31_measured, xyY_matching_31)

% print second table for patch 3.2
fprintf('\n%8s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', '', '','patch 3.2', '', '', '')
fprintf('%8s  %8s  %8s  %8s  %8s  %10s  %8s\n', '', '', 'measured','', '', 'calculated', '')
fprintf('%5s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', 'x', 'y', 'Y', 'x', 'y', 'Y')
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'real', ...
    xyY_real_32_measured, xyY_real_32)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'imaged', ...
    xyY_imaged_32_measured, xyY_imaged_32)
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'matching', ...
    xyY_matching_32_measured, xyY_matching_32)

%% step 12 - visualize chromaticity coordinates of paint patches on chromaticity diagram

% plot chromaticity diagram
plot_chrom_diag_skel;
hold on;

% plot patch 3.1 calculated chromaticity coordinates 
plot(xyY_real_31(1,1),xyY_real_31(2,1),'square','Color', 'red')
plot(xyY_imaged_31(1,1),xyY_imaged_31(2,1),'diamond','Color', 'red')
plot(xyY_matching_31(1,1),xyY_matching_31(2,1),'+','Color', 'red')

% plot patch 3.2 calculated chromaticity coordinates 
plot(xyY_real_32(1,1),xyY_real_32(2,1),'square','Color', 'blue')
plot(xyY_imaged_32(1,1),xyY_imaged_32(2,1),'diamond','Color', 'blue')
plot(xyY_matching_32(1,1),xyY_matching_32(2,1),'+','Color', 'blue')

fontsize(gcf, scale=0.7)

hold off

%legend({'3.1 real', '3.1 imaged', '3.1 matching', '3.2 real', ...
    %'3.2 imaged', '3.2 matching'}, 'Location', 'northeast');
legend({'','','','','','','','','','','','','','', '3.1 real', ...
    '3.1 imaged', '3.1 matching', '3.2 real', '3.2 imaged',  ...
    '3.2 matching'}, 'Location', 'northeast');
title('chromaticity coordinates of 3.1 and 3.2 patches')
