function GUI_RiseTime(riseTimeGroup,handles, f)
starttime_rtmap_text = uicontrol('Parent',riseTimeGroup, ...
                                       'Style','text','FontSize',10, ...
                                       'String','Start Time',...
                                       'Units','normalized',...
                                       'Position',[.01 .9 .4 .09]);
starttime_rtmap_edit = uicontrol('Parent',riseTimeGroup,...
                                       'Style','edit','FontSize',10, ... 
                                       'Units','normalized',...
                                       'Position',[0.42 0.9 .25 .09],...
                                       'Callback', @startTime_callback);
endtime_rtmap_text   = uicontrol('Parent',riseTimeGroup, ...
                                       'Style','text','FontSize',10,...
                                       'String','End Time',...
                                       'Units','normalized',...
                                       'Position',[.01 .8 .4 .09]);
endtime_rtmap_edit   = uicontrol('Parent',riseTimeGroup,...
                                       'Style','edit','FontSize',10,...
                                       'Units','normalized',...
                                       'Position',[.42 .8 .25 .09],...
                                       'Callback', @endTime_callback);
percent_start_rt_text= uicontrol('Parent',riseTimeGroup,'Style','text',...
                                'FontSize',10,'String','Start%',...
                                'Units','normalized',...
                                'Position',[.01 .7 .4 .09]);
percent_start_rt_edit= uicontrol('Parent',riseTimeGroup,'Style','edit',...
                                'FontSize',10,'String','0.8',...
                                'Units','normalized',...
                                'Position',[.42 .7 .25 .09],...
                                'callback',{@percent_rt_edit_callback}); 
percent_end_rt_text= uicontrol('Parent',riseTimeGroup,'Style','text',...
                                'FontSize',10,'String','End%',...
                                'Units','normalized',...
                                'Position',[.01 .6 .4 .09]);
percent_end_rt_edit= uicontrol('Parent',riseTimeGroup,'Style','edit',...
                                'FontSize',10,'String','0.9',...
                                'Units','normalized',...
                                'Position',[.42 .6 .25 .09],...
                                'callback',{@percent_rt_edit_callback});  
calculate_rt=uicontrol('Parent',riseTimeGroup,'Style','pushbutton',...
                                        'FontSize',10,'String','Calculate',...
                                        'Units','normalized',...
                                        'Position',[.01 .1 .7 .15],...
                                        'Callback',{@calculate_rt_callback});

export_icon = imread('icon.png');
export_icon = imresize(export_icon, [20, 20]);
export_button = uicontrol('Parent',riseTimeGroup,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[0.75, 0.1, 0.15, 0.15]...
                        ,'Callback',{@export_button_callback});                                  
set(export_button,'CData',export_icon)                                  
set(starttime_rtmap_edit, 'String', '0.75');
set(endtime_rtmap_edit, 'String', '0.85');
startTime_callback(starttime_rtmap_edit);
% Save handles in figure with handle f.
guidata(riseTimeGroup, handles);



%% callback functions
    function startTime_callback(source,~)
        val_start = str2double(get(source,'String'));
        val_end = str2double(get(endtime_rtmap_edit,'String'));
        if (val_start < 0)
            set(source,'String', 0);
            val_start = 0;
        end
        if (val_start >= val_end)
            set(source,'String', num2str(val_start));
            val_start = val_end;
            val_end = val_start+0.01;
            set(endtime_rtmap_edit,'String', num2str(val_end));
            set(source,'String', num2str(val_start));
        end
        drawTimeLines(val_start, val_end, handles, f);
    end

    function endTime_callback(source,~)
        val_start = str2double(get(starttime_rtmap_edit,'String'));
        val_end = str2double(get(source,'String'));
        if (val_start >= val_end)
            set(source,'String', num2str(val_start+0.01));
            val_end = val_start+0.01;
        end
        drawTimeLines(val_start, val_end, handles, f);
    end 

    function drawTimeLines(val_start, val_end, handles, f)
        if val_start >= 0 && val_start <= handles.time(end)
            if val_end >= 0 && val_end <= handles.time(end)
                % set boundaries to draw time lines
                pointB = [0 1]; 
                playTimeA = [(handles.time(handles.frame)-handles.starttime)*handles.timeScale (handles.time(handles.frame)-handles.starttime)*handles.timeScale];
                startLineA = [(val_start-handles.starttime)*handles.timeScale (val_start-handles.starttime)*handles.timeScale]; 
                endLineA = [(val_end-handles.starttime)*handles.timeScale (val_end-handles.starttime)*handles.timeScale];
                if (handles.bounds(handles.activeScreenNo) == 0)
                    set(f,'CurrentAxes',handles.sweepBar); cla;
                    plot(startLineA, pointB, 'g', 'Parent', handles.sweepBar)
                    hold on
                    axis([0 handles.time(end) 0 1])
                    plot(playTimeA, pointB, 'r', 'Parent', handles.sweepBar)
                    hold on
                    plot(endLineA, pointB, '-g','Parent',handles.sweepBar)
                    hold off; axis off
                    hold off 
                else
                    hold on
                    for i_group=1:5
                        set(f,'CurrentAxes',handles.signalGroup(i_group).sweepBar); cla;
                        plot(startLineA, pointB, 'g', 'Parent', handles.signalGroup(i_group).sweepBar)
                        hold on;
                        plot(playTimeA, pointB, 'r', 'Parent', handles.signalGroup(i_group).sweepBar)
                        hold on;
                        plot(endLineA, pointB, '-g','Parent', handles.signalGroup(i_group).sweepBar)
                        axis([0 handles.time(end) 0 1])
                        hold off; axis off;
                        hold off;
                    end
                    
                end
            else
                error = 'The END TIME must be greater than %d and less than %.3f.';
                msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
                set(endtimeamap_edit,'String',max(handles.time))
            end
        else
            error = 'The START TIME must be greater than %d and less than %.3f.';
            msgbox(sprintf(error,0,max(handles.time)),'Incorrect Input','Warn');
            set(starttimeamap_edit,'String',0)
        end
    end


%% RiseTime
%% Button to create RiseTime map
     function calculate_rt_callback(~,~)
          % Get Input Variables
          APstart = str2double(get(starttime_rtmap_edit,'String'));           % Starting point of selected AP
          APend = str2double(get(endtime_rtmap_edit,'String'));               % End point of the selected AP
          drawTimeLines(APstart,APend,handles, f);
          handles.APstart = APstart;
          handles.APend = APend;

          handles.activeCamData.drawMap = 1;
          
          PercentStart = str2double(get(percent_start_rt_edit,'String'));   % Start percent of upstroke
          PercentEnd = str2double(get(percent_end_rt_edit,'String'));       % End percent of upstroke
          cmosData = handles.activeCamData.cmosData;                                      % Signal conditioned data array
          Rect = getrect(handles.activeScreen);
          rect=round(abs(Rect));
          bg = handles.activeCamData.bg;
          Fs = handles.activeCamData.Fs;

          %Truncate data array to rectangular ROI
          temp = cmosData(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),round(APstart*Fs):round(APend*Fs));

          %Re-Normalize Data
          if size(temp,3) == 1
            min_data = repmat(min(temp,[],2),[1 size(temp,2)]);
            diff_data = repmat(max(temp,[],2)-min(temp,[],2),[1 size(temp,2)]);
            normData = (temp-min_data)./(diff_data);
            temp = normData;
          else
            min_data = repmat(min(temp,[],3),[1 1 size(temp,3)]);
            diff_data = repmat(max(temp,[],3)-min(temp,[],3),[1 1 size(temp,3)]);
            normData = (temp-min_data)./(diff_data);
            temp = normData;
          end

          %Calculate time points of percent start and end
          [~,maxAmpTime] = max(temp,[],3);
          TempStart = zeros(size(temp,1),size(temp,2));
          TempEnd = zeros(size(temp,1),size(temp,2));

          %Start Percent Time
          for i = 1:size(temp,1)
            for j = 1:size(temp,2)
                for k = 1:maxAmpTime(i,j)
                    if temp(i,j,k) >= PercentStart
                        TempStart(i,j) = k; %Save the index when the Start Percent is reached
                        break;
                    end
                end
            end
          end

          %End Percent Time
          for i = 1:size(temp,1)
            for j = 1:size(temp,2)
                for k = 1:maxAmpTime(i,j)
                    if temp(i,j,k) >= PercentEnd
                        TempEnd(i,j) = k; %Save the index when the End Percent is reached
                        break;
                    end
                end
            end
          end

          % Correct unit
          unitFix = 1000.0 / Fs;

          %Calculate difference between start time and end time
          RiseTime = minus(TempEnd,TempStart);
          RiseTime = RiseTime*unitFix;
          RiseTime(RiseTime <= 0) = nan;

          % Calculate Statistics
          RT_mean=nanmean(RiseTime(:));
          RT_std=nanstd(RiseTime(:));
          RT_median=nanmedian(RiseTime(:));
          RT_members = numel(RiseTime(isfinite(RiseTime)));

          % Output results
          handles.activeCamData.meanresults = sprintf('Mean: %0.3f',RT_mean);
          handles.activeCamData.medianresults = sprintf('Median: %0.3f',RT_median);
          handles.activeCamData.SDresults = sprintf('S.D.: %0.3f',RT_std);
          handles.activeCamData.num_membersresults = sprintf('#Members: %d',RT_members);
          handles.activeCamData.angleresults =sprintf('Angle:');
     
          set(handles.meanresults,'String',handles.activeCamData.meanresults);
          set(handles.medianresults,'String',handles.activeCamData.medianresults);
          set(handles.SDresults,'String',handles.activeCamData.SDresults);
          set(handles.num_members_results,'String',handles.activeCamData.num_membersresults);
          set(handles.angleresults,'String',handles.activeCamData.angleresults);

          %Create Masks to plot Risetime map
          Mask=zeros(size(bg));
          Mask(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3))=1;
          Mask2=zeros(size(bg));
          Mask2(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3))=RiseTime;
          
          %Set limits and Build Image
          RT_min = mean(RiseTime(isfinite(RiseTime))) - 2*std(RiseTime(isfinite(RiseTime)));
          RT_max = mean(RiseTime(isfinite(RiseTime))) + 2*std(RiseTime(isfinite(RiseTime)));

          G =real2rgb(bg, 'gray');
          J=real2rgb(Mask2,'jet',[RT_min RT_max]);
          A=real2rgb(Mask,'gray');
          I = J .* A + G .* (1-A);
          %I= Mask2 .*Mask+bg .* (1-Mask);
          handles.activeCamData.saveData = I;
          
          %Plot Rise Time Map and Histogram
%          axes(handles.activeScreen);
          cla(handles.activeCamData.screen);
          set(handles.activeCamData.screen,'YTick',[],'XTick',[]);
          imagesc( handles.activeCamData.screen,I);
          colormap(jet);
          axis(handles.activeCamData.screen,'off')
          %axis image;
          %set(gca,'XTick',[],'YTick',[],'Xlim',[0 size(cmosData,1)],'YLim',[0 size(cmosData,2)]);
          %axis(movie_scrn,'off')
          figure('Name','Histogram of RiseTime')
          hist(reshape(RiseTime,[],1),floor(RT_max-RT_min)*2)
        
     end

 %% percent APD editable textbox
     function percent_rt_edit_callback(source,~)
         val = get(source,'String');
         handles.percentRT = str2double(val);
         if handles.percentRT<.1 || handles.percentRT>1
             msgbox('Please enter number between .1 - 1','Title','Warn')
             set(percentapd_edit,'String','0.8')
         end
     end

%% Export picture from the screen
    function export_button_callback(~,~)  
       if isempty(handles.activeCamData.saveData)
           error = 'ExportedData must exist! Function cancelled.';
           msgbox(error,'Incorrect Input','Error');
           return
       else
        figure;
            image (handles.activeCamData.saveData);
        colormap jet;
        colorbar;
       end
    end
end
