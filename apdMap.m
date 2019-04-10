function [apdMap] = apdMap(data,start,endp,Fs,percent,cmap, movie_scrn, handles)
%% the function apdMap creates a visual representation of the action potential duration 
%
% INPUTS
% data=cmos data
% start=start time
% endp=end time
% Fs=sampling frequency
% percent=percent repolarization
%
% OUTPUT
% A figure that has a color repersentation for action potential duration
% times
%
% METHOD
% We use the the maximum derivative of the upstroke as the initial point of
% activation. The time of repolarization is determine by finding the time 
% at which the maximum of the signal falls to the desired percentage. APD is
% the difference between the two time points. 
%
%
% AUTHOR: Matt Sulkin (sulkin.matt@gmail.com)
%
% MAINTED BY: Christopher Gloschat - (cgloschat@gmail.com) - [Jan. 2015 - Present]
%
% MODIFICATION LOG:
% Jan. 26, 2015 - The input cmap was added to input the colormap and code
% was added at the end of the function to set the colormap to the user
% determined values. In this case the most immediate purpose is to
% facilitate inversion of the default colormap.
%
% Email optocardiography@gmail.com for any questions or concerns.
% Refer to efimovlab.org for more information.


%% Create initial variables
start = 1 + round(start * Fs);
endp = round(endp * Fs);
apd_data = data(:, :, start : endp);        % window signal 
apd_data = normalize_data(apd_data); %re-normalize windowed data

apdMap = nan(size(apd_data, 1), size(apd_data, 2));

%% Andrey Pikunov and Roman Sunyaev (21.03.2019)
% Find the largest interval when AP height more than requiredValue
% Ex.: requiredVal = 0.2 when we calculate APD80
requiredVal = 1.0 - percent;

for i = 1 : size(apd_data, 1)
    for j = 1 : size(apd_data, 2)
        
        index = find(apd_data(i, j, :) <= requiredVal);
        
        if size(index, 1) > 2
            apdMap(i, j) = max(index(2: end) - index(1: end - 1));
        end

    end
end

%%account for different sampling frequencies
unitFix = 1000.0 / Fs;
% Calculate Action Potential Duration
apdMap = apdMap * unitFix;

%%Simple filtration: tails cut-off (by Andrey Pikunov)
% disabled by default
if (false)
    
    apdMap(apdMap < 20) = nan; % remove APD < 20 ms - obvious noise
    apdMap_dropnan = rmmissing(reshape(apdMap, [], 1));
    apdMap_unique = unique(apdMap_dropnan);

    %Calculate APD distrubution
    [APD_count, ~] = hist(apdMap_dropnan, size(apdMap_unique, 1));
    APD_count = APD_count / max(APD_count); % rescaling

    % we will remove APD with small appearance
    % 0.025 is mild, you may use 0.05 to remove more noise
    thrashold_value = 0.025;
    APD_trash = find(APD_count < thrashold_value);

    % find the most left APD below trashold
    APD_trash_left = APD_trash(1);
    for i = 1 : size(APD_trash, 2)
       if (APD_trash(i+1) - APD_trash(i) > 1)
           APD_trash_left = APD_trash(i);
           break;
       end
    end

    % find the most right APD below trashold
    APD_trash_right = APD_trash(end);
    for i = size(APD_trash, 2) : -1 : 1
       if (APD_trash(i) - APD_trash(i-1) > 1)
           APD_trash_right = APD_trash(i);
           break;
       end
    end

    apdMap(apdMap < APD_trash_left) = nan;
    apdMap(apdMap > APD_trash_right) = nan;
    
end % Filtration is done.

handles.activeCamData.saveData = apdMap;

%Setting up values to use for color axis
APD_min = prctile(apdMap(isfinite(apdMap)),5);
APD_max = prctile(apdMap(isfinite(apdMap)),95);

% Plot APDMap
cla(movie_scrn);
set(movie_scrn,'YDir','reverse');
set(movie_scrn,'YTick',[],'XTick',[]);

%map_fig1 = subplot(1,1,1,'replace');
%imagesc(movie_scrn, apdMap,map_fig1);
colormap(handles.activeScreen, cmap);
imagesc(movie_scrn, apdMap);
%set(gca,'XTick',[],'YTick',[],'Xlim',[0 size(data,1)],'YLim',[0 size(data,2)])
axis(movie_scrn,'off')
colormap(cmap);
%cb = colorbar(movie_scrn);
%ylabel(cb, "APD (ms)");
caxis(movie_scrn,[APD_min APD_max])

% Plot Histogram of APDMap
figure('Name','Histogram of APD')
hist(reshape(apdMap,[],1),floor(APD_max-APD_min))
%xlim([APD_min APD_max])

          handles.activeCamData.meanresults = sprintf('Mean:');
          handles.activeCamData.medianresults = sprintf('Median:');
          handles.activeCamData.SDresults = sprintf('S.D.:');
          handles.activeCamData.num_membersresults = sprintf('#Members:');
          handles.activeCamData.angleresults =sprintf('Angle:');
end
