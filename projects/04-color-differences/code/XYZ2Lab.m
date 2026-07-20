function Lab = XYZ2Lab(XYZ, referenceWhite)
%XYZ2LAB Convert CIE XYZ values to CIELAB.
%   LAB = XYZ2LAB(XYZ, REFERENCEWHITE) accepts XYZ as a 3-by-N matrix and
%   the reference-white tristimulus values as a 3-by-1 vector. LAB is a
%   3-by-N matrix containing L*, a*, and b*.

normalizedXYZ = XYZ ./ referenceWhite;
fXYZ = normalizedXYZ;

nonlinearMask = normalizedXYZ > 0.008856;
fXYZ(nonlinearMask) = normalizedXYZ(nonlinearMask) .^ (1 / 3);
fXYZ(~nonlinearMask) = 7.787 .* normalizedXYZ(~nonlinearMask) + 16 / 116;

Lab = [116 .* fXYZ(2, :) - 16;
       500 .* (fXYZ(1, :) - fXYZ(2, :));
       200 .* (fXYZ(2, :) - fXYZ(3, :))];
end
