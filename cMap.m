function [cMap] = cMap(data,stat,endp,Fs,bg,rect, f, movie_scrn, handles)
%% cMap is the central function for creating conduction velocity maps
% [cMap] = cMap(data,stat,endp,Fs,bg,rect) calculates the conduction
% velocity map for a single action potential upstroke by fitting a
% polynomial and calculating the surface derivative to a pre-defined area
% of cmosData.  This area is specified by the vector rect.

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
% rect = area of interest specified by getrect in Rhythm.m GUI

% OUTPUT
% cMap = conduction velocity map

% METHOD
% The method used for calculating conduction velocity is fully described by
% Bayly et al in "Estimation of Conduction Velocity Vecotr Fields from
% Epicardial Mapping Data".  Briefly, this function calculates the
% conduction velocity for a region of interest (ROI) for a single optical
% action potential.  First, an activation map is calculated for the ROI
% by identifying the time of maximum derivative of each ROI pixel.  Next, a
% third-order polynomial surface is fit to the activation map and the
% surface derivative of the fitted surface is calculated.  Finally, the x
% and y components of conduction velocity are calculated per pixel
% (pixel/msec).


% REFERENCES
% Bayly PV, KenKnight BH, Rogers JM, Hillsley RE, Ideker RE, Smith WM.
% "Estimation of COnduction Velocity Vecotr Fields from Epicardial Mapping
% Data". IEEE Trans. Bio. Eng. Vol 45. No 5. 1998.

% ADDITIONAL NOTES
% The conduction velocity vectors are highly dependent on the goodness of
% fit of the polynomial surface.  In the Balyly paper, a 2nd order polynomial 
% surface is used.  We found this polynomial to be insufficient and thus increased
% the order to 3.  MATLAB's intrinsic fitting functions might do a better
% job fitting the data and should be more closely examined if velocity
% vectors look incorrect.

% RELEASE VERSION 1.0.1

% AUTHOR: Jacob Laughner (jacoblaughner@gmail.com)

% Email optocardiography@gmail.com for any questions or concerns.
% Refer to efimovlab.org for more information.

%% Code
%% Find Activation Times for Polynomial Surface
stat=round(stat*Fs)+1;
endp=round(endp*Fs)+1;
actMap = zeros(size(data,1),size(data,2));
mask2 = zeros(size(data,1),size(data,2));
temp = data(:,:,stat:endp); % truncate data

% Re-normalize data in case of drift
temp = normalize_data(temp);

% identify channels that have been zero-ed out due to noise
mask = max(temp,[],3) > 0;

% Remove non-connected artifacts
CC = bwconncomp(mask,4);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
mask_id = CC.PixelIdxList{idx};
mask2(mask_id) = 1;

% Find First Derivative and time of maxium
temp2 = diff(temp,1,3); % first derivative
[~,max_i] = max(temp2,[],3); % find location of max derivative

% Create Activation Map
actMap1 = max_i.*mask;
actMap1(actMap1 == 0) = nan;
offset1 = min(min(actMap1));
actMap1 = actMap1 - offset1*ones(size(data,1),size(data,2));
actMap1 = actMap1/Fs*1000; %% time in ms

%% Find Conduction Velocity Map - Bayly Method
% Isolate ROI Specified by RECT
% rect = round(rect);
% temp = actMap1(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
% Fit Activation Map with 3rd-order Polynomial
% cind = isfinite(temp);
% [x y]= meshgrid(rect(1):rect(1)+rect(3),rect(2):rect(2)+rect(4));
% x = reshape(x,[],1);
% y = reshape(y,[],1);
% z = reshape(temp,[],1);
% X = x(cind);
% Y = y(cind);
% Z = z(cind);
% A = [X.^3 Y.^3 X.*Y.^2 Y.*X.^2 X.^2 Y.^2 X.*Y X Y ones(size(X,1),1)];
% a = A\Z;
% Z_fit = A*a;
% Z_fit = reshape(Z_fit,size(cind));
% Find Gradient of Polynomial Surface
% [Tx Ty] = gradient(Z_fit);
% Calculate Conduction Velocity
% Vx = -Tx./(Tx.^2+Ty.^2);
% Vy = -Ty./(Tx.^2+Ty.^2);
% V = sqrt(Vx.^2 + Vy.^2);
% meanV = mean2(V)
% stdV = std2(V)
% meanAng = mean2(atand(Vy./Vx))
% stdAng = std2(atand(Vy./Vx))
% Plot Map
% cc = figure('Name','Activation Map with Velocity Vectors');
% Create Mask
% actMap_Mask = zeros(size(bg));
% actMap_Mask(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3)) = 1;
% Build the Image
% G = real2rgb(bg, 'gray');
% J = real2rgb(actMap1, 'jet',[min(min(temp)) max(max(temp))]);
% A = real2rgb(actMap_Mask, 'gray');
% I = J .* A + G .* (1-A);
% image(I)
% hold on
% Overlay Conduction Velocity Vectors
% quiver(X,Y,reshape(Vx,[],1),reshape(Vy,[],1),3,'w')
% title('Activation Map with Velocity Vectors')
% axis image
% axis off
% 
% cv = figure('Name','Conduction Velocity Map');
% Create Mask
% actMap_Mask = zeros(size(bg));
% actMap_Mask(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3)) = 1;
% cvMap_Mask = zeros(size(bg));
% cvMap_Mask(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3)) = V;
% Build the Image
% G = real2rgb(bg, 'gray');
% J = real2rgb(cvMap_Mask, 'jet',[min(min(V)) max(max(V))]);
% A = real2rgb(actMap_Mask, 'gray');
% I = J .* A + G .* (1-A);
% subplot(121)
% image(I)
% axis off
% axis image
% subplot(122)
% imagesc(V);colormap jet;colorbar
% axis image
% axis off
% title('Conduction Velocity Magnitude')

%% Find Conduction Velocity Map - Efimov Method
% Fit Activation Map with New Surface based on Kernel Smoothing
cind = isfinite(actMap1);
[x,y]= meshgrid(1:size(data,2),1:size(data,1));
x = reshape(x,[],1);
y = reshape(y,[],1);
z = reshape(actMap1,[],1);
X = x(cind);
Y = y(cind);
k_size = 3;
h = fspecial('average',[k_size k_size]);
Z_fit = filter2(h,actMap1);
% Remove Edge Effect Introduced from Kernel
seD = strel('diamond',k_size-2);
mask = imerode(cind,seD);
mask(1,:) = 0;
mask(end,:) = 0;
mask(:,1) = 0;
mask(:,end) = 0;
Z = Z_fit.*mask;
Z(Z==0) = nan;
% Find Gradient of Polynomial Surface
[Tx,Ty] = gradient(Z);
% Calculate Conduction Velocity
Vx = Tx./(Tx.^2+Ty.^2);
Vy = -Ty./(Tx.^2+Ty.^2);
V = sqrt(Vx.^2 + Vy.^2);

rect = round(abs(rect));
temp_Vx = Vx(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
temp_Vy = Vy(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
temp_V = V(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));


% Display the regional statistics
disp('Regional conduction velocity statistics:')
medV = median(median(temp_V(isfinite(temp_V))));
disp(['The median value is ' num2str(medV) ' pixels/ms.'])
stdV = std2(temp_V(isfinite(temp_V)));
disp(['The standard deviation is ' num2str(stdV) '.'])
medAng = median(median(atan2(temp_Vy(isfinite(temp_Vy)),temp_Vx(isfinite(temp_Vy))).*180/pi));
disp(['The median angle is ' num2str(medAng) ' degrees.'])
stdAng = std2(atan2(temp_Vy(isfinite(temp_Vy)),temp_Vx(isfinite(temp_Vy))).*180/pi);
disp(['The standard deviation of the angle is ' num2str(stdAng) '.'])
num_vectors = numel(temp_V(isfinite(temp_V)));
disp(['The number of vectors is ' num2str(num_vectors) '.'])

          handles.activeCamData.meanresults = sprintf('Mean:');
          handles.activeCamData.medianresults = sprintf('Median:');
          handles.activeCamData.SDresults = sprintf('S.D.:');
          handles.activeCamData.num_membersresults = sprintf('#Members:');
          handles.activeCamData.angleresults =sprintf('Angle:');
handles.activeCamData.saveData = actMap1;
% Plot Results
cla(movie_scrn); 
%compute isolines
contourf(movie_scrn, actMap1,(endp-stat)/2,'LineColor','k');
% colorbar(movie_scrn)
set(movie_scrn,'YTick',[],'XTick',[]);
set(movie_scrn,'YDir','reverse');

hold (movie_scrn,'on')

Y_plot = size(data,1)+1 - y(isfinite(Z));
X_plot = x(isfinite(Z));
Vx_plot = Vx(isfinite(Z));
Vx_plot(abs(Vx_plot) > 5) = 5.*sign(Vx_plot(abs(Vx_plot) > 5));
Vy_plot = Vy(isfinite(Z));
Vy_plot(abs(Vy_plot) > 5) = 5.*sign(Vy_plot(abs(Vy_plot) > 5));
V = sqrt(Vx_plot.^2 + Vy_plot.^2);
imageHeight = 100;

%Create Vector Array to pass to following functions
VecArray = [X_plot Y_plot Vx_plot Vy_plot V];
handles.activeCamData.VecArray = VecArray;
%data for saving
handles.activeCamData.saveX_plot = X_plot;
handles.activeCamData.saveY_plot = Y_plot;
handles.activeCamData.saveVx_plot = Vx_plot;
handles.activeCamData.saveVy_plot = Vy_plot;


% plot vector field
quiver(movie_scrn, X_plot, imageHeight - Y_plot,Vx_plot, -1.0 * Vy_plot,3,'r')

hold (movie_scrn,'off');

% rect_plot = [rect(1) (size(data,1) + 1 - rect(2)-rect(4)) rect(3) rect(4)];
% rectangle(movie_scrn, 'Position',rect_plot,'EdgeColor','c')
axis (movie_scrn,'off')
end

