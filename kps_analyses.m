% >>>>>>>>>>>>>>>>>>>>>>>>>>>>  Data Analysis <<<<<<<<<<<<<<<<<<<<<<<<<<<
% Requires ts_cube input from "ks_timeseries.m" !!!!!  
% Perform analysis on similarity & agreement between Kinect & Mediapipe readings

%% Config
clear 

% =========== ts Cube selection ===========
subject_ID = 'Pilot5_front'
interpol = 'linear'
% ==================================

% Import kps data file
ts_cube = readtable(strcat('D:/SmartRehab/Data_Keypoints/', subject_ID,'_ts_cube_', interpol ,'.csv'));
ts_cube.Time = str2double(cellfun(@(S) S(1:end-4), ts_cube.Time, 'Uniform', 0));

% Breakdown data cube into correpsonding cubes
ts_P = table2timetable(ts_cube(:,3:28),'RowTimes',seconds(ts_cube.Time));
ts_K = table2timetable(ts_cube(:,30:55),'RowTimes',seconds(ts_cube.Time));

cube_P = ts_cube(:,2:28);
cube_K = ts_cube(:,29:55);


%% Correlation 

for i = 1:length(ts_K.Properties.VariableNames)

[R,P,RL,RU] = corrcoef(eval(strcat('ts_K.',ts_K.Properties.VariableNames{i})),...
    eval(strcat('ts_P.',ts_P.Properties.VariableNames{i})));

corrMat.Var(i) = ts_K.Properties.VariableNames(i);
corrMat.R(i) = R(2);
corrMat.RU(i) = RU(2);
corrMat.RL(i) = RL(2);
corrMat.P(i) = P(2);
end

clear R P RL RU 

% Ver 2

[R,P] = corr(cube_K,cube_P);


% for i = 1:length(ts_Kcube.Properties.VariableNames)
%     
%     if corrMat.P(i) > 0.005 && corrMat.P(i) <= 0.05
%         corrMat.Sig(i) = 1;
%         
%     elseif corrMat.P(i) > 0.001 && corrMat.P(i) <= 0.005
%         corrMat.Sig(i) = 2;
%         
%     elseif corrMat.P(i) <= 0.001       
%                 corrMat.Sig(i) = 3;
%         else 
%             corrMat.Sig(i) = 0;
%             end
% end
% 


%% RMSE Analysis























%% % Visualize ALL KINECT timeseries 

TimeVar = eval(strcat(x,'.time'));

figure()
plot(TimeVar,eval(strcat(x,'.head_x')),'DisplayName','head_x');
hold on;
plot(TimeVar,eval(strcat(x,'.head_y')),'DisplayName','head_y');
plot(TimeVar,eval(strcat(x,'.right_shoulder_x')),'DisplayName','right shoulder_x');
plot(TimeVar,eval(strcat(x,'.right_shoulder_y')),'DisplayName','right shoulder_y');
plot(TimeVar,eval(strcat(x,'.left_shoulder_x')),'DisplayName','left shoulder_x');
plot(TimeVar,eval(strcat(x,'.left_shoulder_y')),'DisplayName','left shoulder_y');
plot(TimeVar,eval(strcat(x,'.right_elbow_x')),'DisplayName','right elbow_x');
plot(TimeVar,eval(strcat(x,'.right_elbow_y')),'DisplayName','right elbow_y');
plot(TimeVar,eval(strcat(x,'.left_elbow_x')),'DisplayName','left elbow_x');
plot(TimeVar,eval(strcat(x,'.left_elbow_y')),'DisplayName','left elbow_y');
plot(TimeVar,eval(strcat(x,'.right_wrist_x')),'DisplayName','right wrist_x');
plot(TimeVar,eval(strcat(x,'.right_wrist_y')),'DisplayName','right wrist_y');
plot(TimeVar,eval(strcat(x,'.left_wrist_x')),'DisplayName','left wrist_x');
plot(TimeVar,eval(strcat(x,'.left_wrist_y')),'DisplayName','left wrist_y');
plot(TimeVar,eval(strcat(x,'.right_hip_x')),'DisplayName','right hip_x');
plot(TimeVar,eval(strcat(x,'.right_hip_y')),'DisplayName','right hip_y');
plot(TimeVar,eval(strcat(x,'.left_hip_x')),'DisplayName','left hip_x');
plot(TimeVar,eval(strcat(x,'.left_hip_y')),'DisplayName','left hip_y');
plot(TimeVar,eval(strcat(x,'.right_knee_x')),'DisplayName','right knee_x');
plot(TimeVar,eval(strcat(x,'.right_knee_y')),'DisplayName','right knee_y');
plot(TimeVar,eval(strcat(x,'.left_knee_x')),'DisplayName','left knee_x');
plot(TimeVar,eval(strcat(x,'.left_knee_y')),'DisplayName','left knee_y');
plot(TimeVar,eval(strcat(x,'.right_ankle_x')),'DisplayName','right ankle_x');
plot(TimeVar,eval(strcat(x,'.right_ankle_y')),'DisplayName','right ankle_y');
plot(TimeVar,eval(strcat(x,'.left_ankle_x')),'DisplayName','left ankle_x');
plot(TimeVar,eval(strcat(x,'.left_ankle_y')),'DisplayName','left ankle_y');
hold off;