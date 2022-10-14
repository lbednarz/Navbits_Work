% add all subfolders to execution
addpath(genpath('C:\Users\logan\Desktop\Navbit_Work'))
settings = initSettings();
load('OAKBAT.mat');
[navSolutions, eph] = postNavigation(trackResults, settings);