%% Config
clear 

% =========== Subject ID ===========
subject_ID = 'Pilot5_front'
% ==================================

% Import kps data file
kps_kinect = readtable(strcat('D:\SmartRehab\Data_Keypoints\', subject_ID , '_kinect_kps.xlsx'));
kps_phone = readtable(strcat('D:\SmartRehab\Data_Keypoints\', subject_ID, '_phone(mediapipe)_kps.xlsx'));

kps_phone(:,[1,3])=[]; % remove irrelevant variables (imagename)
kps_phone.Properties.VariableNames{'idx'} = 'time';
kps_phone.time = kps_phone.time/30; % convert frame# to milliseconds (30fps)
kps_phone{:,2:27} = -kps_phone{:,2:27};
kps_kinect.time = kps_kinect.time;

% Flip along y-axis to mirror real-world
kps_kinect{:,2:2:26} = -kps_kinect{:,2:2:26};
kps_phone{:,2:2:26} = -kps_phone{:,2:2:26};

%% Time sync

% select syncing keypoint
var = 'left_wrist';
% 
% % ============ Time sync correction ==========
phonesync = 3.7755;   % Enter time difference here  (Pilot5 = 3.7755; pilot6 = -0.9 )
kps_phone.time = kps_phone.time + phonesync;
% ============================================

% Time sync with video
t = -4;        %(pilot5: t= -4 ; pilot6: t = -1)
kps_kinect.time = kps_kinect.time + t;
kps_phone.time = kps_phone.time + t;

% -- Print Figure
figure('Name','(1) Time sync - Key point')
scatter(kps_kinect.time, eval(strcat('kps_kinect.', var, '_y')),'M','x','MarkerEdgeColor',[0 .7 0])
hold on
scatter(kps_phone.time, eval(strcat('kps_phone.', var,'_y')),'MarkerEdgeColor',[0 0 .7])

clear t var phonesync

%% Trim extra time (Max & Min time)
max_t = min([max(kps_kinect.time) max(kps_phone.time)]);
idx1_k = kps_kinect.time >= max_t;
idx1_p = kps_phone.time >= max_t;
kps_kinect(idx1_k,:) = [];
kps_phone(idx1_p,:) = [];

min_t = max([min(kps_kinect.time) min(kps_phone.time)]);
min_trounded = round(min_t,1);
idx2_k = kps_kinect.time <= min_t;
idx2_p = kps_phone.time <= min_t;
kps_kinect(idx2_k,:) = [];
kps_phone(idx2_p,:) = [];

clear idx* min* max*

%% Concat kinect & mediapipe timeseries into one timeseries cube

% Sort time in ascending order
ts_phone = table2timetable(kps_phone,'RowTimes',seconds(kps_phone{:,1}));
ts_kinect = table2timetable(kps_kinect,'RowTimes',seconds(kps_kinect{:,1}));


% ======== Change data input & timetable sync method here =========
% 
ts_cube = synchronize(ts_phone, ts_kinect,'Union','linear');

%% Visualization (ts_cube)
% =========== KPs & Data Selection ===========
KP1 = 'left_elbow';
KP2 = 'left_wrist';
% ============================================

% -- Print selected kps time series
figure()
title(strcat('X-axis time series data - ',KP1,' & ', KP2));
hold on;
plot(ts_cube.Time,eval(strcat('ts_cube.',KP1,'_x_ts_phone')),'LineWidth',1.5,'Color','b');   %,'LineStyle','--'
plot(ts_cube.Time,eval(strcat('ts_cube.',KP2,'_x_ts_phone')),'LineWidth',1.5,'Color','b');
plot(ts_cube.Time,eval(strcat('ts_cube.',KP1,'_x_ts_kinect')),'LineWidth',1.5,'Color','g');
plot(ts_cube.Time,eval(strcat('ts_cube.',KP2,'_x_ts_kinect')),'LineWidth',1.5,'Color','g');
xlabel('Time (s)');
ylabel('Pixel');
legend({strcat('Mediapipe ',KP1), strcat('Mediapipe ',KP2), strcat('KinectV2 ', KP1), strcat('KinectV2 ', KP2)},'Location','Northeast')

figure()
title(strcat('Y-axis time series data - ',KP1,' & ', KP2));
hold on;
plot(ts_cube.Time,eval(strcat('ts_cube.',KP1,'_y_ts_phone')),'LineWidth',1.5,'Color','b');   %,'LineStyle','--'
plot(ts_cube.Time,eval(strcat('ts_cube.',KP2,'_y_ts_phone')),'LineWidth',1.5,'Color','b');
plot(ts_cube.Time,eval(strcat('ts_cube.',KP1,'_y_ts_kinect')),'LineWidth',1.5,'Color','g');
plot(ts_cube.Time,eval(strcat('ts_cube.',KP2,'_y_ts_kinect')),'LineWidth',1.5,'Color','g');
xlabel('Time (s)');
ylabel('Pixel');
legend({strcat('Mediapipe ',KP1), strcat('Mediapipe ',KP2), strcat('KinectV2 ', KP1), strcat('KinectV2 ', KP2)},'Location','Northeast')

%% Correlation Analysis

% Breakdown data cube into correpsonding cubes
ts_Kcube = ts_cube(:,29:54);
ts_Pcube = ts_cube(:,2:27);

% [R,P,RL,RU] = corrcoef(eval(strcat('ts_cube.',ts_cube.Properties.VariableNames{1})), eval(strcat('ts_cube.',ts_cube.Properties.VariableNames{2})));

for i = 1:length(ts_Kcube.Properties.VariableNames)

[R,P,RL,RU] = corrcoef(eval(strcat('ts_Kcube.',ts_Kcube.Properties.VariableNames{i})), eval(strcat('ts_Pcube.',ts_Pcube.Properties.VariableNames{i})));

corrMat.Var(i) = ts_Kcube.Properties.VariableNames(i);
corrMat.R(i) = R(2);
corrMat.RU(i) = RU(2);
corrMat.RL(i) = RL(2);
corrMat.P(i) = P(2);
end

corrMat.Sig = corrMat.P <= 0.05;


%% RMSE Analysis

