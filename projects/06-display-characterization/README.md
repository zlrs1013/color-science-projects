# Project 6 - Display Characterization

Measured display RGB ramps with a ColorMunki and ArgyllCMS, derived forward and
reverse display models with lookup tables and matrices, and evaluated a rendered
ColorChecker. `project6_report.m` derives and evaluates the model, while
`XYZ2dispRGB.m` provides the reusable XYZ-to-display-RGB conversion.

The curated code corrects channel-specific reverse-LUT application. The
submitted PDF remains unchanged, and its saved physical measurements are
retained as historical results.

The measurement files and saved display model used by the report are stored in
`data/`, and all required MATLAB helpers are stored in the project code folders.
No Project 6 script depends on the private `course-resources/` directory.
