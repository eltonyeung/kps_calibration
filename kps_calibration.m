%% Config
subject_ID = 'Pilot5_front'

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
var = 'left_wrist';

% ============ Time sync correction ==========
phonesync = 22.1422-18.3667;   % Enter time difference here  (Pilot3_louis = 0.9342)
kps_phone.time = kps_phone.time + phonesync;
% ============================================

% trim extra time
max_t = min([max(kps_kinect.time) max(kps_phone.time)]);
max_trounded = floor(max_t);
idx_k = regexp(string(kps_kinect.time), regexptranslate('wildcard', strcat(num2str(max_trounded),'.*')));
idx_p = regexp(string(kps_phone.time), regexptranslate('wildcard', strcat(num2str(max_trounded),'.*')));
idx_k = max(find(~cellfun(@isempty,idx_k)));
idx_p = max(find(~cellfun(@isempty,idx_p)));
kps_kinect(idx_k+1:length(kps_kinect.time),:) = [];
kps_phone(idx_p+1:length(kps_phone.time),:) = [];

% Sync.timesync = phonesync;
% Sync.timetrim = max_t;

figure('Name','(1) Time sync - Key point')
scatter(kps_kinect.time, eval(strcat('kps_kinect.', var, '_x')),'M','x','MarkerEdgeColor',[0 .7 0],'LineWidth',1.5)
hold on
scatter(kps_phone.time, eval(strcat('kps_phone.', var,'_x')))

clear phonesync


%% Calibration _ Part 1 (Translation)

% translate body frame to positive sector for scaling
min_k = [min(min(kps_kinect{:,2:2:26})) min(min(kps_kinect{:,3:2:27}))];
min_p = [min(min(kps_phone{:,2:2:26})) min(min(kps_phone{:,3:2:27}))];
kps_kinect{:,2:2:26} = kps_kinect{:,2:2:26} - min_k(1);
kps_kinect{:,3:2:27} = kps_kinect{:,3:2:27} - min_k(2);
kps_phone{:,2:2:26} = kps_phone{:,2:2:26} - min_p(1);
kps_phone{:,3:2:27} = kps_phone{:,3:2:27} - min_p(2);

% % Make left ankle as the anchor for all frame 

% kps_kinect{:,2:2:26} = kps_kinect{:,2:2:26} - kps_kinect.right_ankle_x;
% kps_kinect{:,3:2:27} = kps_kinect{:,3:2:27} - kps_kinect.right_ankle_y;
% kps_phone{:,2:2:26} = kps_phone{:,2:2:26} - kps_phone.right_ankle_x;
% kps_phone{:,3:2:27} = kps_phone{:,3:2:27} - kps_phone.right_ankle_y;

figure('Name','(2) Translation - Full timeseries')
scatter(kps_kinect{:,2:2:26},kps_kinect{:,3:2:27},'M','x')
hold on
scatter(kps_phone{:,2:2:26},kps_phone{:,3:2:27})
xlim([-100 1880])
ylim([-100 980])


%% Calibration _ Part 2 (Selecting key frames for scaling)
% select key frame for syncing keypoints in space
t = '3.';
idx_k = regexp(string(kps_kinect.time), regexptranslate('wildcard', strcat(t,'*')));
idx_p = regexp(string(kps_phone.time), regexptranslate('wildcard', strcat(t,'*')));
idx_k = find(~cellfun(@isempty,idx_k));
idx_p = find(~cellfun(@isempty,idx_p));

skeletonk_x = table2array(kps_kinect(idx_k(1:30),2:2:26));
skeletonk_y = table2array(kps_kinect(idx_k(1:30),3:2:27));
skeletonp_x = table2array(kps_phone(idx_p(1:30),2:2:26));
skeletonp_y = table2array(kps_phone(idx_p(1:30),3:2:27));

% Translate selected keyframes to positive sector for scale calculation
mink = [min(min(skeletonk_x)) min(min(skeletonk_y))];
minp = [min(min(skeletonp_x)) min(min(skeletonp_y))];
mink(mink >= 100) = 0;  
minp(minp >= 100) = 0;
skeletonk_x = skeletonk_x - mink(1);
skeletonk_y = skeletonk_y - mink(2);
skeletonp_x = skeletonp_x - minp(1);
skeletonp_y = skeletonp_y - minp(2);

clear mink minp

% -- Visualize selected key frames
figure('Name','(3) Selected key timeframes')
scatter(skeletonk_x, skeletonk_y, 'M','x','MarkerEdgeColor',[0 .7 0],'LineWidth',1.5)
hold on
scatter(skeletonp_x, skeletonp_y)
xlim([-200 500])
ylim([-100 900])

%% Calibration _ Part 3 (Autoscaling)
% Calculate x scale diff using distance between ankle (selected frames)
Ankledist_k = abs(median(skeletonk_x(:,13)) - median(skeletonk_x(:,12)));
Ankledist_p = abs(median(skeletonp_x(:,13)) - median(skeletonp_x(:,12)));
scale_x = Ankledist_p / Ankledist_k;

Shoulderdist_k = abs(median(skeletonk_x(:,3)) - median(skeletonk_x(:,2)));
Shoulderdist_p = abs(median(skeletonp_x(:,3)) - median(skeletonk_x(:,2)));
scale_x2 = Shoulderdist_p / Shoulderdist_k;

% Calculate y scale diff using the distance between L shoulder & ankle
% (selected frames)
Bodyheight_k = abs(median(skeletonk_y(:,3)) - median(skeletonk_y(:,13)));
Bodyheight_p = abs(median(skeletonp_y(:,3)) - median(skeletonp_y(:,13)));
scale_y = Bodyheight_p / Bodyheight_k;

BodyheightR_k = abs(median(skeletonk_y(:,2)) - median(skeletonk_y(:,12)));
BodyheightR_p = abs(median(skeletonp_y(:,2)) - median(skeletonp_y(:,12)));
scale_y2 = BodyheightR_p / BodyheightR_k ;

scale_xAVG = mean([scale_x scale_x2]);
scale_yAVG = mean([scale_y scale_y2]);

% % Rescale Kinect bodyframe to fit RGB bodyframe
kps_kinect_scaled = kps_kinect;
kps_kinect_scaled{:,2:2:26} = kps_kinect_scaled{:,2:2:26}.* scale_xAVG;
kps_kinect_scaled{:,3:2:27} = kps_kinect_scaled{:,3:2:27}.* scale_yAVG;

skeletonk_x_scaled = skeletonk_x.* scale_xAVG;
skeletonk_y_scaled = skeletonk_y.* scale_yAVG;

% --
figure('Name','(3) Scaling - Key timeframes')
scatter(skeletonk_x_scaled, skeletonk_y_scaled, 'M','x')
hold on
scatter(skeletonp_x, skeletonp_y)

% --
figure('Name','(3) Scaling- Full timeseries')
scatter(kps_kinect_scaled{:,2:2:26},kps_kinect_scaled{:,3:2:27},'M','x')
hold on
scatter(kps_phone{:,2:2:26},kps_phone{:,3:2:27})

Sync.scale_xAVG = scale_xAVG;
Sync.scale_yAVG = scale_yAVG;

clear idx_* max_* scale_* Ankledist_* Bodyheight* Shoulderdist_*


%% Calibration _ Part 3 (Translation)   [Fixing]  
leftankleK_loc = [median(skeletonk_x_scaled(:,13)), median(skeletonk_y_scaled(:,13))];
leftankleP_loc = [median(skeletonp_x(:,13)), median(skeletonp_y(:,13))];
cali= leftankleP_loc - leftankleK_loc;

kps_kinect_cali = kps_kinect_scaled;
% kps_kinect_cali.left_ankle_x = kps_kinect_cali.left_ankle_x *2;
% kps_kinect_cali.left_ankle_y = kps_kinect_cali.left_ankle_y *2;
% kps_kinect_cali{:,2:2:26} = (kps_kinect_cali{:,2:2:26} + cali(1) - 2034)*0.891;
% kps_kinect_cali{:,3:2:27} = kps_kinect_cali{:,3:2:27} + cali(2) - 1500;

kps_kinect_cali{:,2:2:26} = kps_kinect_cali{:,2:2:26} + cali(1);
kps_kinect_cali{:,3:2:27} = kps_kinect_cali{:,3:2:27} + cali(2);

% X_AmpK = max(eval(strcat('kps_kinect_cali.', var, '_x')))-min((eval(strcat('kps_kinect_cali.', var, '_x'))));
% X_AmpP = max(eval(strcat('kps_phone.', var, '_x')))-min(eval(strcat('kps_phone.', var, '_x')));

% Adjust Kinect bodyframe to overlap w/ Phone bodyframe using the cali
skeletonk_x_cali = skeletonk_x_scaled + cali(1);
skeletonk_y_cali = skeletonk_y_scaled + cali(2);

% --
figure('Name','(4) Translation - Key timeframes')
title('Kinect & Mediapipe Overlay')
scatter(skeletonk_x_cali,skeletonk_y_cali, 'M','x')
hold on
scatter(skeletonp_x,skeletonp_y)
xlim([-200 1980]);
ylim([-200 1280]);

% --
figure('Name','(4) Translation - All timeframes')
scatter(kps_kinect_cali{:,2:2:26},kps_kinect_cali{:,3:2:27},'M','x')
hold on
scatter(kps_phone{1:930,2:2:26},kps_phone{1:930,3:2:27})
xlim([-200 1980]);
ylim([-200 1280]);

%% Calibration _ Part 4 (Manual scaling)

% Manually input data point here for rescaling
maxk_x = 2;
mink_x = 1;
maxp_x = 2;
minp_x = 1;
maxk_y = 854.21;
mink_y = 509.393;
maxp_y = 803.559;
minp_y = 498.631;

scale= [(maxp_x-minp_x)/(maxk_x-mink_x) (maxp_y-minp_y)/(maxk_y-mink_y)];

% kps_kinect_cali{:,2:2:26} = kps_kinect_cali{:,2:2:26}* scale(1);
kps_kinect_cali{:,3:2:27} = kps_kinect_cali{:,3:2:27}* scale(2);

clear maxp* maxk* scale minp* mink*

%% Calibration _ Part 5 (Manual translation)

transy = 530.1;
transy2 = 530.1;

kps_kinect_cali.right_wrist_x = kps_kinect.right_wrist_x + transy;
kps_kinect_cali.right_elbow_x = kps_kinect.right_elbow_x + transy2;

%%
figure(7)   
scatter(kps_kinect_cali.time, eval(strcat('kps_kinect_cali.', var, '_x')),'M','x')
hold on
scatter(kps_phone.time, eval(strcat('kps_phone.', var,'_x')))




%% Visualize ALL KINECT timeseries 
figure(99)
title('Kinect')
plot(kps_kinect_cali.time,kps_kinect_cali.head_x,'DisplayName','head_x');
hold on;
plot(kps_kinect_cali.time,kps_kinect_cali.head_y,'DisplayName','head_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_shoulder_x,'DisplayName','right shoulder_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_shoulder_y,'DisplayName','right shoulder_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_shoulder_x,'DisplayName','left shoulder_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_shoulder_y,'DisplayName','left shoulder_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_elbow_x,'DisplayName','right elbow_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_elbow_y,'DisplayName','right elbow_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_elbow_x,'DisplayName','left elbow_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_elbow_y,'DisplayName','left elbow_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_wrist_x,'DisplayName','right wrist_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_wrist_y,'DisplayName','right wrist_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_wrist_x,'DisplayName','left wrist_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_wrist_y,'DisplayName','left wrist_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_hip_x,'DisplayName','right hip_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_hip_y,'DisplayName','right hip_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_hip_x,'DisplayName','left hip_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_hip_y,'DisplayName','left hip_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_knee_x,'DisplayName','right knee_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_knee_y,'DisplayName','right knee_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_knee_x,'DisplayName','left knee_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_knee_y,'DisplayName','left knee_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_ankle_x,'DisplayName','right ankle_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_ankle_y,'DisplayName','right ankle_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_ankle_x,'DisplayName','left ankle_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_ankle_y,'DisplayName','left ankle_y');
hold off;
%% Visualize ALL Phone Timeseries
figure(100)
plot(kps_phone.time,kps_phone.nose_x,'DisplayName','kps_phone.nose_x');
hold on;
plot(kps_phone.time,kps_phone.nose_y,'DisplayName','kps_phone.nose_y');
plot(kps_phone.time,kps_phone.right_shoulder_x,'DisplayName','kps_phone.right_shoulder_x');
plot(kps_phone.time,kps_phone.right_shoulder_y,'DisplayName','kps_phone.right_shoulder_y');
plot(kps_phone.time,kps_phone.left_shoulder_x,'DisplayName','kps_phone.left_shoulder_x');
plot(kps_phone.time,kps_phone.left_shoulder_y,'DisplayName','kps_phone.left_shoulder_y');
plot(kps_phone.time,kps_phone.right_elbow_x,'DisplayName','kps_phone.right_elbow_x');
plot(kps_phone.time,kps_phone.right_elbow_y,'DisplayName','kps_phone.right_elbow_y');
plot(kps_phone.time,kps_phone.left_elbow_x,'DisplayName','kps_phone.left_elbow_x');
plot(kps_phone.time,kps_phone.left_elbow_y,'DisplayName','kps_phone.left_elbow_y');
plot(kps_phone.time,kps_phone.right_wrist_x,'DisplayName','kps_phone.right_wrist_x');
plot(kps_phone.time,kps_phone.right_wrist_y,'DisplayName','kps_phone.right_wrist_y');
plot(kps_phone.time,kps_phone.left_wrist_x,'DisplayName','kps_phone.left_wrist_x');
plot(kps_phone.time,kps_phone.left_wrist_y,'DisplayName','kps_phone.left_wrist_y');
plot(kps_phone.time,kps_phone.right_hip_x,'DisplayName','kps_phone.right_hip_x');
plot(kps_phone.time,kps_phone.right_hip_y,'DisplayName','kps_phone.right_hip_y');
plot(kps_phone.time,kps_phone.left_hip_x,'DisplayName','kps_phone.left_hip_x');
plot(kps_phone.time,kps_phone.left_hip_y,'DisplayName','kps_phone.left_hip_y');
plot(kps_phone.time,kps_phone.right_knee_x,'DisplayName','kps_phone.right_knee_x');
plot(kps_phone.time,kps_phone.right_knee_y,'DisplayName','kps_phone.right_knee_y');
plot(kps_phone.time,kps_phone.left_knee_x,'DisplayName','kps_phone.left_knee_x');
plot(kps_phone.time,kps_phone.left_knee_y,'DisplayName','kps_phone.left_knee_y');
plot(kps_phone.time,kps_phone.right_ankle_x,'DisplayName','kps_phone.right_ankle_x');
plot(kps_phone.time,kps_phone.right_ankle_y,'DisplayName','kps_phone.right_ankle_y');
plot(kps_phone.time,kps_phone.left_ankle_x,'DisplayName','kps_phone.left_ankle_x');
plot(kps_phone.time,kps_phone.left_ankle_y,'DisplayName','kps_phone.left_ankle_y');
hold off;

%%

% X & Y

figure(101)
plot(kps_phone.time,kps_phone.nose_x,'DisplayName','kps_phone.nose_x');
hold on;
plot(kps_phone.time,kps_phone.nose_y,'DisplayName','kps_phone.nose_y');
plot(kps_phone.time,kps_phone.right_shoulder_x,'DisplayName','kps_phone.right_shoulder_x');
plot(kps_phone.time,kps_phone.right_shoulder_y,'DisplayName','kps_phone.right_shoulder_y');
plot(kps_phone.time,kps_phone.left_shoulder_x,'DisplayName','kps_phone.left_shoulder_x');
plot(kps_phone.time,kps_phone.left_shoulder_y,'DisplayName','kps_phone.left_shoulder_y');
plot(kps_phone.time,kps_phone.right_elbow_x,'DisplayName','kps_phone.right_elbow_x');
plot(kps_phone.time,kps_phone.right_elbow_y,'DisplayName','kps_phone.right_elbow_y');
plot(kps_phone.time,kps_phone.left_elbow_x,'DisplayName','kps_phone.left_elbow_x');
plot(kps_phone.time,kps_phone.left_elbow_y,'DisplayName','kps_phone.left_elbow_y');
plot(kps_phone.time,kps_phone.right_wrist_x,'DisplayName','kps_phone.right_wrist_x');
plot(kps_phone.time,kps_phone.right_wrist_y,'DisplayName','kps_phone.right_wrist_y');
plot(kps_phone.time,kps_phone.left_wrist_x,'DisplayName','kps_phone.left_wrist_x');
plot(kps_phone.time,kps_phone.left_wrist_y,'DisplayName','kps_phone.left_wrist_y');
plot(kps_phone.time,kps_phone.right_hip_x,'DisplayName','kps_phone.right_hip_x');
plot(kps_phone.time,kps_phone.right_hip_y,'DisplayName','kps_phone.right_hip_y');
plot(kps_phone.time,kps_phone.left_hip_x,'DisplayName','kps_phone.left_hip_x');
plot(kps_phone.time,kps_phone.left_hip_y,'DisplayName','kps_phone.left_hip_y');
plot(kps_phone.time,kps_phone.right_knee_x,'DisplayName','kps_phone.right_knee_x');
plot(kps_phone.time,kps_phone.right_knee_y,'DisplayName','kps_phone.right_knee_y');
plot(kps_phone.time,kps_phone.left_knee_x,'DisplayName','kps_phone.left_knee_x');
plot(kps_phone.time,kps_phone.left_knee_y,'DisplayName','kps_phone.left_knee_y');
plot(kps_phone.time,kps_phone.right_ankle_x,'DisplayName','kps_phone.right_ankle_x');
plot(kps_phone.time,kps_phone.right_ankle_y,'DisplayName','kps_phone.right_ankle_y');
plot(kps_phone.time,kps_phone.left_ankle_x,'DisplayName','kps_phone.left_ankle_x');
plot(kps_phone.time,kps_phone.left_ankle_y,'DisplayName','kps_phone.left_ankle_y');
plot(kps_kinect_cali.time,kps_kinect_cali.head_x,'DisplayName','head_x');
plot(kps_kinect_cali.time,kps_kinect_cali.head_y,'DisplayName','head_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_shoulder_x,'DisplayName','right shoulder_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_shoulder_y,'DisplayName','right shoulder_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_shoulder_x,'DisplayName','left shoulder_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_shoulder_y,'DisplayName','left shoulder_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_elbow_x,'DisplayName','right elbow_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_elbow_y,'DisplayName','right elbow_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_elbow_x,'DisplayName','left elbow_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_elbow_y,'DisplayName','left elbow_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_wrist_x,'DisplayName','right wrist_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_wrist_y,'DisplayName','right wrist_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_wrist_x,'DisplayName','left wrist_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_wrist_y,'DisplayName','left wrist_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_hip_x,'DisplayName','right hip_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_hip_y,'DisplayName','right hip_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_hip_x,'DisplayName','left hip_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_hip_y,'DisplayName','left hip_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_knee_x,'DisplayName','right knee_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_knee_y,'DisplayName','right knee_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_knee_x,'DisplayName','left knee_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_knee_y,'DisplayName','left knee_y');
plot(kps_kinect_cali.time,kps_kinect_cali.right_ankle_x,'DisplayName','right ankle_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_ankle_y,'DisplayName','right ankle_y');
plot(kps_kinect_cali.time,kps_kinect_cali.left_ankle_x,'DisplayName','left ankle_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_ankle_y,'DisplayName','left ankle_y');
hold off;

%% X & Y separate


figure(102)
plot(kps_phone.time,kps_phone.nose_x,'DisplayName','kps_phone.nose_x');
hold on;
plot(kps_phone.time,kps_phone.right_shoulder_x,'DisplayName','kps_phone.right_shoulder_x');
plot(kps_phone.time,kps_phone.left_shoulder_x,'DisplayName','kps_phone.left_shoulder_x');
plot(kps_phone.time,kps_phone.right_elbow_x,'DisplayName','kps_phone.right_elbow_x');
plot(kps_phone.time,kps_phone.left_elbow_x,'DisplayName','kps_phone.left_elbow_x');
plot(kps_phone.time,kps_phone.right_wrist_x,'DisplayName','kps_phone.right_wrist_x');
plot(kps_phone.time,kps_phone.left_wrist_x,'DisplayName','kps_phone.left_wrist_x');
plot(kps_phone.time,kps_phone.right_hip_x,'DisplayName','kps_phone.right_hip_x');
plot(kps_phone.time,kps_phone.left_hip_x,'DisplayName','kps_phone.left_hip_x');
plot(kps_phone.time,kps_phone.right_knee_x,'DisplayName','kps_phone.right_knee_x');
plot(kps_phone.time,kps_phone.left_knee_x,'DisplayName','kps_phone.left_knee_x');
plot(kps_phone.time,kps_phone.right_ankle_x,'DisplayName','kps_phone.right_ankle_x');
plot(kps_phone.time,kps_phone.left_ankle_x,'DisplayName','kps_phone.left_ankle_x');
plot(kps_kinect_cali.time,kps_kinect_cali.head_x,'DisplayName','head_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_shoulder_x,'DisplayName','right shoulder_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_shoulder_x,'DisplayName','left shoulder_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_elbow_x,'DisplayName','right elbow_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_elbow_x,'DisplayName','left elbow_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_wrist_x,'DisplayName','right wrist_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_wrist_x,'DisplayName','left wrist_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_hip_x,'DisplayName','right hip_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_hip_x,'DisplayName','left hip_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_knee_x,'DisplayName','right knee_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_knee_x,'DisplayName','left knee_x');
plot(kps_kinect_cali.time,kps_kinect_cali.right_ankle_x,'DisplayName','right ankle_x');
plot(kps_kinect_cali.time,kps_kinect_cali.left_ankle_x,'DisplayName','left ankle_x');
hold off;

%% 
% 
% LineSpec_k.Color = 'R';

figure(104)
title('X-axis time series data while performing right shoulder abduction');
hold on;
plot(kps_phone.time,kps_phone.right_elbow_x,'LineWidth',1.5,'Color','b','LineStyle','--');
plot(kps_phone.time,kps_phone.right_wrist_x,'LineWidth',1.5,'Color','b');
plot(kps_kinect_cali.time,kps_kinect_cali.right_elbow_x,'LineWidth',1.5,'Color','g','LineStyle','--');
plot(kps_kinect_cali.time,kps_kinect_cali.right_wrist_x,'LineWidth',1.5,'Color','g');
xlabel('Time (s)');
ylabel('Pixel');
legend({'Mediapipe elbow(R)','Mediapipe wrist(R)','KinectV2 elbow(R)','KinectV2 wrist(R)'},'Location','Northeast')

figure(105)
title('Y-axis time series data while performing right shoulder abduction');
hold on;
plot(kps_phone.time,kps_phone.right_elbow_y,'LineWidth',1.5,'Color','b','LineStyle','--');
plot(kps_phone.time,kps_phone.right_wrist_y,'LineWidth',1.5,'Color','b');
plot(kps_kinect_cali.time,kps_kinect_cali.right_elbow_y,'LineWidth',1.5,'Color','g','LineStyle','--');
plot(kps_kinect_cali.time,kps_kinect_cali.right_wrist_y,'LineWidth',1.5,'Color','g');
xlabel('Time (s)');
ylabel('Pixel');
legend({'Mediapipe elbow(R)','Mediapipe wrist(R)','KinectV2 elbow(R)','KinectV2 wrist(R)'},'Location','Northeast')

%% Calculate difference TEST

kps_diff = eval(kps_kinect{:,:})- kps_phone{:,:};


%% TEST


leftankleK_loc = [median(kps_kinect_cali.left_ankle_x), median(kps_kinect_cali.left_ankle_y)];
leftankleP_loc = [median(kps_phone.left_ankle_x), median(kps_phone.left_ankle_y)];
cali= leftankleP_loc - leftankleK_loc;

kps_kinect_cali{:,2:2:26} = kps_kinect_cali{:,2:2:26} - cali(1);
kps_kinect_cali{:,3:2:27} = kps_kinect_cali{:,3:2:27} + 169.33;