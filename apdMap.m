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


%% Create initial variablesns
start=round(start*Fs);
endp=round(endp*Fs);
apd_data = data(:,:,start:endp);        % window signal 
apd_data = normalize_data(apd_data); %re-normalize windowed data

%%Determining activation time point
% Find First Derivative and its index of maximum
apd_data2 = diff(apd_data,1,3); % first derivative
[~,max_i] = max(apd_data2,[],3); % find location of max derivative


%%Find location of repolarization
%%Find maximum of the signal and its index
[~,maxValI] = max(apd_data,[],3);

%locs is a temporary holding place
locs = nan(size(apd_data,1),size(apd_data,2));

%Define the baseline value you want to go down to
requiredVal = 1.0 - percent;

%%for each pixel
for i = 1:size(apd_data,1)
    for j = 1:size(apd_data,2)
        %%starting from the peak of the signal, loop until we reach baseline
        for k = maxValI(i,j):size(apd_data,3)
            if apd_data(i,j,k) <= requiredVal
                locs(i,j) = k; %Save the index when the baseline is reached
                                %this is the repolarizatin time point
                break;
            end
        end
    end
end

%%account for different sampling frequencies
unitFix = 1000.0 / Fs;

% Calculate Action Potential Duration
apd = minus(locs,max_i); 
apdMap = apd * unitFix;
apdMap(apdMap <= 0) = nan;
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
imagesc(movie_scrn, apdMap);
%set(gca,'XTick',[],'YTick',[],'Xlim',[0 size(data,1)],'YLim',[0 size(data,2)])
axis(movie_scrn,'off')
colormap(cmap);
% colorbar(movie_scrn);
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