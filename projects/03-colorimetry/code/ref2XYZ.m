function XYZ = ref2XYZ(reflectances, colorMatchingFunctions, illuminant)
%REF2XYZ Convert reflectance spectra to CIE XYZ tristimulus values.
%   XYZ = REF2XYZ(REFLECTANCES, COLORMATCHINGFUNCTIONS, ILLUMINANT)
%   accepts one or more reflectance spectra in an N-by-M matrix, the CIE
%   color-matching functions in an N-by-3 matrix, and an N-by-1 illuminant
%   spectral power distribution. The result is a 3-by-M matrix scaled so a
%   perfect reflecting diffuser has Y = 100.

normalization = 100 / sum(colorMatchingFunctions(:, 2) .* illuminant);
weightedReflectances = illuminant .* reflectances;
XYZ = normalization * colorMatchingFunctions.' * weightedReflectances;
end
