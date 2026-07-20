% load data
project_dir = fileparts(fileparts(mfilename('fullpath')));
load(fullfile(project_dir, 'data', 'patchSpectralData.mat'))

% patch 3.1
orig_xs = 380:10:730;
orig_ys_p31_imaged = p31_imaged;
orig_ys_p31_real = p31_real;
orig_ys_p31_matching = p31_matching;

figure;
hold on;
plot(orig_xs, orig_ys_p31_real, 'color', "#0072BD", 'LineWidth', 1.5)
plot(orig_xs, orig_ys_p31_imaged,'color', '#D95319', 'LineWidth', 1.5)
plot(orig_xs, orig_ys_p31_matching,'color', '#77AC30', 'LineWidth', 1.5)
xlim([350 750])
ylim([0 100])
yticks(0:(100/10):100)
xlabel('wavelength')
ylabel('relative energy')
legend('3.1 real','3.1 imaged','3.1 matching');
title('patch 3.1 measured spectra')


% patch 3.2
orig_xs = 380:10:730;
orig_ys_p32_imaged = p32_imaged;
orig_ys_p32_real = p32_real;
orig_ys_p32_matching = p32_matching;

figure;
hold on;
plot(orig_xs, orig_ys_p32_real,'color', '#0072BD', 'LineWidth', 1.5)
plot(orig_xs, orig_ys_p32_imaged,'color', '#D95319', 'LineWidth', 1.5)
plot(orig_xs, orig_ys_p32_matching,'color', '#77AC30', 'LineWidth', 1.5)
xlim([350 750])
ylim([0 100])
yticks(0:(100/10):100)

xlabel('wavelength')
ylabel('relative energy')
legend('3.2 real','3.2 imaged','3.2 matching');
title('patch 3.2 measured spectra')
