% This script demonstrates how to use:
% the proposed EM algorithm + pose dictionary learned from Human3.6M
% + the 2D joint detector described in the paper
% We use a Human3.6M sequence as example

clear

%% load data
% load data including heatmaps, images, etc ...
data = load('data/h36m/S9-Posing 1.55011271.mat');
% load camera parameters
cam = load('data/h36m/camera/S9-Posing 1.55011271.mat');
% load dictionary
dict = load('dict/poseDict-Posing-K64.mat');

%% pose estimation using orthographic camera model
Given2DPose = false;
if Given2DPose
    output = PoseFromVideo('W_gt',data.W_gt,'dict',dict);
else
    output = PoseFromVideo('heatmap',data.heatmap,'dict',dict);
end

%% using perspective camera model if camera parameters are known
output.dict = dict;
output.rootID = 1; % root node in the skeleton tree
output.camera = cam;
output.bbox = data.bbox;
output = perspAdj(output);

%% visualization

nPlot = 4;
figure('position',[300 300 200*nPlot 200]);
for i = 1:length(data.frames)
    clf;
    % heatmap
    subplot('position',[0/nPlot 0 1/nPlot 1]);
    cmap = colormap('jet');
    hmap = size(cmap,1)*mat2gray(sum(data.heatmap(:,:,:,i),3));
    imshow(hmap,cmap);
    % 2D optimized pose
    subplot('position',[1/nPlot 0 1/nPlot 1]);
    imshow(data.img(:,:,:,i));
    vis2Dskel(output.W_proj(2*i-1:2*i,:)*data.scale,dict.skel);
    % 3D reconstructed pose 
    subplot('position',[2/nPlot 0 1/nPlot 1]);
    vis3Dskel(output.S_refine(3*i-2:3*i,:),dict.skel);
    % 3D reconstructed pose in novel view
    subplot('position',[3/nPlot 0 1/nPlot 1]);
    vis3Dskel(output.S_refine(3*i-2:3*i,:),dict.skel,'viewpoint',[-90 0]);
    camroll(5);
    pause(0.01);
end