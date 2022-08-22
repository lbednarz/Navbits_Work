function [bits, bits_alt] = decodeEphemeris()

% % how many digits of PI galileo uses for their calculations 
% galileoPi = 3.1415926535898;
% 
% foundPages = 0;
% 
% for i=1:(length(bits)/240)
% 
% % make bin2dec compatable version of symbol stream
% bitsArrangedPageWise = test2((i-1)*240+1: i*240);
% 
%  % Arrange bits
%     evenOddType = bin2dec(bitsArrangedPageWise(1));
%     pageType(i) = bin2dec(bitsArrangedPageWise(2));
%     if evenOddType == 0 && pageType(i) == 0 % type odd
%         %Arrange the bits into a Word of length 128 bits (112 + 16)        
%         bitsArrangedWordWise(1:112) = bitsArrangedPageWise(3:3+111);
%         bitsArrangedWordWise(113:128) = bitsArrangedPageWise(120+3:120+3+15);
%         wordType(i,:) = bin2dec(bitsArrangedWordWise(1:6)); %#ok<*SAGROW> 
%     else
%         wordType(i,:) = 7; % This is a hack. Othervise we will get funny page numbers. To be checked. SS
%     end
% 
%     % Decode data words
%     switch wordType(i,:) 
%         case 0 % Word Type 0
%             time =  bin2dec(bitsArrangedWordWise(7:8));
%             if time == 2
%                 WN_0 = bin2dec(bitsArrangedWordWise(97:108));
%                 TOW_0 = bin2dec(bitsArrangedWordWise(109:128));
%             else
%                 fprintf('No valid WN & TOW \n');
%             end
%             foundPages = bitset(foundPages,1);
%         case 1 % Word Type 1
%             IOD_nav_1 = bin2dec(bitsArrangedWordWise(7:16));
%             t0e_1 = bin2dec(bitsArrangedWordWise(17:30)) * 60;
%             M0_1 = twosComp2dec(bitsArrangedWordWise(31:62)) * 2^(-31) * galileoPi;            
%             e_1 = bin2dec(bitsArrangedWordWise(63:94)) * 2^(-33);
%             A_1 = bin2dec(bitsArrangedWordWise(95:126)) * 2^(-19);
%             foundPages = bitset(foundPages,2);
%         case 2 % Word Type 2
%             IOD_nav_2 = bin2dec(bitsArrangedWordWise(7:16));
%             OMEGA_0_2 = twosComp2dec(bitsArrangedWordWise(17:48)) * 2^(-31) * galileoPi;
%             i_0_2 = twosComp2dec(bitsArrangedWordWise(49:80)) * 2^(-31) * galileoPi;
%             omega_2 = twosComp2dec(bitsArrangedWordWise(81:112)) * 2^(-31) * galileoPi;
%             iDot_2 = twosComp2dec(bitsArrangedWordWise(113:126)) * 2^(-43) * galileoPi;
%             foundPages = bitset(foundPages,3);
%         case 3 % Word Type 3
%             IOD_nav_3 = bin2dec(bitsArrangedWordWise(7:16));
%             OMEGA_dot_3 = twosComp2dec(bitsArrangedWordWise(17:40)) * 2^(-43) * galileoPi;
%             delta_n_3 = twosComp2dec(bitsArrangedWordWise(41:56)) * 2^(-43) * galileoPi;
%             C_uc_3 = twosComp2dec(bitsArrangedWordWise(57:72)) * 2^(-29);
%             C_us_3 = twosComp2dec(bitsArrangedWordWise(73:88)) * 2^(-29);
%             C_rc_3 = twosComp2dec(bitsArrangedWordWise(89:104))* 2^(-5);
%             C_rs_3 = twosComp2dec(bitsArrangedWordWise(105:120))* 2^(-5);
%             SISA_3 = bin2dec(bitsArrangedWordWise(121:128));
%             foundPages = bitset(foundPages,4);
%         case 4 % Word Type 4
%             IOD_nav_4 = bin2dec(bitsArrangedWordWise(7:16));
%             SV_ID_4 = bin2dec(bitsArrangedWordWise(17:22));
%             C_ic_4 = twosComp2dec(bitsArrangedWordWise(23:38))*2^(-29);
%             C_is_4 = twosComp2dec(bitsArrangedWordWise(39:54))*2^(-29);
%             t0c_4 = bin2dec(bitsArrangedWordWise(55:68)) * 60;
%             af0_4 = twosComp2dec(bitsArrangedWordWise(69:99)) * 2^(-34);
%             af1_4 = twosComp2dec(bitsArrangedWordWise(100:120)) * 2^(-46);
%             af2_4 = twosComp2dec(bitsArrangedWordWise(121:126)) * 2^(-59);
%             foundPages = bitset(foundPages,5);
%         case 5 % Word Type 5
%             % TBA Require revision from ICD
%             ai0_5 = bin2dec(bitsArrangedWordWise(7:17))* 2^(-2);
%             ai1_5 = twosComp2dec(bitsArrangedWordWise(18:28))* 2^(-8);
%             ai2_5 = twosComp2dec(bitsArrangedWordWise(29:42))* 2^(-15);
%             Region1_flag_5 = bin2dec(bitsArrangedWordWise(43));
%             Region2_flag_5 = bin2dec(bitsArrangedWordWise(44));
%             Region3_flag_5 = bin2dec(bitsArrangedWordWise(45));
%             Region4_flag_5 = bin2dec(bitsArrangedWordWise(46));
%             Region5_flag_5 = bin2dec(bitsArrangedWordWise(47));
%             BGD_E1E5a_5 = twosComp2dec(bitsArrangedWordWise(48:57)) * 2^(-32);
%             BGD_E1E5b_5 = twosComp2dec(bitsArrangedWordWise(58:67)) * 2^(-32);
%             E5b_HS_5 = bin2dec(bitsArrangedWordWise(68:69));
%             E1B_HS_5 = bin2dec(bitsArrangedWordWise(70:71));
%             E5b_DVS_5 = bin2dec(bitsArrangedWordWise(72));
%             E1B_DVS_5 = bin2dec(bitsArrangedWordWise(73));
%             WN_5 = bin2dec(bitsArrangedWordWise(74:85));
%             TOW_5 = bin2dec(bitsArrangedWordWise(86:105));
%             ind_TOW_5 = i;
%             foundPages = bitset(foundPages,6);
%         case 6 % Word Type 6: GST-UTC conversion parameters
%             % Require revision from ICD
%             A0_6 = bin2dec(bitsArrangedWordWise(7:38));
%             A1_6 = bin2dec(bitsArrangedWordWise(39:62));
%             Delta_tLS_6 = bin2dec(bitsArrangedWordWise(63:70));
%             t_ot_6 = bin2dec(bitsArrangedWordWise(71:78)); 
%             WN_ot_6 = bin2dec(bitsArrangedWordWise(79:86));
%             WN_LSF_6 = bin2dec(bitsArrangedWordWise(87:94));
%             DN_6 = bin2dec(bitsArrangedWordWise(95:97));
%             Delta_tLSF_6 = bin2dec(bitsArrangedWordWise(98:105));
%             TOW_6 = bin2dec(bitsArrangedWordWise(106:125));
%             foundPages = bitset(foundPages,7);            
%         case 7
%             
%         case 8
%             
%         case 9
%             
%         case 10
%             % GPS-Galileo time comversion parameters
%             A_0G = bin2dec(bitsArrangedWordWise(87:102)) * 2^(-35);            
%             A_1G = bin2dec(bitsArrangedWordWise(103:114)) * 2^(-51);            
%             t_0G = bin2dec(bitsArrangedWordWise(115:122)) * 3600;            
%             WN_0G = bin2dec(bitsArrangedWordWise(123:128));            
%             foundPages = bitset(foundPages,11);            
%         case 63 % Dummy data word: Type 63
%             
%         otherwise
%             fprintf('Wrong Word Number! Word type: %d. Check CRC! \n',wordType(i));
%     end     
% end