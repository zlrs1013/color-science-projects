%% Project 7 report 
% zl 12/1/2024
%
% This project used tools developed in earlier projects to analyze the
% sources of error in color imaging and perform end-to-end color-accurate
% colorimetric imaging using the camera and display models developed in previous
% projects.
%
% First, the color differences between the un-calibrated (camera image ->
% display) and the calibrated (camera image -> camera model -> estimated XYZs
% -> display model -> color-calibrated RGBs for the given display) imaging
% workflows were measured and compared. 
% Then, a figure that visualizes these differences were created. 
% Finally, 2 functions, camRGB2XYZ and XYZ2dispRGB, were used to process
% the ColorChecker image captured in project 1, so the colors were rendered
% correctly for the given display.
%

repo_dir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(repo_dir, 'shared'));
paths = imgs351Paths(repo_dir);
addpath(paths.p03.code, paths.p04.code, paths.p05.code, paths.p06.code);

%% step 1 - evaluate color accuracy of an un-calibrated imaging workflow 

% load the 8-bit RGB DCs of the ColorChecker patches extracted from camera
% image
camRGBs_255 = load(fullfile(paths.p07.data, 'camRGBs.mat'));
camRGBs_255 = camRGBs_255.cam_RGBs';

% workflow_test_uncal.ti1 stores these camera RGB stimuli plus repeated
% display-black and display-white measurements in ArgyllCMS format.

% use the ColorMunki colorimeter to measure the XYZs of the camera RGBs displayed on 
% the given display without using calibrated models

% load the measured XYZs 
uncal_XYZs = importdata(fullfile(paths.p07.data, ...
    'workflow_test_uncal.ti3'), ' ', 20);
% extract the XYZ data for the displayed CC patches
uncal_CC_XYZs = uncal_XYZs.data(1:24, 5:7)';
% for 3 measurements of display black and average them
uncal_XYZk = mean(uncal_XYZs.data(25:27, 5:7), 1)';
% for 3 measurements of display white and average them
uncal_XYZw = mean(uncal_XYZs.data(28:30, 5:7), 1)';

% calculate Lab values for the displayed CC patches from the XYZs
uncal_CC_Labs = XYZ2Lab(uncal_CC_XYZs, uncal_XYZw);

% load the ColorMunki measured XYZ and Lab values of the physical CC chart
% into 2 arrays for XYZ and Lab values respectively
munki_data = importdata(fullfile(paths.p07.data, ...
    'munki_CC_XYZs_Labs.txt'));
munki_XYZs = munki_data(:, 2:4)';
munki_Labs = munki_data(:, 5:end)';

% calculate the delta E to measure the color differences
uncal_deltaE = deltaEab(munki_Labs, uncal_CC_Labs);

% calculate the min, max and mean delta E values
uncal_deltaE_max = max(uncal_deltaE);
uncal_deltaE_min = min(uncal_deltaE);
uncal_deltaE_mean = mean(uncal_deltaE);

% summarize and display the differences between the real and displayed Lab
% values for the un-calibrated workflow
printWorkflowError('Uncalibrated', 'camera -> RGB_cam -> display', ...
    munki_Labs, uncal_CC_Labs, uncal_deltaE);

% delete temporary vars
clear munki_data uncal_XYZs


%% step 2 - reproduce the submitted calibrated-workflow evaluation
% The saved .ti3 measurements below were collected using the originally
% submitted RGB stimuli. The resulting Delta E values are historical results;
% physically validating the corrected camera/display conversion would require
% a new display-measurement session.

% load the 8-bit RGB DCs of the ColorChecker patches
camRGBs_255;

% put the RGB DCs through camRGB2XYZ function to calculate the XYZs of the
% patches
camXYZs = camRGB2XYZ(fullfile(paths.p05.data, 'cam_model.mat'), ...
    camRGBs_255);

% load the CIE data, calculate XYZs for D50 
cie = loadCIEdata;
XYZ_D50 = ref2XYZ(cie.PRD, cie.cmf2deg, cie.illD50);

% put the XYZs through XYZ2dispRGB function to estimate color-calibrated
% RGB 0-255 DCs for the given display
dispRGBs = XYZ2dispRGB(fullfile(paths.p06.data, 'display_model.mat'), ...
    camXYZs, XYZ_D50);

% workflow_test_cal.ti1 preserves the originally submitted calibrated RGB
% stimuli plus repeated black and white measurements. It is intentionally
% not regenerated from the corrected conversion above.

% load the measured XYZs 
cal_XYZs = importdata(fullfile(paths.p07.data, ...
    'workflow_test_cal.ti3'), ' ', 20);
% extract the XYZ data for the displayed CC patches
cal_CC_XYZs = cal_XYZs.data(1:24, 5:7)';
% for 3 measurements of display black and average them
cal_XYZk = mean(cal_XYZs.data(25:27, 5:7), 1)';
% for 3 measurements of display white and average them
cal_XYZw = mean(cal_XYZs.data(28:30, 5:7), 1)';

% calculate Lab values for the displayed CC patches from the XYZs
cal_CC_Labs = XYZ2Lab(cal_CC_XYZs, cal_XYZw);

% calculate the delta E to measure the color differences
cal_deltaE = deltaEab(munki_Labs, cal_CC_Labs);

% calculate the min, max and mean delta E values
cal_deltaE_max = max(cal_deltaE);
cal_deltaE_min = min(cal_deltaE);
cal_deltaE_mean = mean(cal_deltaE);

% summarize and display the differences between the real and displayed Lab
% values for the calibrated workflow
printWorkflowError('Calibrated', ...
    ['camera -> RGB_cam -> camera model -> estimated XYZ -> ' ...
    'display model -> RGB_disp -> display'], ...
    munki_Labs, cal_CC_Labs, cal_deltaE);

% delete temporary vars
clear cie cal_XYZs

%% step 3 - visualize the differences between ground-truth, un-calibrated and calibrated renderings of CC chart

% load the ground truth XYZ and Lab values of the CC chart
munki_XYZs;
munki_Labs;

% normalize XYZ values to range 0 - 1
munki_XYZs_normalized = munki_XYZs ./ 100;

% use xyz2srgb transform to calculate RGB values from XYZs
CC_RGBs = xyz2rgb(munki_XYZs_normalized', 'WhitePoint','d50', 'OutputType', 'uint8');

% create a 4x6x3 array to hold un-calibrated RGBs
camRGBs_255_reshaped = uint8(reshape(camRGBs_255', [6 4 3]));
camRGBs_255_reshaped = fliplr(imrotate(camRGBs_255_reshaped, -90));

% create a 4x6x3 array to hold calibrated RGBs
dispRGBs_reshaped = uint8(reshape(dispRGBs', [6 4 3]));
dispRGBs_reshaped = fliplr(imrotate(dispRGBs_reshaped, -90));

% create a 4x6x3 array to hold ground-truth RGBs
CC_RGBs_reshaped = uint8(reshape(CC_RGBs, [6 4 3]));
CC_RGBs_reshaped = fliplr(imrotate(CC_RGBs_reshaped, -90));

% Interleave ground-truth rows with pairs of uncalibrated/calibrated rows.
workflow_diffs = zeros(8, 12, 3, 'uint8');
workflow_diffs(1:2:end, 1:2:end, :) = CC_RGBs_reshaped;
workflow_diffs(1:2:end, 2:2:end, :) = CC_RGBs_reshaped;
workflow_diffs(2:2:end, 1:2:end, :) = camRGBs_255_reshaped;
workflow_diffs(2:2:end, 2:2:end, :) = dispRGBs_reshaped;

% visualize the array
figure;
image(uint8(workflow_diffs));
axis image off;
title({'ColorChecker workflow comparison', ...
    'Each 2-by-2 block represents one patch', ...
    ['Top-left and top-right: reference | Bottom-left: uncalibrated | ' ...
    'Bottom-right: calibrated']});

% resize the array to 768 x 1024 x 3 
workflow_diffs_resized = imresize3(workflow_diffs, 'OutputSize', [768 1024 3], 'Method', "nearest"); 

% save the resized array as a .png image
imwrite(uint8(workflow_diffs_resized), ...
    fullfile(paths.p07.results, 'final_render_corrected.png'));

clear CC_RGBs_reshaped camRGBs_255_reshaped dispRGBs_reshaped workflow_diffs_resized

%% step 4 - color-accurate imaging

% start with the original CC 1125x800 photo
img_orig = imread(fullfile(paths.p07.data, 'original_chart.jpg'));

% reshape the image into a pixel vector/[3 x n] RGB vector
[r, c, p] = size(img_orig);
pix_orig = reshape(img_orig, [r * c, p])';

% process the pixels through camera and display models derived in previous
% projects to calculate color-calibrated DCs
pix_DCs_calib = XYZ2dispRGB( ...
    fullfile(paths.p06.data, 'display_model.mat'), ...
    camRGB2XYZ(fullfile(paths.p05.data, 'cam_model.mat'), ...
    double(pix_orig)), XYZ_D50);

% reshape the pixels back into an 3-d array
img_calib = reshape(pix_DCs_calib', [r, c, p]);

% save the color-calibrated image
imwrite(uint8(img_calib), ...
    fullfile(paths.p07.results, 'color_calibrated_chart_corrected.png'));

clear r c p pix_orig pix_DCs_calib

%% compare the original and color calibrated images
% The two images are shown with the same dimensions for a direct visual
% comparison. The calibrated image is the result of applying the camera model
% followed by the display model.

imageComparisonFigure = figure('Color', 'w', 'Name', ...
    'Original and color-calibrated images');
imageComparisonLayout = tiledlayout(imageComparisonFigure, 1, 2, ...
    'TileSpacing', 'compact', 'Padding', 'compact');

nexttile(imageComparisonLayout);
imshow(img_orig);
title('Original camera image');

nexttile(imageComparisonLayout);
imshow(uint8(img_calib));
title('Color-calibrated image');

title(imageComparisonLayout, ...
    'Original and Color-Calibrated ColorChecker Images');

function printWorkflowError(workflowName, workflowPath, referenceLabs, ...
    displayedLabs, deltaEs)
%PRINTWORKFLOWERROR Summarize measured and displayed ColorChecker errors.

tableValues = [(1:24)', referenceLabs', displayedLabs', deltaEs'];

fprintf('\n\n%s workflow color error\n', workflowName);
fprintf('%s\n\n', workflowPath);
fprintf('\t       Real vs. displayed ColorChecker Lab values\n');
fprintf('\t\t     real\t\t     displayed\n');
fprintf('patch #\t     L        a        b        L        a        b       dEab\n');
fprintf('% 7d\t% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f% 9.4f\n', ...
    tableValues');
fprintf('\n');
fprintf('\t\t\t\t\t\t\tmin   % 9.4f\n', min(deltaEs));
fprintf('\t\t\t\t\t\t\tmax   % 9.4f\n', max(deltaEs));
fprintf('\t\t\t\t\t\t\tmean  % 9.4f\n', mean(deltaEs));
end
