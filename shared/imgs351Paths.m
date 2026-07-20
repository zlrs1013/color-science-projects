function paths = imgs351Paths(repoRoot)
% Returns absolute paths for the curated IMGS-351 repository.
% The optional repoRoot input is useful when a script derives the repository
% location from its own filename. With no input, the repository root is
% inferred from this file's location in the shared directory.

if nargin < 1
    sharedDir = fileparts(mfilename('fullpath'));
    repoRoot = fileparts(sharedDir);
end

paths.root = repoRoot;
paths.projects = fullfile(repoRoot, 'projects');

paths.p01 = projectPaths(paths.projects, '01-color-problem');
paths.p02 = projectPaths(paths.projects, '02-color-measurement');
paths.p03 = projectPaths(paths.projects, '03-colorimetry');
paths.p04 = projectPaths(paths.projects, '04-color-differences');
paths.p05 = projectPaths(paths.projects, '05-camera-characterization');
paths.p06 = projectPaths(paths.projects, '06-display-characterization');
paths.p07 = projectPaths(paths.projects, '07-color-reproduction');
end

function project = projectPaths(projectsRoot, projectName)
project.root = fullfile(projectsRoot, projectName);
project.code = fullfile(project.root, 'code');
project.data = fullfile(project.root, 'data');
project.results = fullfile(project.root, 'results');
project.report = fullfile(project.root, 'report');
project.courseResources = fullfile(project.root, 'course-resources');
end

