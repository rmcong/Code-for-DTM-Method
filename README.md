# Code-for-DTM-Method
Going from RGB to RGBD saliency: A depth-guided transformation model, IEEE Transactions on Cybernetics, 2019.

1. This code is for the paper: 

Runmin Cong, Jianjun Lei, Huazhu Fu, Junhui Hou, Qingming Huang, and Sam Kwong, Going from RGB to RGBD saliency: A depth-guided transformation model, IEEE Transactions on Cybernetics, vol. 50, no. 8, pp. 3627-3639, 2020.

It can only be used for non-comercial purpose. If you use this code, please cite our papers.

The related works include:

[1] Runmin Cong, Jianjun Lei, Huazhu Fu, Ming-Ming Cheng, Weisi Lin, and Qingming Huang, Review of visual saliency detection with comprehensive information, IEEE Transactions on Circuits and Systems for Video Technology, vol. 29, no. 10, pp. 2941-2959, 2019.

[2] Runmin Cong, Jianjun Lei, Changqing Zhang, Qingming Huang, Xiaochun Cao, Chunping Hou, Saliency detection for stereoscopic images based on depth confidence analysis and multiple cues fusion, IEEE Signal Processing Letters, vol.23, no.6, pp.819-823, 2016.

2. This matlab code is tested on Windows 10 64bit with MATLAB 2014a. 

3. Usage:

(1) put the test images into file 'data/RGB/', depth maps into file 'data/depth/', and original RGB saliency maps into file 'data/RBD/'

In this example, we use RBD method [@] to generate the initial saliency map for each image and save into file 'data/RBD/'.

[@] W. Zhu, S. Liang, Y. Wei, and J. Sun, “Saliency optimization from robust background detection,” in CVPR, 2014, pp. 2814–2821.

(2) run demo_DTM.m
the final  RGBD saliency maps with suffix '_DTM.png' are generated and saved in the file 'results/DTM/'

For any questions, please contact rmcong@126.com  runmincong@gmail.com.
