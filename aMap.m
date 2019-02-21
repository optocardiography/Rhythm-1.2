function [actMap1] = aMap(data,stat,endp,Fs,cmap, movie_scrn, handles)
%% aMap is the central function for creating conduction velocity maps
% [actMap1] = aMap(data,stat,endp,Fs,bg) calculates the activation map
% for a single action potential upstroke.

% INPUTS
% data = cmos data (voltage, calcium, etc.) from the micam ultima system.
% 
% stat = start of analysis (in msec)
%
% endp = end of analysis (in msec)
%
% Fs = sampling frequency
%
% bg = black and white background image from the CMOS camera.  This is a
% 100X100 pixel image from the micam ultima system. bg is stored in the
% handles structure handles.bg.
%
% cmap = a colormap input that facilites the potential inversion of the
% colormap. cmap is stored in the handles structure as handles.cmap.
%
%
% OUTPUT
% actMap1 = activation map
%
% METHOD
% An activation map is calculated by finding the time of the maximum derivative 
% of each pixel in the specified time-windowed data.
%
% RELEASE VERSION 1.0.1
%
% AUTHOR: Qing Lou, Jacob Laughner (jacoblaughner@gmail.com)
%
%
% MODIFICATION LOG:
%
% Jan. 26, 2015 - The input cmap was added to input the colormap and code
% was added at the end of the function to set the colormap to the user
% determined values. In this case the most immediate purpose is to
% facilitate inversion of the default colormap.
%
% Email optocardiography@gmail.com for any questions or concerns.
% Refer to efimovlab.org for more information.



%% Code

if stat == 0
    stat = 1; % Subscript indices must either be real positive integers or logicals
end
% Create initial variables
stat=round(stat*Fs);
endp=round(endp*Fs);
% Code not used in current version %
% % actMap = zeros(size(data,1),size(data,2));
% % mask2 = zeros(size(data,1),size(data,2));

% identify channels that have been zero-ed out due to noise
if size(data,3) == 1
    temp = data(:,stat:endp);       % Windowed signal
    temp = normalize_data(temp);    % Re-normalize data in case of drift
    mask = max(temp,[],2) > 0;      % Generate mask
else
    temp = data(:,:,stat:endp);     % Windowed signal
    temp = normalize_data(temp);    % Re-normalize data in case of drift
    mask = max(temp,[],3) > 0;      % Generate mask
end

% Code not used in current version %
% % % % Remove non-connected artifacts
% % % CC = bwconncomp(mask,4);
% % % numPixels = cellfun(@numel,CC.PixelIdxList);
% % % [~,idx] = max(numPixels);
% % % mask_id = CC.PixelIdxList{idx};
% % % mask2(mask_id) = 1;

% Find First Derivative and time of maxium
if size(data,3) == 1
    temp2 = diff(temp,1,2);
    [~,max_i] = max(temp2,[],2);
else
    temp2 = diff(temp,1,3); % first derivative
    [~,max_i] = max(temp2,[],3); % find location of max derivative
end

% Activation Map Matrix
actMap1 = max_i.*mask;
actMap1(actMap1 == 0) = nan;
offset1 = min(min(actMap1));
actMap1 = actMap1 - offset1*ones(size(actMap1,1),size(actMap1,2));
actMap1 = actMap1/Fs*1000; %% time in ms

% Plot Map
if size(data,3) ~= 1
    handles.activeCamData.saveData = actMap1;
    cla(movie_scrn); 
    contourf(movie_scrn, actMap1,(endp-stat),'LineColor','k');
    set(movie_scrn,'YDir','reverse');
    set(movie_scrn,'YTick',[],'XTick',[]);
    colormap(jet);
%     colorbar(movie_scrn);
end

          handles.activeCamData.meanresults = sprintf('Mean:');
          handles.activeCamData.medianresults = sprintf('Median:');
          handles.activeCamData.SDresults = sprintf('S.D.:');
          handles.activeCamData.num_membersresults = sprintf('#Members:');
          handles.activeCamData.angleresults =sprintf('Angle:');
end




