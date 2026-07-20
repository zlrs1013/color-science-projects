function xyY = XYZ2xyY(XYZ)
%XYZ2XYY Convert CIE XYZ values to x, y chromaticity and luminance.
%   XYY = XYZ2XYY(XYZ) accepts a 3-by-N matrix and returns a 3-by-N
%   matrix whose rows contain x, y, and Y. Chromaticity is undefined when
%   X + Y + Z is zero, so x and y are returned as NaN for those samples.

tristimulusSum = sum(XYZ, 1);
xyY = [XYZ(1, :) ./ tristimulusSum;
       XYZ(2, :) ./ tristimulusSum;
       XYZ(2, :)];
end
