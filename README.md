This repository implements the 3D human pose estimation algorithm introduced in the following paper:
> Monocap: Monocular human motion capture using a CNN coupled with a geometric prior. X. Zhou, M. Zhu, G. Pavlakos, S. Leonardos, K.G. Derpanis, K. Daniilidis. IEEE Transactions on Pattern Analysis and Machine Intelligence (T-PAMI), 2018. Accepted.

## How to use?
1. Download data by running the following script in command line:
```bash data.sh```
2. Open MATLAB and run:
```startup```
3. Run the demo scripts:
- demoH36M for an example from Human3.6M dataset
- demoHG for an example of how to use our algorithm combined with the "Stacked hourglass network"
- demoMPII for an example of how to reconstruct 3D poses from a single image from MPII dataset

## Notes:
- The code for hourglass network in pose-hg-demo is from Newell et al., https://github.com/anewell/pose-hg-demo
- See the comments in demoHG.m for how to run hourglass network on your images and save heatmaps
- If you want to use the hourglass network, you need to first install Torch and make it work
- Generally "Hourglass network" + "poseDict-all-K128" (pose dictionary learned from Human3.6M) work well. For better 3D reconstruction, you can learn a 3D pose dictionary using your own mocap data. For more details on pose dictionary learning, please see the following project: [sparse representation for shape estimation](http://cis.upenn.edu/~xiaowz/shapeconvex.html)
- The optimization could be accelerated by changing the initialization method to alternating by changing the option when calling PoseFromVideo: 
```PoseFromVideo(...,'InitialMethod','altern')```