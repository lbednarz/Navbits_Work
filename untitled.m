load('trackResultsBungled.mat')
stat = [];
for i = 1:12
    stat = [trackResults(i).status, " ", stat];  %#ok<AGROW> 
end
    
tchan = sum(stat == "T");
settings.numberOfChannels = tchan;
for i = 1:tchan
    trackResults(i).data_I_P = trackResults(i).I_P; %#ok<SAGROW> 
end