# Project 5 - Camera Characterization

Characterized an iPhone SE camera by linearizing its RGB response, deriving RGB
to XYZ transformation matrices, evaluating ColorChecker errors, and saving a
reusable camera model.

`project5_report.m` is the primary illustrated workflow, and `camRGB2XYZ.m` is
the reusable conversion function.

The measured ColorChecker reference values and saved camera model used by the
report are stored in `data/`; no Project 5 script depends on the private
`course-resources/` directory. Publication of attributed helper functions still
requires a separate redistribution review.
