# KPS_Calibration
Keypoints analyses -- Run in the following order

1) kps_timeseries.m 
2) kps_calibration.m  (In trial)
3) kps_analyses.m



kps_timeseries.m
------------
* Extract timeseries from Kinect & Phone .csv file
* Visualize timeseries data and allow time syncing between Kinect
& phone recording time, and video file.
* Trim additional recording times
* Form timetables  to stitch and synchronize timeline
between timeseries data (using linear interpolation)
* Save timetables as ts_cube for further analyses

kps_calibration.m
-------------
(Piloting) 
* Thoughts: Scaling and Translation of kps in space for overlap
* Skeleton-based


kps_analyses.m
------------
Requires ts_cube from kps_timeseries.m
* Correlation
* RMSE 
* Agreement (Kappa)
* Preprocessing? 