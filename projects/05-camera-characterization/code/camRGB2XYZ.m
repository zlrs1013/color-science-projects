function cameraXYZ = camRGB2XYZ(cameraModelFile, cameraRGB)
%CAMRGB2XYZ Estimate scene XYZ values from iPhone SE camera RGB values.
%   CAMERAXYZ = CAMRGB2XYZ(CAMERAMODELFILE, CAMERARGB) loads the Project 5
%   model and converts a 3-by-N matrix of 8-bit camera RGB values to a
%   3-by-N matrix of estimated CIE XYZ values.

RED = 1;
GREEN = 2;
BLUE = 3;

cameraModel = load(cameraModelFile);
normalizedRGB = double(cameraRGB) ./ 255;
linearRGB = zeros(size(normalizedRGB));

for channel = 1:3
    linearRGB(channel, :) = polyval( ...
        cameraModel.cam_polys(channel, :), normalizedRGB(channel, :));
end

% Match the clipping used when the characterization model was fitted.
linearRGB = min(max(linearRGB, 0), 1);

red = linearRGB(RED, :);
green = linearRGB(GREEN, :);
blue = linearRGB(BLUE, :);

extendedRGB = [linearRGB;
               red .* green;
               red .* blue;
               green .* blue;
               red .* green .* blue;
               red .^ 2;
               green .^ 2;
               blue .^ 2;
               ones(1, size(linearRGB, 2))];

cameraXYZ = cameraModel.cam_matrix3x11 * extendedRGB;
end
