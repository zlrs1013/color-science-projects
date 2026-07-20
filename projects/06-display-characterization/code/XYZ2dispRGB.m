function displayRGB = XYZ2dispRGB(displayModelFile, XYZ, referenceWhite)
%XYZ2DISPRGB Convert CIE XYZ values to display-specific 8-bit RGB values.
%   DISPLAYRGB = XYZ2DISPRGB(DISPLAYMODELFILE, XYZ, REFERENCEWHITE) applies
%   Bradford chromatic adaptation and the Project 6 reverse display model
%   to a 3-by-N matrix of XYZ values.

repo_dir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(fullfile(repo_dir, 'shared'));
paths = imgs351Paths(repo_dir);
addpath(paths.p05.code);

displayModel = load(displayModelFile);

% Adapt the source white point to the measured display white point, then
% remove the measured display black level.
adaptedXYZ = catBradford(XYZ, referenceWhite, displayModel.XYZw_disp);
adaptedXYZ = adaptedXYZ - displayModel.XYZk_disp;

% multiply the adjusted XYZ values by the display reverse matrix to produce linear
% RGB radiometric scalars 
linearRGB = displayModel.M_disp * adaptedXYZ;

% normalize the RSs by dividing by 100 element-wise
linearRGB = linearRGB ./ 100;

% clip any RSs that are out of range
linearRGB = min(max(linearRGB, 0), 1);

% multiply the RSs by 1023 and add 1 and round to the nearest integer 
lutIndices = round((linearRGB .* 1023) + 1);

% use the scaled RSs to index into the display LUTs to calculate the
% gamma-corrected RGB 0-255 digital counts (DCs) for the display. 
digitalCounts = zeros(size(linearRGB), 'uint8');
digitalCounts(1, :) = displayModel.RLUT_disp(lutIndices(1, :));
digitalCounts(2, :) = displayModel.GLUT_disp(lutIndices(2, :));
digitalCounts(3, :) = displayModel.BLUT_disp(lutIndices(3, :));

% convert the calculated RGBs from doubles to uint8s ready for display
displayRGB = digitalCounts;
end
