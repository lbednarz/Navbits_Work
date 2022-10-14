addpath(genpath('C:\Users\logan\Desktop\Navbit_Work')) 
settings = initSettings();
load('trackResultsBungled2.mat')
[navSolutions, eph] = postNavigation(trackResults, settings);
