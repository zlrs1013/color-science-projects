# Project 7 - Color Reproduction

Connected the camera and display models from Projects 5 and 6 into an end-to-end
color-reproduction workflow, measured calibrated and uncalibrated renderings,
and produced a color-calibrated ColorChecker image.

The workflow measurements, ColorChecker reference values, camera RGB samples,
and source photograph are stored in `data/`. The report uses the reusable code
and saved models retained in earlier project folders and does not depend on the
private `course-resources/` directory.

The original PNGs in `results/` are preserved submitted artifacts. Running the
cleaned script writes `_corrected.png` variants without overwriting them. The
reported physical Delta E values remain historical because validating the
corrected stimuli would require a new measurement session.
