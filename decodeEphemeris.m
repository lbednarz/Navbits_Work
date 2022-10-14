function [eph, TOWSecond] = decodeEphemeris(CRC)
%--------------------------------------------------------------------------
% Description:
%     
%     This function takes in the CRC-validated navbit stream (after viterbi
%     decoding) and performs the ephemeris decoding. 
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

% how many digits of PI galileo uses for their calculations 
GalileoPi = 3.1415926535898;


% grab 1 subframe, which is 15 pages
for j = 1:floor(length(CRC.Word)/240)
    for i = 1:15 
        % get one word and add it to the subframe
        word = CRC.Word(1+(i-1)*128:i*128);
        subframebits = dec2bin(word)';
        
        % get word type 
        wt = bin2dec(subframebits(1:6));

        assert(wt <= 15 && wt >= 0);

       switch wt
            case 0
               eph.weekNumber   = bin2dec(subframebits(97:97+12-1));   
               TOWSecond        = bin2dec(subframebits(109:109+20-1));   
               TOWSecond        = mod(TOWSecond,604800); 
               updateI          = i;  
               eph.WordType0    = true;  
            case 1 
                eph.IODC1       = bin2dec(subframebits(7:7+10-1));  
                eph.t_oe        = bin2dec(subframebits(17:17+14-1))*60;
                eph.M_0         = twosComp2dec(subframebits(31:31+32-1))* 2^(-31)*GalileoPi; 
                eph.e           = bin2dec(subframebits(63:63+32-1))* 2^(-33);       
                eph.sqrtA       = bin2dec(subframebits(95:95+32-1))* 2^(-19);       
           case 2 
                eph.IODC2       = bin2dec(subframebits(7:7+10-1));   
                eph.omega_0     = twosComp2dec(subframebits(17:17+32-1))* 2^(-31)*GalileoPi;      
                eph.i_0         = twosComp2dec(subframebits(49:49+32-1))* 2^(-31)*GalileoPi; 
                eph.omega       = twosComp2dec(subframebits(81:81+32-1))* 2^(-31)*GalileoPi; 
                eph.iDot        = twosComp2dec(subframebits(113:113+14-1))* 2^(-43)*GalileoPi; 
           case 3      
                eph.IODC3       = bin2dec(subframebits(7:7+10-1));   
                eph.omegaDot    = twosComp2dec(subframebits(17:17+24-1))* 2^(-43)*GalileoPi;      
                eph.deltan      = twosComp2dec(subframebits(41:41+16-1))* 2^(-43)*GalileoPi; 
                eph.C_uc        = twosComp2dec(subframebits(57:57+16-1))* 2^(-29); 
                eph.C_us        = twosComp2dec(subframebits(73:73+16-1))* 2^(-29); 
                eph.C_rc        = twosComp2dec(subframebits(89:89+16-1))* 2^(-5); 
                eph.C_rs        = twosComp2dec(subframebits(105:105+16-1))* 2^(-5);         
                eph.SISA_E1E5b  = bin2dec(subframebits(121:121+8-1));   
           case 4      
                eph.IODC4       = bin2dec(subframebits(7:7+10-1));   
                PRN             = bin2dec(subframebits(17:17+6-1));   %SVID
                eph.C_ic        = twosComp2dec(subframebits(23:23+16-1))* 2^(-29); 
                eph.C_is        = twosComp2dec(subframebits(39:39+16-1))* 2^(-29); 
                
                eph.t_oc        = bin2dec(subframebits(55:55+14-1))*60;   %(E1,E5b)£¬Single-frequency E1
                eph.a_f0        = twosComp2dec(subframebits(69:69+31-1))* 2^(-34); 
                eph.a_f1        = twosComp2dec(subframebits(100:100+21-1))* 2^(-46); 
                eph.a_f2        = twosComp2dec(subframebits(121:121+6-1))* 2^(-59);       
           case 5        
                eph.ai0         = bin2dec(subframebits(7:7+11-1))* 2^(-2); 
                eph.ai1         = twosComp2dec(subframebits(18:18+11-1))* 2^(-8); 
                eph.ai2         = twosComp2dec(subframebits(29:29+14-1))* 2^(-15); 
                eph.Region1     = bin2dec(subframebits(43:43+1-1));   
                eph.Region2     = bin2dec(subframebits(44:44+1-1));   
                eph.Region3     = bin2dec(subframebits(45:45+1-1));   
                eph.Region4     = bin2dec(subframebits(46:46+1-1));   
                eph.Region5     = bin2dec(subframebits(47:47+1-1));   
                eph.BGD_E1E5a   = twosComp2dec(subframebits(48:48+10-1))* 2^(-32);   
                eph.BGD_E1E5b   = twosComp2dec(subframebits(58:58+10-1))* 2^(-32); %Single-frequency E1   
                eph.T_GD        = eph.BGD_E1E5b;
                
                
                eph.E5b_HS      = bin2dec(subframebits(68:68+2-1)); %signal health  ,0:Signal OK 
                eph.E1B_HS      = bin2dec(subframebits(70:70+2-1));   
                eph.E5b_DVS     = bin2dec(subframebits(72:72+1-1)); %data validity status    ,0:Navigation data valid
                eph.E1B_DVS     = bin2dec(subframebits(73:73+1-1));   
                
                eph.weekNumber = bin2dec(subframebits(74:74+12-1));   
                TOWSecond      = bin2dec(subframebits(86:86+20-1));   
                TOWSecond      = mod(TOWSecond,604800); 
                updateI        = i;
                eph.WordType5  = true;  
           case 6       
                eph.d_A0       = twosComp2dec(subframebits(7:7+32-1))* 2^(-30); 
                eph.d_A1       = twosComp2dec(subframebits(39:39+24-1))* 2^(-50);         
                eph.d_DeltaT_LS= twosComp2dec(subframebits(63:63+8-1));        
                eph.d_t_OT     = bin2dec(subframebits(71:71+8-1))*3600;        
                eph.i_WN_T     = bin2dec(subframebits(79:79+8-1));        
                eph.i_WN_LSF   = bin2dec(subframebits(87:87+8-1));        
                eph.i_DN       = bin2dec(subframebits(95:95+3-1));        
                eph.d_DeltaT_LSF= twosComp2dec(subframebits(98:98+8-1));
                TOWSecond      = bin2dec(subframebits(106:106+20-1));   
                TOWSecond      = mod(TOWSecond,604800); 
                updateI        = i;
                eph.WordType6  = true;  
           case 10  
                eph.d_A0G      = twosComp2dec(subframebits(87:87+16-1))* 2^(-35); 
                eph.d_A1G      = twosComp2dec(subframebits(103:103+12-1))* 2^(-51); 
                eph.d_t_OG     = bin2dec(subframebits(115:115+8-1))*3600;        
                eph.i_WN_G     = bin2dec(subframebits(123:123+6-1));        
                
                eph.WordType10 = true;  
        end
    end

    % make a offset to the TOW of the first nominal page,
    TOWSecond=TOWSecond-updateI*2+2;
end