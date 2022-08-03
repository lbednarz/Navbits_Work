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
navbitrel = NaN.*correlationData;

if arg == "bit_twos"

    bmat = NaN * correlationData;
    for j = 1:tchan
        navbitrel(j,1:length(correlationData(j,:))) = correlationData(j,:);
        bitstream = navbitrel(j,:);
        bitstream = bitstream(~isnan(navbitrel(j,:))); % just the non NaN entries of bitstream
        odd = 1:2:length(bitstream);
        for i = 1:length(bitstream)/2
            bmat(j,i) = sign(bitstream(odd(i)));
        end
    end

bmatalt = bmat*-1;
bits = bmat;
bits_alt = bmatalt;

end

if arg == "bit_ones"

    bits = sign(correlationData);
    bits_alt = -1*bits;
    
end

if arg == "sum"
    bmat = NaN * zeros(tchan, length(correlationData(1,:))*.5);
    for i = 1:tchan
        Ip = correlationData(i,:);
        bmat(i,1:length(Ip)/2) = Ip(1:2:end) + Ip(2:2:end);
    end
    bits = sign(bmat);
    bits(bits == 0) = 1;
    bits_alt = -1*bits;
end


