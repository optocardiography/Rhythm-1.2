function [alternanceMap] = alternanceMap(data, start, endp, Fs, cmap, movie_scrn, handles)
%% the function apdMap creates a visual representation of the alternance distribution 
%
% INPUTS
% data  =   cmos data
% start =   start time
% endp  =   end time
% Fs    =   sampling frequency
% cmap  =   colormap
%
% OUTPUT
% A figure that has a color repersentation of alternance appearence.
%
% METHOD
% We calculate difference between the first and the second AP durations (APD).
% APD is being calculated as difference between adjucent moments of time
% when AP is lower than a given level (e.g. 0.45 for APD55). This deifference
% must be greater than some threshold (to avoid fake AP caused by noise).
% If two regions have opposite sign of the difference then they undergo
% discordant alternance (otherwise - concordant).
%
% AUTHOR: Pikunov Andrey (pikunov@phystech.edu)
%
% Email optocardiography@gmail.com for any questions or concerns.
% Refer to efimovlab.org for more information.


%% Create initial variables
start = 1 + round(start * Fs);
endp = round(endp * Fs);
ap_data = data(:, :, start : endp);    % window signal 
ap_data = normalize_data(ap_data);     % re-normalize windowed data

alternanceMap = nan(size(ap_data, 1), size(ap_data, 2));

AP_level = 0.45; % so we measure APD55
APD_threshold = 5;

%% Map calculation
for i = 1 : size(ap_data, 1)
    for j = 1 : size(ap_data, 2)
        
        index = find(ap_data(i, j, :) < AP_level);
        
        if size(index, 1) > 2
            spaces = index(2: end) - index(1: end - 1);
            peak_index = find(spaces > APD_threshold, 2);
            
            if size(peak_index, 1) == 2  
                first_peak_value = spaces(peak_index(1));
                second_peak_value = spaces(peak_index(2));
                   
                alternance_value = first_peak_value - second_peak_value;
                alternanceMap(i, j) = alternance_value;
            end
        end
    end
end

% account for different sampling frequencies
unitFix = 1000.0 / Fs;
alternanceMap = alternanceMap * unitFix;

handles.activeCamData.saveData = alternanceMap;

%% Plot
cla(movie_scrn);
set(movie_scrn,'YDir','reverse');
set(movie_scrn,'YTick',[],'XTick',[]);

colormap(handles.activeScreen, cmap);
imagesc(movie_scrn, alternanceMap);
axis(movie_scrn,'off');

alternance_max = prctile(abs(alternanceMap(:)), 99);
alternance_min = -alternance_max;

caxis(movie_scrn,[alternance_min alternance_max]);
end