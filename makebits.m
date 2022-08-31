function [bits, bits_alt] = makebits(correlationData)
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

    bits = correlationData;
    bits(bits > 0)  =  1;
    bits(bits <= 0) = -1;
    bits_alt = -1*bits;

end

