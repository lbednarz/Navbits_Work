function [pstart,check] = findsync(bits)

sync = [0 1 0 1 1 0 0 0 0 0];
pstart = xcorr(bits, sync);

% determine a threshold cross-correlation that suggests a sync pattern
th = max(pstart);
flag = find(abs(pstart) >= th);

check = diff(flag);
pstart = pstart(check == 250);

if isempty(pstart)
    disp('Could not find valid sync pattern in channel!');
end


