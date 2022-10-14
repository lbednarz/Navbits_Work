function [navSolutions] = PVT(activeChnList, TOW, trackResults, settings, PageStart)

% process from beginning of solvable period. This means understanding that 
% each value of Ip is 4 ms long. Then you will process this remaining data
% in batches that are 1 nav-solve period long.

%% Initialization =========================================================

% Set the satellite elevations array to INF to include all satellites for
% the first calculation of receiver position. There is no reference point
% to find the elevation angle as there is no receiver position estimate at
% this point.
satElev  = inf(1, settings.numberOfChannels);

% Save the active channel list. The list contains satellites that are
% tracked and have the required ephemeris data. In the next step the list
% will depend on each satellite's elevation angle, which will change over
% time.  
readyChnList = activeChnList;

transmitTime = TOW;

%##########################################################################
%#   Do the satellite and receiver position calculations                  #
%##########################################################################

%% Initialization of current measurement ==================================
for currMeasNr = 1:fix((settings.msToProcess - 4 * max(PageStart)) / ...
                                                     settings.navSolPeriod)

    % Exclude satellites, that are belove elevation mask 
    activeChnList = intersect(find(satElev >= settings.elevationMask), ...
                              readyChnList);

    % Save list of satellites used for position calculation
    navSolutions.channel.PRN(activeChnList, currMeasNr) = ...
                                        [trackResults(activeChnList).PRN]; 

    % These two lines help the skyPlot function. The satellites excluded
    % do to elevation mask will not "jump" to possition (0,0) in the sky
    % plot.
    navSolutions.channel.el(:, currMeasNr) = ...
                                         NaN(settings.numberOfChannels, 1);
    navSolutions.channel.az(:, currMeasNr) = ...
                                         NaN(settings.numberOfChannels, 1);

%% Find pseudoranges ======================================================
    navSolutions.channel.rawP(:, currMeasNr) = calculatePseudoranges(...
            trackResults, ...
            PageStart + settings.navSolPeriod / 4 * (currMeasNr-1), ...
            activeChnList, settings);


end %for currMeasNr...