%% Config

% =========== Subject ID ===========
subject_ID = 'Pilot6_side'
% ==================================

% Import kps data file
kps_kinect = readtable(strcat('D:\SmartRehab\Data_Keypoints\', subject_ID , '_kinect_kps.xlsx'));
kps_phone = readtable(strcat('D:\SmartRehab\Data_Keypoints\', subject_ID, '_phone(mediapipe)_kps.xlsx'));

kps_phone(:,[1,3])=[]; % remove irrelevant variables (imagename)
kps_phone.Properties.VariableNames{'idx'} = 'time';
kps_phone.time = kps_phone.time/30; % convert frame# to seconds (30fps)
kps_phone{:,2:27} = -kps_phone{:,2:27};

% Flip along y-axis to mirror real-world
kps_kinect{:,2:2:26} = -kps_kinect{:,2:2:26};
kps_phone{:,2:2:26} = -kps_phone{:,2:2:26};

%% Time sync

% select syncing keypoint
var = 'right_wrist';

% ============ Time sync correction ==========
% phonesync = 0.9;   % Enter time difference here  (Pilot5 = 3.7755; pilot6 = -0.9 )
% kps_phone.time = kps_phone.time + phonesync;
% ============================================

% trim extra time
% max_t = min([max(kps_kinect.time) max(kps_phone.time)]);
% max_trounded = floor(max_t);
% idx_k = regexp(string(kps_kinect.time), regexptranslate('wildcard', strcat(num2str(max_trounded),'.*')));
% idx_p = regexp(string(kps_phone.time), regexptranslate('wildcard', strcat(num2str(max_trounded),'.*')));
% idx_k = max(find(~cellfun(@isempty,idx_k)));
% idx_p = max(find(~cellfun(@isempty,idx_p)));
% kps_kinect(idx_k+1:length(kps_kinect.time),:) = [];
% kps_phone(idx_p+1:length(kps_phone.time),:) = [];

% Time sync with video
t = -1;        %(pilot5: t= -4 ; pilot6: t = -1)
kps_kinect.time = kps_kinect.time + t;
kps_phone.time = kps_phone.time + t;

% -- Print Figure
figure('Name','(1) Time sync - Key point')
scatter(kps_kinect.time, eval(strcat('kps_kinect.', var, '_y')),'M','x','MarkerEdgeColor',[0 .7 0],'LineWidth',1.5)
hold on
scatter(kps_phone.time, eval(strcat('kps_phone.', var,'_y')))



%% 
% =========== KPs & Data Selection ===========
VData = 'kps_kinect_cali';  %Data version
KP1 = 'right_elbow';
KP2 = 'right_wrist';
% ============================================
figure()
title(strcat('X-axis time series data - ',KP1,' & ', KP2));
hold on;
plot(kps_phone.time,eval(strcat('kps_phone.',KP1,'_x')),'LineWidth',1.5,'Color','b','LineStyle','--');
plot(kps_phone.time,eval(strcat('kps_phone.',KP2,'_x')),'LineWidth',1.5,'Color','b');
plot(kps_kinect.time,eval(strcat(VData,'.',KP1,'_x')),'LineWidth',1.5,'Color','g','LineStyle','--');
plot(kps_kinect.time,eval(strcat(VData,'.',KP2,'_x')),'LineWidth',1.5,'Color','g');
xlabel('Time (s)');
ylabel('Pixel');
legend({strcat('Mediapipe ',KP1), strcat('Mediapipe ',KP2), strcat('KinectV2 ', KP1), strcat('KinectV2 ', KP2)},'Location','Northeast')

figure()
title(strcat('Y-axis time series data - ',KP1,' & ', KP2));
hold on;
plot(kps_phone.time,eval(strcat('kps_phone.',KP1,'_y')),'LineWidth',1.5,'Color','b','LineStyle','--');
plot(kps_phone.time,eval(strcat('kps_phone.',KP2,'_y')),'LineWidth',1.5,'Color','b');
plot(kps_kinect.time,eval(strcat(VData,'.',KP1,'_y')),'LineWidth',1.5,'Color','g','LineStyle','--');
plot(kps_kinect.time,eval(strcat(VData,'.',KP2,'_y')),'LineWidth',1.5,'Color','g');
xlabel('Time (s)');
ylabel('Pixel');
legend({strcat('Mediapipe ',KP1), strcat('Mediapipe ',KP2), strcat('KinectV2 ', KP1), strcat('KinectV2 ', KP2)},'Location','Northeast')

%%

[R,P] = corrcoef(kps_kinect_cali.right_wrist_x, kps_phone.right_wrist_x)
