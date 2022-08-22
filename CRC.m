function [CRCresult] = CRC(viterbi_output)
%--------------------------------------------------------------------------
% Description:
%     
%     This function accepts the decoded navigation symbols and processes
%     them against the CRC to detect error
%
% Inputs: 
% 
%     viterbi_output     - bits after the processing of decoding FEC with
%                          Viterbi decoder.
%
% Retuns:
% 
%      CRCresult(channelNr).result(i)  - record if the CRC is successful
%                                        for channelNr in word i
%
%      CRCresult(channelNr).Word(i) - record 128 bits data to compose 
%                                     every single word in Galileo message.
%
%--------------------------------------------------------------------------

    % Calculate the total nominal page number need to be processed.
    PageNr = floor((length(viterbi_output)-1)/240);
    % adjust the start point according to page type (odd or even).
    if viterbi_output(1) == 0
        startPoint =1;
    else
        startPoint =121;
    end
    % take CRC for process every nominal page
    for i =1:PageNr

        %extract data bits of one word in Galileo meassage.
        Page = viterbi_output(startPoint+(i-1)*...
                240:startPoint-1+i*240);

        % construct the nominal page
        nomPage = [Page(1:120-6),Page(121:240-14)];

        % CRC Generator polynomials from SIS document
        Polynomials = zeros(1,25);
        index = [0, 1, 3, 4, 5, 6, 7, 10, 11, 14, 17, 18, 23, 24] + 1;
        Polynomials(1,index) = 1;
        % want this in descending powers of x
        Polynomials = flip(Polynomials,2);

        % implement CRC.
        R = length(Polynomials) - 1; 
        % carry out polynomial division and compare to 24 bit CRC
        [~,r] = deconv(nomPage,Polynomials);
        r2 = mod(r(end-R+1:end),2);

        % Record the status and the data bits for every word if CRC is passed.
        if sum(r2==0)==length(r2)
            CRCresult.result(i) = 0;
            WordContent =[Page(3:120-6),Page(123:138)];
            CRCresult.Word(1+128*(i-1):128*i)=WordContent;
        else
        %Record the status if CRC is not passed.
            CRCresult.result(i) = 1;
        end
    end

end