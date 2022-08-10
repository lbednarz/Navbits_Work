function [decodeResult] = viterbiGalileo(dis)
%--------------------------------------------------------------------------
% decode interleaving from the data channel
%   Inputs:
%       dis                - symbols after the processing of interleaving 
%
%   Outputs:
%       decodeFECResult    - bits after the processing of decoding FEC with
%                            Viterbi decoder.
%--------------------------------------------------------------------------

% The number of pages in data channel. (One page is 1 second, and the 
% nominal page of Galileo I/NAV is 2 pages)
PageNr = floor(length(dis)/240);    
for i = 1:PageNr

        symbols = dis((i-1)*240+1:i*240);

        % Convert to symbol.(240 symbols)
        symbols (symbols == 1 ) =  -1;
        symbols (symbols == 0 ) =   1;

        %Take into account the NOT gate in G2 polynomial (Galileo ICD Figure 13, FEC encoder),figure 13. Convolutional Coding Scheme
        symbols(2:2:end)=-1*symbols(2:2:end);
        %make a offset to the delay of viterbi decoder
        tbl=32;
        Symbols_vitdec=[symbols,ones(1,2*tbl)];
        %Generator polynomials
        trellis = poly2trellis(7,[171 133]);
        %implement Viterbi decoder
        decodeBits = vitdec(Symbols_vitdec,trellis,tbl,'cont','unquant');
        decodeBits = decodeBits(tbl+1:end);
        %Record result of decoding FEC
        decodeResult((i-1)*120+1:120*i)=decodeBits;
end
