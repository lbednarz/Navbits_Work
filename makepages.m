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
dis= [];

for j = 1:floor(length(bits)/250)

    % grab 240 symbols after sync patterns. This is a nominal page.
    sym = bits((j-1)*250 + 11:250*j);

    % de-interleve
    page = reshape(sym,30,8);
    dis = horzcat(dis,reshape(page',1,[])); %#ok<AGROW> 

end