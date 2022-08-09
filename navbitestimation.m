clc; clear; close all

dataset = 1; % change this to pick from available datasets

addpath(genpath('C:\Users\logan\Desktop\FGI-GSRx')) % add all subfolders to execution
addpath(genpath('C:\Users\logan\Desktop\Navbit_Work')) % add all subfolders to execution

if dataset == 1
    load('.\trackResultsBungled.mat')
    stat = [];
    for i = 1:12
     stat = [trackResults(i).status, " ", stat];  %#ok<AGROW> 
    end
    
    tchan = sum(stat == "T");
    for i = 1:tchan
        trackData(i,:) = trackResults(i).I_P;%#ok<SAGROW> 
    end
    % get possible navbit patterns - carrying the 180 phase ambiguity through this whole process
    [bmat, bmatalt] = makebits(trackData, tchan, "sum");
end

if dataset == 2
    load('.\trackData_GalileoE1_Chapter4.mat')

    tchan = size(trackData.gale1b.channel); % channels that contain tracking data
    tchan = tchan(2);

    for i = 1:tchan
        trackdata(i,:) =trackData.gale1b.channel(i).promptCode; %#ok<SAGROW> 
    end
        trackData = trackdata;
    % get possible navbit patterns - carrying the 180 phase ambiguity through this whole process
    [bmat, bmatalt] = makebits(trackData, tchan, "sum");
end

if dataset == 3
    load('C:\Users\logan\Desktop\Navbit_Work\E1SDR\GNSS_SDR_GalileoE1-master\trackingResults.mat')
    
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
    [bmat, bmatalt] = makebits(trackData, tchan, "sum");
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
    [bmat, bmatalt] = makebits(trackData, tchan, "sum");
    [firstPage, activeChnList] = findPreambles(trackResults, settings,activeChnList);

end
%% find preambles 

pstarth = NaN * zeros(tchan,length(trackData(1,:))/2); % the h's on the end mean "hold" since we're going to be populating this NaN matrix w our flagging results 
pstart_alth = pstarth; checkh = pstarth; check_alth = pstarth;
% extract bits
for j = 1:tchan
    bits_1= bmat(~isnan(bmat(j,:)));
    bits_2 = bmatalt(~isnan(bmatalt(j,:)));
    
    [pstart,check,firstPage(j)] = ...
        findsync(bits_1, "bits");
    [pstart_alt,check_alt,firstPage_alt(j)] = ...
        findsync(bits_2,"bits");
    
    pstarth(j,1:length(pstart)) = pstart;
    checkh(j,1:length(check)) = check;
    pstart_alth(j,1:length(pstart_alt)) = pstart_alt;
    check_alth(j,1:length(check_alt)) = check_alt;

    % re-encode into binary
    bits_1(bits_1 == -1) = 1;
    bits_1(bits_1 == 0) = 1;
    bits_1(bits_1 == 1) = 0;
    bits_2(bits_2 == -1) = 1;
    bits_2(bits_2 == 0) = 1;
    bits_2(bits_2 == 1) = 0;

    % decode bits
    trellis = poly2trellis(7,[171 133]);
    sym_1 = convenc(bits_1,trellis);
    sym_2 = convenc(bits_2,trellis);
    
    tb = 240;
    decoded_1 = vitdec(sym_1,trellis,tb,'trunc','hard');
    decoded_2 = vitdec(sym_2,trellis,tb,'trunc','hard');
    
    % de-interleve
    bits_deint_1 = [];
    bits_deint_2 = [];
    
    for i = 1:floor(length(decoded_1)/240)
        deint_1 = decoded_1((i-1)*240+1:240*i); % grab one interleaved frame 
        deint_2 = decoded_2((i-1)*240+1:240*i);
        
        page_1 = reshape(deint_1,30,8);
        page_2 = reshape(deint_2,30,8);
    
        bits_deint_1 = horzcat(bits_deint_1,reshape(page_1',1,[])); %#ok<AGROW> 
        bits_deint_2 = horzcat(bits_deint_2,reshape(page_2',1,[])); %#ok<AGROW> 
    end
end
