% load data
project_dir = fileparts(fileparts(mfilename('fullpath')));
load(fullfile(project_dir, 'data', 'patchColorimetryData.mat'))

% print title
fprintf('\n%s\n', "Measured XYZ and Lab values")

% print first table for patch 3.1
fprintf('\n%8s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', '', '','patch 3.1', '', '', '')
fprintf('%5s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', 'X', 'Y', 'Z', 'L', 'a', 'b')
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'real', XYZLabsreal(1,2:end))
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'imaged', XYZLabsimaged(1,2:end))
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'matching', XYZLabsmatching(1,2:end))

% print second table for patch 3.2
fprintf('\n%8s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', '', '','patch 3.2', '', '', '')
fprintf('%5s  %8s  %8s  %8s  %8s  %8s  %8s\n', '', 'X', 'Y', 'Z', 'L', 'a', 'b')
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'real', XYZLabsreal(2,2:end))
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'imaged', XYZLabsimaged(2,2:end))
fprintf('%8s  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f  %8.4f\n', 'matching', XYZLabsmatching(2,2:end))
