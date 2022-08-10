function [dis] = makepages(bits, firstPage)
%--------------------------------------------------------------------------
% Description:
%     
%     This function takes in the navbits and the index of the first page
%     and performs a decoding into nav symbols. The function then
%     deinterleves.
%
% Inputs: 
% 
%     bits - the navigation bits in 1's and 0's
%     
%     firstPage - the index of the first navigation page. From this index
%     onward, it is assumed the nominal page structure will be retained.
%
% Retuns:
% 
%     dis - The deinterleved symbols of the navigation message
%
%--------------------------------------------------------------------------

% pull all relevant bits 

bits = bits(firstPage:end);

for j = 1:floor(length(bits)/250)

    sym = bits((j-1)*250 + 11:250*j);

    % de-interleve
    bits_deint= [];
    
    for i = 1:floor(length(sym)/240)
        deint = sym((i-1)*240+1:240*i); % grab one interleaved frame 
        
        page = reshape(deint,30,8);
    
        bits_deint = horzcat(bits_deint,reshape(page',1,[])); %#ok<AGROW> 
    end
    dis((j-1)*240+1:j*240) = bits_deint;
end