function [bits, bits_alt] = makebits(correlationData, tchan, arg)
%--------------------------------------------------------------------------
% Description: 
%     
%     This script takes in the raw correlation data from the prompt
%     correlatior and produces the navbits in 1's and 0's. After the
%     navbits have been recovered, the sync patterns must be found, which
%     is done in "findsync.m"
% 
% Inputs: 
% 
%     correlationData - the raw prompt correlator output 
% 
%     tchan - the amount of channels that returned a signal lock
% 
%     arg - temporary argument for taking every 2 Ip values and making one
%           bit from them vs taking the sign of every Ip as a bit
%
% Retuns:
% 
%     bits - the navbits in 0's and 1's
%
%     bits_alt - the navbits carrying the 180 degree phase ambiguity 
%                i.e. implying we cant know if the sequence was supposed to
%                start with a 1 or -1 
%--------------------------------------------------------------------------
navbit = zeros(tchan,1000);
navbit_skip = [];
navbitrel = NaN.*ones(tchan,length(correlationData(1,:)));

if arg == "bit_twos"

    for i = 1:1:tchan
     
        I_P = correlationData(i,:);
        x = find(I_P(1:end-1)>0 & I_P(2:end) < 0);
        y = find(I_P(1:end-1)<0 & I_P(2:end) > 0);
        z = [x,y];
        z = sort(z);
        b = diff(z);
        c = rem(b,2);
        a = find(c==0);
    
        nc = a(1);
        navbit(i,1:length(z)) = z;
        
        navbit_skip = [navbit_skip;nc]; %#ok<AGROW> 
        navbitrel(i,1:length(navbit(i,nc:end))) = navbit(i,nc:end); % take relevant navbits 
        navbitrel(i,1:length(navbit(i,nc:end))) = Ip(navbitrel(i,1:length(navbit(i,nc:end))));
        navbitrel(i,:) = Ip(i,:);

    end

    bmat = NaN * navbitrel;
    for j = 1:tchan
        bitstream = navbitrel(j,:);
        bitstream = bitstream(~isnan(navbitrel(j,:))); % just the non NaN entries of bitstream
        odd = 1:2:length(bitstream);
        for i = 1:length(bitstream)/2
            bmat(j,i) = sign(bitstream(odd(i)));
        end
    end

% Re-encode to binary 
bmatalt = bmat*-1;
bmat(bmat == -1) = 0; % case 1
bmatalt(bmatalt == -1) = 0; % case 2

bits = bmat;
bits_alt = bmatalt;

end

if arg == "bit_ones"

    bits = sign(correlationData);
    bits_alt = -1*bits;
    bits(bits == -1) = 0; % case 1
    bits_alt(bits_alt == -1) = 0; % case 2

end


