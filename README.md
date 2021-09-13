# KPS_Calibration
Keypoints analyses -- Run in the following order

1) kps_timeseries.m 
2) kps_calibration.m  (In trial)
3) kps_analyses.m



kps_timeseries.m
------------
* Extract timeseries from Kinect & Phone .csv file
* Visualize timeseries data, followed by time syncing between Kinect
& phone skeleton recording and the video recording file.
* Trim additional recording times 
* Construct "timetables" format datacube for stitching and synchronizing
between timeseries data (using linear interpolation)
* Save & output timetables as "ts_cube" for further analyses

kps_calibration.m
-------------
(Piloting) 
* Thoughts: Scaling and Translation of kps in space for overlap
* Skeleton-based
* kps-based
* Normalized space?
* Pixel space
* Real-life distance?   (may require visual calibration?)


kps_analyses.m
------------
Requires ts_cube from kps_timeseries.m
* Preprocessing?
* Correlation
* RMSE 
* Agreement (Kappa)
