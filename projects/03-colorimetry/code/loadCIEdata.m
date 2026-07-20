function cie = loadCIEdata
%LOADCIEDATA Load the CIE observer and illuminant data used in this course.
%   CIE = LOADCIEDATA returns a structure containing wavelength samples,
%   2-degree and 10-degree color-matching functions, standard illuminants,
%   and a perfect reflecting diffuser.

project_dir = fileparts(fileparts(mfilename('fullpath')));
resource_dir = fullfile(project_dir, 'data');

cie = struct();

% import 1931 standard observer data
cie_2deg = importdata(fullfile(resource_dir, 'CIE_2Deg_380-780-5nm.txt'));
% store the wavelength data from cie_2deg to the lambda field
cie.lambda = cie_2deg(:, 1);
cie.cmf2deg = cie_2deg(:, 2:end);

% Import the 1964 10-degree standard observer.
cie_10deg = importdata(fullfile(resource_dir, 'CIE_10Deg_380-780-5nm.txt'));
cie.cmf10deg = cie_10deg(:, 2:end);

% import standard illuminant A data
illA = importdata(fullfile(resource_dir, 'CIE_IllA_380-780-5nm.txt'));
cie.illA = illA(:, 2:end);

% import standard illuminant C data
illC = importdata(fullfile(resource_dir, 'CIE_IllC_380-780-5nm.txt'));
cie.illC = illC(:, 2:end);

% import standard illuminant D50 data
illD50 = importdata(fullfile(resource_dir, 'CIE_IllD50_380-780-5nm.txt'));
cie.illD50 = illD50(:, 2:end);

% import standard illuminant D65 data
illD65 = importdata(fullfile(resource_dir, 'CIE_IllD65_380-780-5nm.txt'));
cie.illD65 = illD65(:, 2:end);

sampleCount = numel(cie.lambda);

% Equal-energy illuminant E.
cie.illE = 100 * ones(sampleCount, 1);

% import standard illuminant F 1-12 data
illF = importdata(fullfile(resource_dir, 'CIE_IllF_1-12_380-780-5nm.txt'));
cie.illF = illF(:, 2:end);

% Perfect reflecting diffuser.
cie.PRD = ones(sampleCount, 1, 'double');

end
