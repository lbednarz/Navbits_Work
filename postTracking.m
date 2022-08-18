clc; clear; close all

dataset = 1; % change this to pick from available datasets

% add all subfolders to execution
addpath(genpath('/home/loganbednarz/Documents/GitHub/')) 

if dataset == 1
    load('trackResultsBungled2.mat')
    stat = [];
    for i = 1:12
     stat = [trackResults(i).status, " ", stat];  %#ok<AGROW> 
    end
    
    tchan = sum(stat == "T");
    settings.numberOfChannels = tchan;
    for i = 1:tchan
        trackData(i,:) = trackResults(i).I_P;%#ok<SAGROW> 
    end
    % get possible navbit patterns - carrying the 180 phase ambiguity through this whole process
    [bmat, bmatalt] = makebits(trackData, tchan);
    [firstPage2, activeChnList] = findPreambles(trackResults, ...
                                                        settings,1:tchan);
end

if dataset == 2
    load('trackData_GalileoE1_Chapter4.mat')

    tchan = size(trackData.gale1b.channel); % channels that contain tracking data
    tchan = tchan(2);
    settings.numberOfChannels = tchan;

    for i = 1:tchan
        trackdata(i,:) =trackData.gale1b.channel(i).promptCode; %#ok<SAGROW> 
    end
        trackData = trackdata;
    % get possible navbit patterns - carrying the 180 phase ambiguity through this whole process
    [bmat, bmatalt] = makebits(trackData, tchan);
end

if dataset == 3
    load('trackingResults.mat')
    settings.numberOfChannels = 6;
    activeChnList = find([trackResults.status] ~= '-');

    stat = [];
    for i = 1:6
     stat = [trackResults(i).status, " ", stat];  %#ok<AGROW> 
    end
    
    tchan = sum(stat == "T");
    settings.numberOfChannels = tchan;
    for i = 1:tchan
        trackData(i,:) = trackResults(i).data_I_P; 
    end
    % get possible navbit patterns - carrying the 180 phase ambiguity through this whole process
    [bmat, bmatalt] = makebits(trackData, tchan);
    [firstPage, activeChnList] = findPreambles(trackResults, settings,activeChnList);

end

if dataset == 4 
    load('OAKBAT.mat')
    
    settings.numberOfChannels = 6;
    activeChnList = find([trackResults.status] ~= '-');

    stat = [];
    for i = 1:6
     stat = [trackResults(i).status, " ", stat];  %#ok<AGROW> 
    end
    
    tchan = sum(stat == "T");
    for i = 1:tchan
        trackData(i,:) = trackResults(i).data_I_P; 
    end
    % get possible navbit patterns - carrying the 180 phase ambiguity through this whole process
    [bmat, bmatalt] = makebits(trackData, tchan);
    [firstPage, activeChnList] = findPreambles(trackResults, settings,activeChnList);

end
%% find preambles 

pstarth = NaN * zeros(tchan,length(trackData(1,:))/2); % the h's on the end mean "hold" since we're going to be populating this NaN matrix w our flagging results 
pstart_alth = pstarth; checkh = pstarth; check_alth = pstarth;
% extract bits
for j = 1:tchan
    bits_1= bmat(~isnan(bmat(j,:)));
    bits_2 = bmatalt(~isnan(bmatalt(j,:)));
    
    [pstart,check,firstPage] = ...
        findsync(bits_1);
    [pstart_alt,check_alt,firstPage_alt] = ...
        findsync(bits_2); 
    
    % re-encode into binary
    bits_1(bits_1 == -1) = 1;
    bits_1(bits_1 == 0) = 1;
    bits_1(bits_1 == 1) = 0;
    bits_2(bits_2 == -1) = 1;
    bits_2(bits_2 == 0) = 1;
    bits_2(bits_2 == 1) = 0;

    % get deinterleved symbols
    dis_1 = makepages(bits_1,firstPage);
    dis_2 = makepages(bits_2,firstPage_alt);
    
    % decode symbols into bits using viterbi methods
    vit_bit_1 = viterbiGalileo(dis_1);
    vit_bit_2 = viterbiGalileo(dis_2);

    % perform cyclical redundancy check
    CRC_1 = CRC(vit_bit_1);
    CRC_2 = CRC(vit_bit_2);
end
