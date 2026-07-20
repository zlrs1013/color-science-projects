%% Color Measurement and Visual Matching
% Zhen Lai, September 2024
%
% This report consolidates the Project 2 measurement workflow, numerical
% results, visual comparisons, and spectral plots. Two paint samples
% (3.1 and 3.2), their photographed/displayed reproductions, and visually
% matched display colors were measured with a ColorMunki and ArgyllCMS.
%
% The measurements include spectral data from 380 to 730 nm in 10 nm steps,
% CIE XYZ tristimulus values, and CIELAB values. Differences in CIELAB are
% calculated relative to each physical sample.

projectDir = fileparts(fileparts(mfilename('fullpath')));
projectsDir = fileparts(projectDir);
dataDir = fullfile(projectDir, 'data');
resultsDir = fullfile(projectDir, 'results');

colorimetry = load(fullfile(dataDir, 'patchColorimetryData.mat'));
spectra = load(fullfile(dataDir, 'patchSpectralData.mat'));
wavelengths = 380:10:730;

assert(numel(wavelengths) == numel(spectra.p31_real), ...
    'The wavelength axis does not match the saved spectral measurements.');

%% Experimental comparison
% The first photograph shows the physical samples beside their photographed
% reproductions from Project 1. The second shows the physical samples beside
% display colors adjusted by visual matching.

realVsImagedFile = fullfile(projectsDir, '01-color-problem', 'results', ...
    'comparison_01.JPG');
realVsMatchedFile = fullfile(dataDir, 'colormunki_data', 'matched', ...
    '3_real_vs_matching.jpg');

comparisonFigure = figure('Color', 'w', 'Name', ...
    'Physical, imaged, and visually matched samples');
comparisonLayout = tiledlayout(comparisonFigure, 1, 2, ...
    'TileSpacing', 'compact', 'Padding', 'compact');

nexttile(comparisonLayout);
imshow(imread(realVsImagedFile));
title('Physical vs. imaged samples');

nexttile(comparisonLayout);
imshow(imread(realVsMatchedFile));
title('Physical vs. visually matched samples');

%% Measured CIE XYZ and CIELAB values
% The saved data arrays contain an original measurement identifier in column
% 1; columns 2 through 7 contain X, Y, Z, L*, a*, and b*. The fixed-width
% layout preserves the presentation used in the original project report.

fprintf('\n%s\n', "Measured XYZ and Lab values");

% Print the table for patch 3.1.
fprintf('\n%8s  %8s  %8s  %8s  %8s  %8s  %8s\n', ...
    '', '', '', 'patch 3.1', '', '', '');
fprintf('%5s  %8s  %8s  %8s  %8s  %8s  %8s\n', ...
    '', 'X', 'Y', 'Z', 'L*', 'a*', 'b*');
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', ...
    'real', colorimetry.XYZLabsreal(1, 2:end));
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', ...
    'imaged', colorimetry.XYZLabsimaged(1, 2:end));
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', ...
    'matching', colorimetry.XYZLabsmatching(1, 2:end));

% Print the table for patch 3.2.
fprintf('\n%8s  %8s  %8s  %8s  %8s  %8s  %8s\n', ...
    '', '', '', 'patch 3.2', '', '', '');
fprintf('%5s  %8s  %8s  %8s  %8s  %8s  %8s\n', ...
    '', 'X', 'Y', 'Z', 'L*', 'a*', 'b*');
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', ...
    'real', colorimetry.XYZLabsreal(2, 2:end));
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', ...
    'imaged', colorimetry.XYZLabsimaged(2, 2:end));
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', ...
    'matching', colorimetry.XYZLabsmatching(2, 2:end));

%% CIELAB component differences
% Differences are calculated as comparison minus physical reference. Positive
% delta L* indicates lighter, positive delta a* indicates redder, and positive
% delta b* indicates yellower. Negative delta a* indicates greener, while
% negative delta b* indicates bluer.

physicalLab = colorimetry.XYZLabsreal(:, 5:7);
imagedLab = colorimetry.XYZLabsimaged(:, 5:7);
matchedLab = colorimetry.XYZLabsmatching(:, 5:7);

deltaImaged = imagedLab - physicalLab;
deltaMatched = matchedLab - physicalLab;

differenceValues = [
    deltaImaged(1, :)
    deltaMatched(1, :)
    deltaImaged(2, :)
    deltaMatched(2, :)
];

Patch = ["3.1"; "3.1"; "3.2"; "3.2"];
Comparison = ["Imaged - physical"; "Matched - physical"; ...
    "Imaged - physical"; "Matched - physical"];
LabIndication = [
    "Slightly lighter, greener, and bluer"
    "Much lighter and greener; nearly unchanged yellow-blue component"
    "Much lighter, redder, and yellower"
    "Lighter, redder, and much yellower"
];
VisualObservation = [
    "Appeared bluer and lighter, with little red-green change"
    "Appeared much lighter and greener, with a small blue shift"
    "Appeared slightly redder and yellower, but darker rather than lighter"
    "Appeared yellower and slightly redder, but darker than the physical patch"
];

differenceTable = table(Patch, Comparison, differenceValues(:, 1), ...
    differenceValues(:, 2), differenceValues(:, 3), LabIndication, ...
    VisualObservation, 'VariableNames', {'Patch', 'Comparison', ...
    'DeltaLStar', 'DeltaaStar', 'DeltabStar', 'LabIndication', ...
    'VisualObservation'});

disp('CIELAB differences relative to each physical patch');
disp(differenceTable);

%% Measured reflectance spectra
% The plots use a consistent color mapping in both figures: physical is blue,
% imaged is orange, and visually matched is green. The older plotting script
% labeled the physical and imaged curves in the opposite order; the data were
% correct, but the legend mapping was not.

plotPatchSpectra(wavelengths, spectra.p31_real, spectra.p31_imaged, ...
    spectra.p31_matching, 'Patch 3.1', ...
    fullfile(resultsDir, 'patch3.1_spectral_plot.png'));

plotPatchSpectra(wavelengths, spectra.p32_real, spectra.p32_imaged, ...
    spectra.p32_matching, 'Patch 3.2', ...
    fullfile(resultsDir, 'patch3.2_spectral_plot.png'));

%% Summary
% Patch 3.1's imaged measurement remained relatively close to the physical
% sample in CIELAB, while its visually matched measurement was substantially
% lighter. For patch 3.2, both comparison conditions shifted toward positive
% a* and b*, indicating redder and yellower measurements. The visual judgments
% generally agreed with the hue directions but did not always agree with the
% measured lightness direction, illustrating the difference between instrument
% measurements and appearance in a camera-display viewing workflow.

fprintf('\nSummary of component differences (comparison minus physical):\n');
fprintf('Patch 3.1 imaged:  dL*=%7.4f, da*=%7.4f, db*=%7.4f\n', deltaImaged(1, :));
fprintf('Patch 3.1 matched: dL*=%7.4f, da*=%7.4f, db*=%7.4f\n', deltaMatched(1, :));
fprintf('Patch 3.2 imaged:  dL*=%7.4f, da*=%7.4f, db*=%7.4f\n', deltaImaged(2, :));
fprintf('Patch 3.2 matched: dL*=%7.4f, da*=%7.4f, db*=%7.4f\n', deltaMatched(2, :));

function plotPatchSpectra(wavelengths, physical, imaged, matched, ...
        patchName, outputFile)
%PLOTPATCHSPECTRA Plot and export physical, imaged, and matched spectra.

figureHandle = figure('Color', 'w', 'Name', patchName);
hold on;
plot(wavelengths, physical, 'Color', '#0072BD', 'LineWidth', 1.8);
plot(wavelengths, imaged, 'Color', '#D95319', 'LineWidth', 1.8);
plot(wavelengths, matched, 'Color', '#77AC30', 'LineWidth', 1.8);
hold off;

xlim([380 730]);
ylim([0 100]);
xticks(400:50:700);
yticks(0:10:100);
grid on;
box on;
xlabel('Wavelength (nm)');
ylabel('Reflectance factor (%)');
title([patchName ' measured spectra']);
legend({'Physical', 'Imaged', 'Visually matched'}, ...
    'Location', 'best');

exportgraphics(figureHandle, outputFile, 'Resolution', 160);
end
