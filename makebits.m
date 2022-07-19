function [bits, bits_alt] = makebits(correlationData, tchan)

navbit = zeros(tchan,1000);
navbit_skip = [];
navbitrel = NaN.*ones(tchan,length(correlationData(1).promptCode));

for i = 1:1:tchan
 
    I_P = correlationData(i).promptCode;
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
    Ip(i,:) = I_P;  
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

bmat = sign(Ip);
% Re-encode to binary 
bmatalt = bmat*-1;
bmat(bmat == -1) = 0; % case 1
bmatalt(bmatalt == -1) = 0; % case 2

bits = bmat;
bits_alt = bmatalt;


