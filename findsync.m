function [pstart,check] = findsync(bits, arg)
%--------------------------------------------------------------------------
% Description:
%     
%     This function takes in the navbits in 1's and 0's and identifies
%     where the sync patterns begin for a given I/NAV page. It also returns
%     a vector that describes the distance between preambles, which should
%     always be 130 bits (not symbols) for a valid page. These pages can 
%     then be ecoded into their symbol form before deinterleaving. 
%
% Inputs: 
% 
%     bits - the navigation bits in 1's and 0's
%     
%     arg - temporary option to pick a theory of how the sync flagging
%     works.
%
% Retuns:
% 
%     pstart - the index where a page begins 
%
%     check - the distance between sync flags
%
%--------------------------------------------------------------------------
sync = [1 -1 1 -1 -1  1 1 1 1 1];

if arg == "bits"
    pstart = xcorr(bits, sync);
    
    % determine a threshold cross-correlation that suggests a sync pattern
    th = 10;
    flag = find(abs(pstart) >= th);
    
    check = diff(flag);
    %pstart = pstart(check == 130);
end

if arg == "symbols"
    % decode bits into symbols
    trellis = poly2trellis(7,[171 133]);
    sym = convenc(bits,trellis);  

    % then carry out regular correlation process
    pstart = xcorr(sym, sync);
    
    % determine a threshold cross-correlation that suggests a sync pattern
    th = max(pstart);
    flag = find(abs(pstart) >= th);
    
    check = diff(flag);
    pstart = pstart(check == 250);
end

if isempty(pstart)
    disp('Could not find valid sync pattern in channel!');
end

