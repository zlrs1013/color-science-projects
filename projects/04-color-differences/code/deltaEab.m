function deltaE = deltaEab(Lab1, Lab2)
%DELTAEAB Calculate CIE 1976 Delta E*ab color differences.
%   DELTAE = DELTAEAB(LAB1, LAB2) accepts corresponding CIELAB samples in
%   two 3-by-N matrices and returns their Euclidean distances as a 1-by-N
%   row vector.

deltaE = sqrt(sum((Lab2 - Lab1) .^ 2, 1));
end
