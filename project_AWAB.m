% Clear the workspace and functions
clc;
clear all;
clear functions;

%% Define the parameters of the KUKA KR6 R900
d1 = 400; % Length of link 1 (mm)
a2 = 400; % Length of link 2 (mm)
a3 = 560; % Length of link 3 (mm)
d4 = 515; % Length of link 4 (mm)
d6 = 90;  % Length of link 6 (mm)

%% Create the links of the manipulator
L(1) = Link([0 d1 0 pi/2]);  % Link 1
L(2) = Link([0 0 a2 0]);      % Link 2
L(3) = Link([0 0 a3 0]);      % Link 3
L(4) = Link([0 d4 0 pi/2]);   % Link 4
L(5) = Link([0 0 0 -pi/2]);   % Link 5
L(6) = Link([0 d6 0 pi/2]);   % Link 6

%% Create the serial link robot
robot = SerialLink(L, 'name', 'KUKA KR6 R900');

%% Define a series of joint configurations
q1 = zeros(1, 6); % Home position
q2 = [pi/6, -pi/4, pi/3, -pi/6, pi/4, -pi/3]; % Some arbitrary position
q3 = [-pi/6, pi/4, -pi/3, pi/6, -pi/4, pi/3]; % Another arbitrary position
q4 = [pi/3, -pi/6, pi/4, -pi/3, pi/6, -pi/4]; % Another arbitrary position

% Combine the joint configurations into a matrix
qMatrix = [q1; q2; q3; q4];

%% Simulate the robot moving through the joint configurations
figure;
for i = 1:size(qMatrix, 1)
    robot.plot(qMatrix(i, :));
    pause(1); % Pause for 1 second between each configuration
end

%% Forward Kinematics Verification
% Compute the forward kinematics of the robot at the home position
T_06 = robot.fkine(zeros(1,6)); % Forward kinematics at home position (0,0,0,0,0,0)

% Display the forward kinematics transformation matrix (T_0_6)
disp('Forward Kinematics (Transformation Matrix T_0_6):');
disp(T_06);

% Ensure T_06 is a 4x4 matrix
disp('Size of T_06:');
disp(size(T_06));

% Extract the position (x, y, z) from the transformation matrix
if size(T_06,1) == 4 && size(T_06,2) == 4
    position = T_06(1:3, 4); % Extract x, y, z position
    disp('Position of the end-effector (x, y, z):');
    disp(position);
else
    disp('Error: The transformation matrix T_06 is not a 4x4 matrix.');
end

% Extract the orientation (rotation matrix)
if size(T_06,1) == 4 && size(T_06,2) == 4
    orientation = T_06(1:3, 1:3); % Extract the rotation matrix
    disp('Orientation of the end-effector (Rotation Matrix):');
    disp(orientation);
else
    disp('Error: The transformation matrix T_06 is not a 4x4 matrix.');
end

%% Inverse Kinematics Verification
% Define a desired end-effector position (position and orientation)
desired_position = [500; 300; 400];  % Example position (x, y, z)
desired_orientation = eye(3);         % Identity matrix for no rotation

% Combine position and orientation to form the desired transformation matrix
T_desired = [desired_orientation, desired_position; 0 0 0 1];

% Solve for joint angles using inverse kinematics
q_sol = robot.ikine(T_desired, 'mask', [1 1 1 0 0 0]); % Only solve for position (x, y, z)

% Display the joint solutions
disp('Inverse Kinematics Solution (Joint Angles q):');
disp(q_sol);

% Verify the solution by computing the forward kinematics with the obtained joint angles
T_check = robot.fkine(q_sol); 

% Display the computed forward kinematics transformation matrix
disp('Forward Kinematics from the Inverse Kinematics Solution (T_check):');
disp(T_check);

% Verify if the computed forward kinematics is close to the desired transformation matrix
if all(size(T_check) == size(T_desired))
    disp('Difference between desired and computed transformation matrix:');
    disp(T_check - T_desired);
else
    disp('Error: The computed transformation matrix T_check does not match the size of T_desired.');
end

% Plot the robot in the new configuration
robot.plot(q_sol);