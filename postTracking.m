clc; clear; close all

dataset = 3; % change this to pick from available datasets

% add all subfolders to execution
addpath(genpath('C:\Users\logan\Desktop\Navbit_Work')) 

if dataset == 1
    load('trackResultsBungled2.mat')
    stat = [];
    for i = 1:12
     stat = [trackResults(i).status, " ", stat]; %#ok<AGROW> 
    end
    
    tchan = sum(stat == "T");
    settings.numberOfChannels = tchan;
    settings.symbolRate = int32 (250);
    settsearchStartOffset = 50;
    for i = 1:tchan
        trackData(i,:) = trackResults(i).I_P; %#ok<SAGROW> 
    end
    settings.msToProcess = length(trackData(1,:))*4; %2*60*1000;
    % get possible navbit patterns - carrying the 180 phase ambiguity through this whole process
    [bmat, bmatalt] = makebits(trackData,settsearchStartOffset);
    [firstPage2, activeChnList] = findPreambles(trackResults, ...
                                                        settings,1:tchan);
    decodeInterResult = decodeInterleaving(trackResults, settings, ...
                                   firstPage2, 1:tchan , zeros(1,tchan));
end

%% other datasets
if dataset == 2
    load('trackData_GalileoE1_Chapter4.mat')

    tchan = size(trackData.gale1b.channel); % channels that contain tracking data
    tchan = tchan(2);
    settings.numberOfChannels = tchan;

    for i = 1:tchan
        trackdata(i,:) =trackData.gale1b.channel(i).promptCode; %#ok<SAGROW> 
    end
    settings.symbolRate = int32 (250);
    settsearchStartOffset = 50; 
        trackData = trackdata;
    % get possible navbit patterns - carrying the 180 phase ambiguity through this whole process
    [bmat, bmatalt] = makebits(trackData);
    
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
    settings.symbolRate = int32 (250);
    settsearchStartOffset = 50;
    settings.numberOfChannels = tchan;
    for i = 1:tchan
        trackData(i,:) = trackResults(i).data_I_P; 
    end
    % get possible navbit patterns - carrying the 180 phase ambiguity through this whole process
    [bmat, bmatalt] = makebits(trackData);
    [firstPage2, activeChnList] = findPreambles(trackResults, settings,activeChnList);
    decodeInterResult = decodeInterleaving(trackResults, settings, ...
                                   firstPage2, 1:tchan , zeros(1,tchan));
    decodeFECResult = decodeFEC(decodeInterResult, settings, firstPage2 , activeChnList);
    CRCresult = cyclicRedundancyCheck(decodeFECResult, activeChnList);
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

% extract bits
for j = 1:tchan
    bits_1= bmat(j,~isnan(bmat(j,:)));
    bits_2 = bmatalt(j,~isnan(bmatalt(j,:)));
    
    [pstart,check,firstPage] = ...
        findsync(bits_1);
    [pstart_alt,check_alt,firstPage_alt] = ...
        findsync(bits_2); 

    % get deinterleved symbols
    dis_1 = makepages(bits_1,firstPage(2));
    dis_2 = makepages(bits_2,firstPage_alt(2));
    
    % decode symbols into bits using viterbi methods
    vit_bit_1 = viterbiGalileo(dis_1);
    vit_bit_2 = viterbiGalileo(dis_2);

    % perform cyclical redundancy check
    CRC_1 = CRC(vit_bit_1);
    CRC_2 = CRC(vit_bit_2);

    % decode words
    
end
