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
dataCroppedInTime = data(:,:,stat:endp); % truncate data

% Re-normalize data in case of drift
dataCroppedInTime = normalize_data(dataCroppedInTime);

% identify channels that have been zero-ed out due to noise
mask = max(dataCroppedInTime,[],3) > 0;


% Find First Derivative and time of maxium
derivatives = diff(dataCroppedInTime,1,3); % first derivative
[~,max_i] = max(derivatives,[],3); % find location of max derivative

% Create Activation Map
actMap1 = max_i.*mask;
actMap1(actMap1 == 0) = nan;
offset1 = min(min(actMap1));
actMap1 = actMap1 - offset1*ones(size(data,1),size(data,2));
actMap1 = actMap1/Fs*1000; %% time in ms

%% Find Conduction Velocity Map - Bayly Method
% Isolate ROI Specified by RECT
rect = round(rect);
croppedAmap = actMap1(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
%exclude everything, but activation front

use_window=1; % use windowed least-squares fitting

% if ~use_window
    includeMask=zeros(rect(4)+1,rect(3)+1);
    includeMask(2:end-1,2:end-1)=abs(croppedAmap(1:end-2,2:end-1)-croppedAmap(3:end,2:end-1))+abs(croppedAmap(2:end-1,1:end-2)-croppedAmap(2:end-1,3:end));
    includeMask(2:end-1,2:end-1)=((croppedAmap(2:end-1,2:end-1)<croppedAmap(3:end,2:end-1))|(croppedAmap(2:end-1,2:end-1))<croppedAmap(1:end-2,2:end-1)|(croppedAmap(2:end-1,2:end-1)<croppedAmap(2:end-1,3:end))|(croppedAmap(2:end-1,2:end-1))<croppedAmap(2:end-1,1:end-2));
    croppedAmap(includeMask==0)=NaN;
% end
if use_window
    [xx yy]= meshgrid(rect(1):rect(1)+rect(3),rect(2):rect(2)+rect(4));
    xx = reshape(xx,[],1);
    yy = reshape(yy,[],1);
    t = reshape(croppedAmap,[],1);
    
    xyt = [xx yy t];
    
    M=size(xyt,1);
    XYT=zeros(M,17);
    
    space_window_width =  2./ handles.activeCamData.xres; % mm space frame 
    time_window_width = 5 * handles.Fs / 1000; % time frame 
    how_many = 12; % why???
    for i=1:M
       % ������� ������� ���������� i-��� ����� �� ���� ���������
       dx=abs(xyt(:,1)-xyt(i,1));
       dy=abs(xyt(:,2)-xyt(i,2));
       dt=abs(xyt(:,3)-xyt(i,3));
       %find dx dy dt 
       %------------------------------------------------------------------------

       near=find((sqrt(dx.^2+dy.^2)<=space_window_width)&(isfinite(xyt(:,3))));
       len=length(near);
       %specify the points by using the points that are close enough
       %------------------------------------------------------------------------

       if len>how_many
            xyn=xyt(near,1:2)-ones(len,1)*xyt(i,1:2); % centered around the i-th point
            x=xyn(:,1)*handles.activeCamData.xres/1000;%unit of X,Y are mM
            y=xyn(:,2)*handles.activeCamData.yres/1000;
            t=xyt(near,3);
            %find dx dy dt of the specific points that are acceptable
            %------------------------------------------------------------------------
            fit     = [ones(len,1) x y x.^2 y.^2 x.*y x.^3 y.^3 x.*y.^2 y.*x.^2]; % on the windowed area
            coefs   = fit\t;
            resi    = sqrt(sum((t-fit*coefs).^2)/sum(t.^2));
            resilin = sqrt(sum((t-fit(:,1:3)*coefs(1:3)).^2)/sum(t.^2));
            XYT(i,:)= [xyt(i,:),coefs',resi,len,cond(fit),resilin];
        end
    end
            
    cropped = dataCroppedInTime(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),1);
    croppedResized = reshape(cropped,[],1);
    
    was_fitted=find( (XYT(:,1)~=0) & (XYT(:,2)~=0) & ( croppedResized(:) > 0) ); % if XYT was not filled or point not inside of segmented region
    XYT=XYT(was_fitted,:);
    
    % coef_x / (coef_x^2 + coef_y^2) * TODO multiplier????
    Vx=(XYT(:,5)./(XYT(:,5).^2 + XYT(:,6).^2))*1000;%handles.activeCamData.xres; 
    % coef_y / (coef_y^2 + coef_y^2) * TODO multiplier????
    Vy=-(XYT(:,6)./(XYT(:,5).^2 + XYT(:,6).^2))*1000;%handles.activeCamData.yres; 
    
    V=sqrt(Vx.^2+Vy.^2);
end         



% Fit Activation Map with 3rd-order Polynomial
if ~use_window
    cind = isfinite(croppedAmap);
    [x y]= meshgrid(rect(1):rect(1)+rect(3),rect(2):rect(2)+rect(4));
    x = reshape(x,[],1);
    y = reshape(y,[],1);
    z = reshape(croppedAmap,[],1);
    a = [x.^3 y.^3 x.*y.^2 y.*x.^2 x.^2 y.^2 x.*y x y ones(size(x,1),1)]; % for the whole rectangle
    X = x(cind);
    Y = y(cind);
    Z = z(cind);
    A = [X.^3 Y.^3 X.*Y.^2 Y.*X.^2 X.^2 Y.^2 X.*Y X Y ones(size(X,1),1)]; % for the active front
    solution = A\Z; % solution is the set of coefficients
    Z_fit = a*solution; % Z_fit is a polynome surface on the whole rectangle
    Z_fit = reshape(Z_fit,size(cind)); % reshape Z_fit to be rectangle shaped
end
%Z_fit=nan(size(cind));
 %Z_fit(cind)=A*a;
% zres=reshape(Z_fit,[],1)-Z;
% SSres=sum(zres.^2);
% SStot=(length(Z)-1)*var(Z);
% rsq=1-SSres/SStot;
% disp(['rsq of fit is ' num2str(rsq)]);
% Find Gradient of Polynomial Surface
if ~use_window
    [Tx Ty] = gradient(Z_fit);
    Tx=Tx/handles.activeCamData.xres;
    Ty=Ty/handles.activeCamData.yres;
end
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
%cind = isfinite(actMap1);
%[x,y]= meshgrid(1:size(data,2),1:size(data,1));
%x = reshape(x,[],1);
%y = reshape(y,[],1);
%z = reshape(actMap1,[],1);
%X = x(cind);
%Y = y(cind);
%k_size = 3;
%h = fspecial('average',[k_size k_size]);
%Z_fit = filter2(h,actMap1);
% Remove Edge Effect Introduced from Kernel
%seD = strel('diamond',k_size-2);
%mask = imerode(cind,seD);
%mask(1,:) = 0;
%mask(end,:) = 0;
%mask(:,1) = 0;
%mask(:,end) = 0;
%Z = Z_fit.*mask;
%Z(Z==0) = nan;
% Find Gradient of Polynomial Surface
%[Tx,Ty] = gradient(Z);

% Calculate Conduction Velocity
if ~use_window
    Vx = Tx./(Tx.^2+Ty.^2);
    Vy = -Ty./(Tx.^2+Ty.^2);
    V = sqrt(Vx.^2 + Vy.^2);
else
    bad=(V>1); %includeMask CV above 2 m/s
    Vx(bad)=NaN;
    Vy(bad)=NaN;
    V(bad)=NaN;
end
%rect = round(abs(rect));
%temp_Vx = Vx(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
%temp_Vy = Vy(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
%temp_V = V(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));

% Display the regional statistics
disp('Regional conduction velocity statistics:')
meanV=nanmean(V(isfinite(V)));
disp(['The mean value is ' num2str(meanV) ' m/s.'])
medV = median(V(isfinite(V)));
disp(['The median value is ' num2str(medV) ' m/s.'])
stdV = std2(V(isfinite(V)));
disp(['The standard deviation is ' num2str(stdV) '.'])
meanAng = mean(atan2(Vy(isfinite(Vy)),Vx(isfinite(Vy))).*180/pi);
disp(['The mean angle is ' num2str(meanAng) ' degrees.'])
medAng = median(atan2(Vy(isfinite(Vy)),Vx(isfinite(Vy))).*180/pi);
disp(['The median angle is ' num2str(medAng) ' degrees.'])
stdAng = std2(atan2(Vy(isfinite(Vy)),Vx(isfinite(Vy))).*180/pi);
disp(['The standard deviation of the angle is ' num2str(stdAng) '.'])
num_vectors = numel(V(isfinite(V)));
disp(['The number of vectors is ' num2str(num_vectors) '.'])

        % statistics window
       handles.activeCamData.meanresults = sprintf('Mean: %0.3f',meanV);
       handles.activeCamData.medianresults  = sprintf('Median: %0.3f',medV);
       handles.activeCamData.SDresults = sprintf('S.D.: %0.3f',stdV);
       handles.activeCamData.num_membersresults = sprintf('#Members: %d',num_vectors);
       handles.activeCamData.angleresults = sprintf('Angle: %d',meanAng);
       
       set(handles.meanresults,'String',handles.activeCamData.meanresults);
       set(handles.medianresults,'String',handles.activeCamData.medianresults);
       set(handles.SDresults,'String',handles.activeCamData.SDresults);
       set(handles.num_members_results,'String',handles.activeCamData.num_membersresults);
       set(handles.angleresults,'String',handles.activeCamData.angleresults);
       
handles.activeCamData.saveData = actMap1;
% Plot Results
cla(movie_scrn); 
%compute isolines

[C,h] = contourf(movie_scrn, actMap1,(endp-stat)/2, 'LineColor','k');

% 
% allH = allchild(h);
%  valueToHide = 1;
%  patchValues = cell2mat(get(allH,'UserData'));
%  patchesToHide = patchValues == valueToHide;
%  set(allH(patchesToHide),'FaceColor','r','FaceAlpha',0);


%caxis(movie_scrn,[stat endp]);
contourcmap('copper','SourceObject', movie_scrn, 'ColorAlignment', 'center');
%colorbar(movie_scrn);
set(movie_scrn,'YTick',[],'XTick',[]);


hold (movie_scrn,'on')

%Y_plot = size(data,1)+1 - y(isfinite(Z_fit));
if ~use_window
    Y_plot = y(isfinite(Z_fit));
    X_plot = x(isfinite(Z_fit));
    Vx_plot = Vx(isfinite(Z_fit));
else
    Y_plot = yy(was_fitted);
    X_plot = xx(was_fitted);
    Vx_plot = Vx;
end
Vx_plot(abs(Vx_plot) > 5) = 5.*sign(Vx_plot(abs(Vx_plot) > 5));
if ~use_window
    Vy_plot = Vy(isfinite(Z_fit));
else
    Vy_plot = Vy;%(was_fitted,1);
end
Vy_plot(abs(Vy_plot) > 5) = 5.*sign(Vy_plot(abs(Vy_plot) > 5));
V = sqrt(Vx_plot.^2 + Vy_plot.^2);

%Create Vector Array to pass to following functions
VecArray = [X_plot Y_plot Vx_plot Vy_plot V];
handles.activeCamData.VecArray = VecArray;
%data for saving
handles.activeCamData.saveX_plot = X_plot;
handles.activeCamData.saveY_plot = Y_plot;
handles.activeCamData.saveVx_plot = Vx_plot;
handles.activeCamData.saveVy_plot = Vy_plot;

 % Check for bad vectors
%        badNaN=(isnan(Vx_plot)|isnan(Vy_plot));
%        bad1=(XYT(:,10)>0.8);
%        bad3=(V>10);
%        bad=find(bad3|badNaN);
%        Vx_plot(bad)=[];Vy_plot(bad)=[];X_plot(bad)=[];Y_plot(bad)=[];;V(bad)=[];
        
% plot vector field
quiver_step = 2;
q = quiver(movie_scrn, X_plot(1:quiver_step:end),...
           Y_plot(1:quiver_step:end),Vx_plot(1:quiver_step:end),...
           -1.0 * Vy_plot(1:quiver_step:end),'w');
q.LineWidth = 2;
q.AutoScaleFactor = 2;
set(movie_scrn,'YDir','reverse');

hold (movie_scrn,'off');

% rect_plot = [rect(1) (size(data,1) + 1 - rect(2)-rect(4)) rect(3) rect(4)];
% rectangle(movie_scrn, 'Position',rect_plot,'EdgeColor','c')
%axis (movie_scrn,'off')
end

