clc; clear; close all

dataset = 4; % change this to pick from available datasets

% add all subfolders to execution
addpath(genpath('C:\Users\logan\Desktop\Navbit_Work')) 

if dataset == 1
    load('trackResultsBungled2.mat')
    stat = [];
    for i = 1:12
     stat = [trackResults(i).status, " ", stat]; %#ok<AGROW> 
    end
    
    tchan = sum(stat == "T");
    settings.msToProcess        = 40000;        %[ms]      
    settings.numberOfChannels = tchan;
    settings.symbolRate = int32 (250);
    settsearchStartOffset = 50;
    settings.navSolRate = 5; %[Hz]
    settings.navSolPeriod = 1000/settings.navSolRate; %ms

    for i = 1:tchan
        trackData(i,:) = trackResults(i).I_P; %#ok<SAGROW> 
    end
    settings.msToProcess = length(trackData(1,:))*4; %2*60*1000;
    % get possible navbit patterns - carrying the 180 phase ambiguity through this whole process
    [bmat, bmatalt] = makebits(trackData);
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

    %settings
    settings.numberOfChannels = tchan;
    settings.symbolRate = int32 (250);
    settings.numberOfChannels = tchan;
    settings.msToProcess        = 40000;        %[ms]      
    settings.symbolRate = int32 (250);
    settsearchStartOffset = 50;
    settings.navSolRate = 5; %[Hz]
    settings.navSolPeriod = 1000/settings.navSolRate; %ms
    
    for i = 1:tchan
        trackData(i,:) = trackResults(i).data_I_P; 
    end
    % get possible navbit patterns - carrying the 180 phase ambiguity through this whole process
    [bmat, bmatalt] = makebits(trackData);
    [firstPage2, activeChnList] = findPreambles(trackResults, settings,activeChnList);
    [PageStart,activeChnList] = findPreambles(trackResults, settings,activeChnList);
    decodeInterResult = decodeInterleaving(trackResults, settings, ...
                                   firstPage2, 1:tchan , zeros(1,tchan));
    decodeFECResult = decodeFEC(decodeInterResult, settings, firstPage2 , activeChnList);
    CRCresult = cyclicRedundancyCheck(decodeFECResult, activeChnList);
    settings.msToProcess = length(trackData(1,:))*4; %2*60*1000;
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
    [bmat, bmatalt] = makebits(trackData);
    [firstPage, activeChnList] = findPreambles(trackResults, settings,activeChnList);
    [PageStart,activeChnList] = findPreambles(trackResults, settings,activeChnList);

end
%% find preambles 

count = 1;
fp_final = [];

% extract bits
for j = 1:tchan
    bits_1= bmat(j,~isnan(bmat(j,:)));
    
    [pstart,check,firstPage] = findsync(bits_1);

    % get deinterleved symbols
    dis = makepages(bits_1,firstPage(1));
    
    % decode symbols into bits using viterbi methods
    vit_bit = viterbiGalileo(dis);

    % perform cyclical redundancy check
    CRC_1 = CRC(vit_bit);
    CRC_2 = CRC_1;

    while sum(CRC_1.result ~= 0) > length(CRC_1.result)*.2 && ...
            sum(CRC_2.result ~= 0) > length(CRC_2.result)*.2
        % get deinterleved symbols
        dis = makepages(bits_1,firstPage(1+count));
        
        % decode symbols into bits using viterbi methods
        vit_bit = viterbiGalileo(dis);
    
        % perform cyclical redundancy check
        CRC_1 = CRC(vit_bit);

        if sum(CRC_1.result ~= 0) > length(CRC_1.result)*.2 
            vit_bit_2 = viterbiGalileo(-1*dis);
            CRC_2 = CRC(vit_bit_2);
        end

        % try next flag if this one didn't work
        count = count + 1; 
        if count+1 > length(firstPage)
            disp('Could not validate via CRC! Exiting.');
            return; 
        end
    end

    if sum(CRC_2.result ~= 0) < length(CRC_2.result)*.2
        CRC_1 = CRC_2;
    end
    
    % decode words
    [eph(trackResults(j).PRN), TOW] = decodeEphemeris(CRC_1);
    fp_final(j) = firstPage(count); %#ok<SAGROW> 
end

navSolutions = PVT(activeChnList, TOW, trackResults, settings, PageStart,eph);
settings = initSettings();
%plotNavigation(navSolutions, settings);

 %--- Satellite sky plot -----------------------------------------------
 handles(1, 1) = subplot(1, 1, [1, 1]);  
    skyPlot(handles(1, 1), ...
            navSolutions.channel.az, ...
            navSolutions.channel.el, ...
            navSolutions.channel.PRN(:, 1));
        
    title (handles(1, 1), ['Sky plot (mean PDOP: ', ...
                               num2str(mean(navSolutions.DOP(2,:))), ')']);  