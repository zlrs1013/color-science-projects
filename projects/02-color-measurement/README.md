# Project 2 - Color Measurement

Performed visual color matching and used a ColorMunki with ArgyllCMS to measure
spectra, CIE XYZ, and CIELAB values for real, imaged, and matched patches.

- `code/`: master MATLAB report plus the original focused calculation, table,
  and plotting scripts.
- `data/`: measurement exports and MAT files.
- `results/`: exported spectral plots.
- `report/`: submitted report.

`project2_report.m` is the primary readable workflow. It loads the saved
measurements, displays the XYZ/CIELAB and component-difference tables, shows the
visual comparisons, and regenerates the spectral plots with corrected legend
mapping.
