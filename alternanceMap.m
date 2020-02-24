function [alternanceMap] = alternanceMap(data,...
                                         start, endp,...
                                         minapd, maxapd,...
                                         percentAPD,...
                                         area_coords,...
                                         Fs, cmap, movie_scrn, handles)
%% the function apdMap creates a visual representation of the alternance distribution 
%
% INPUTS
% data          = cmos data
% start         = start time
% endp          = end time
% minapd        = minimal APD
% maxapd        = maximal APD
% percentAPD    = percent repolarization
% area_coords   = area coordinates
%                 [xmin, ymin, width, height]
% Fs            = sampling frequency
%
% OUTPUT
% A figure that has a color repersentation of alternance appearence.
%
% METHOD
% We calculate difference between the first and the second AP durations (APD).
% APD is being calculated as difference between adjucent moments of time
% when AP is lower than a given level (e.g. 0.45 for APD55).
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
ap_data = data(:, :, start : endp);
ap_data = normalize_data(ap_data);

alternanceMap = nan(size(ap_data, 1), size(ap_data, 2));

APD_min_rescaled = minapd * Fs / 1000;
APD_max_rescaled = maxapd * Fs / 1000;

AP_level = 1.0 - percentAPD / 100;

area_coords = int8(area_coords);
j_min = 1 + area_coords(1);
i_min = 1 + area_coords(2);
j_max = area_coords(1) + area_coords(3);
i_max = area_coords(2) + area_coords(4);

%% Map calculation
for i = i_min : i_max
    for j = j_min : j_max
        
        index = find(ap_data(i, j, :) < AP_level);
        
        if size(index, 1) > 2
            spaces = index(2: end) - index(1: end - 1);
            peak_index = find((spaces > APD_min_rescaled) & (spaces < APD_max_rescaled), 2);
            
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

colormap(handles.activeScreen, cmap);
imagesc(movie_scrn, alternanceMap, 'AlphaData', ~isnan(alternanceMap));
set(movie_scrn,'Color','k')
set(movie_scrn,'YDir','reverse');
set(movie_scrn,'YTick',[],'XTick',[]);

alternance_max = max(max(abs(alternanceMap(:))));
alternance_min = -alternance_max;

caxis(movie_scrn,[alternance_min alternance_max]);

%% Plot Histogram of APDMap
figure('Name','Histogram of Alternance')
hist(reshape(alternanceMap,[],1),floor(alternance_max-alternance_min))
xlim([alternance_min alternance_max])

%% Calculating statistics
alternance_mean=nanmean(alternanceMap(:));
disp(['The average alternance in the region is ' num2str(alternance_mean) ' (ms).'])
alternance_std=nanstd(alternanceMap(:));
disp(['The standard deviation of alternance in the region is ' num2str(alternance_std) ' (ms).'])
alternance_median=nanmedian(alternanceMap(:));
disp(['The median alternance in the region is ' num2str(alternance_median) ' (ms).'])

handles.activeCamData.meanresults           = sprintf('Mean: %0.3f (ms)',alternance_mean);
handles.activeCamData.medianresults         = sprintf('Median: %0.3f (ms)',alternance_median);
handles.activeCamData.SDresults             = sprintf('S.D.: %0.3f (ms)',alternance_std);
handles.activeCamData.num_membersresults    = sprintf('');
handles.activeCamData.angleresults          = sprintf('');

set(handles.meanresults,'String',handles.activeCamData.meanresults);
set(handles.medianresults,'String',handles.activeCamData.medianresults);
set(handles.SDresults,'String',handles.activeCamData.SDresults);
set(handles.num_members_results,'String',handles.activeCamData.num_membersresults);
set(handles.angleresults,'String',handles.activeCamData.angleresults);

end
