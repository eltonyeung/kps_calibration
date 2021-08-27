% Correlation 

% Visualize ALL KINECT timeseries 

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