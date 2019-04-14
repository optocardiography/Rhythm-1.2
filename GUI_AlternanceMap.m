%% GUI for Alternance analysis
% Inputs: 
% alternanceMapGroup    -- pannel to draw on
% handles               -- rhythm handles
% f                     -- figure of the main rhythm window
% 
% by Dmitry Rybashlykov and Andrey Pikunov

function GUI_AlternanceMap(alternanceMapGroup, handles, f)
handles.objectToDrawOn = alternanceMapGroup;

starttime_alternance_text = uicontrol('Parent', alternanceMapGroup,...
                                       'Style', 'text', 'FontSize', 10,...
                                       'String', 'Start Time (sec)',...
                                       'Units', 'normalized',...
                                       'Position', [.05 .9 .5 .1]);
                                   
starttimealternancemap_edit = uicontrol('Parent', alternanceMapGroup,...
                                       'Style', 'edit',...
                                       'FontSize', 10, 'String', '0',...
                                       'Units', 'normalized',...
                                       'Position', [.6 .9 .3 .1],...
                                       'Callback', @startTime_callback);
                                   
endtime_alternancemap_text   = uicontrol('Parent', alternanceMapGroup,...
                                       'Style', 'text',...
                                       'FontSize', 10, 'String', 'End Time (sec)',...
                                       'Units', 'normalized',...
                                       'Position', [.05 .8 .5 .1]);
                                   
endtimealternancemap_edit   = uicontrol('Parent', alternanceMapGroup,...
                                       'Style', 'edit',...
                                       'FontSize', 10, 'String', '1',...
                                       'Units', 'normalized',...
                                       'Position', [.6 .8 .3 .1],...
                                       'Callback', @endTime_callback);

minapd_text = uicontrol('Parent',alternanceMapGroup,...
                                'Style','text',...
                                'FontSize',10,'String','Min APD (ms)',...
                                'Units','normalized',...
                                'Position',[.05 .6 .5 .1]);
                            
minapd_edit = uicontrol('Parent',alternanceMapGroup,...
                                'Style','edit',...
                                'FontSize',10,'String','10',...
                                'Units','normalized',...
                                'Position',[.6 .6 .3 .1],...
                                'Callback',{@minapd_edit_callback});
                            
maxapd_text = uicontrol('Parent',alternanceMapGroup,...
                                'Style','text',...
                                'FontSize',10,'String','Max APD (ms)',...
                                'Units','normalized',...
                                'Position',[.05 .5 .5 .1]);
                            
maxapd_edit = uicontrol('Parent',alternanceMapGroup,...
                                'Style','edit',...
                                'FontSize',10,'String','1000',...
                                'Units','normalized',...
                                'Position',[.6 .5 .3 .1],...
                                'Callback',{@maxapd_edit_callback});
                            
percentapd_text= uicontrol('Parent',alternanceMapGroup,...
                                'Style','text',...
                                'FontSize',10,'String','%APD',...
                                'Units','normalized',...
                                'Position',[0.05 .4 .5 .1]);
                            
percentapd_edit= uicontrol('Parent',alternanceMapGroup,...
                                'Style','edit',...
                                'FontSize',10,'String','55',...
                                'Units','normalized',...
                                'Position',[.6 .4 .3 .1],...
                                'callback',{@percentapd_edit_callback});                                   
                                   
create_alternancemap_button  = uicontrol('Parent',alternanceMapGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',10, 'String','Mapping',...
                                       'Units','normalized',...
                                       'Position',[.01 0 .7 .1],...
                                       'Callback',@createalternance_button_callback);
                                   
regional_alternance_button = uicontrol('Parent',alternanceMapGroup,...
                                'Style','pushbutton',...
                                'FontSize',10,...
                                'String','Regional alternance',...
                                'Units','normalized',...
                                'Position',[.01 .1 .7 .1],...
                                'Callback',{@calc_apd_button_callback});                                   
                                                                
export_icon = imread('icon.png');
export_icon = imresize(export_icon, [20, 20]);                           
export_button = uicontrol('Parent',alternanceMapGroup,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[0.75, 0, 0.2, 0.2],...
                        'Callback',{@export_button_callback});
set(export_button,'CData',export_icon)

% Save handles in figure with handle f.
guidata(alternanceMapGroup, handles);
startTime_callback(starttimealternancemap_edit);

%% callback functions
% alternance MAP
 function startTime_callback(source,~)
        val_start = str2double(get(source,'String'));
        val_end = str2double(get(endtimealternancemap_edit,'String'));
        if (val_start < 0)
            set(source,'String', 0);
            val_start = 0;
        end
        if (val_start >= val_end)
            set(source,'String', num2str(val_start));
            val_start = val_end;
            val_end = val_start+0.01;
            set(endtimealternancemap_edit,'String', num2str(val_end));
            set(source,'String', num2str(val_start));
        end
        drawTimeLines(val_start, val_end, handles, f);
    end

    function endTime_callback(source,~)
        val_start = str2double(get(starttimealternancemap_edit,'String'));
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
                playTimeA = [(handles.time(handles.frame)-handles.starttime)*handles.timeScale (handles.time(handles.frame)-handles.starttime)*handles.timeScale];
                startLineA = [(val_start-handles.starttime)*handles.timeScale (val_start-handles.starttime)*handles.timeScale]; 
                endLineA = [(val_end-handles.starttime)*handles.timeScale (val_end-handles.starttime)*handles.timeScale];
                if (handles.bounds(handles.activeScreenNo) == 0)
                    set(f,'CurrentAxes',handles.sweepBar)
                    pointB = [0 1]; cla;
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
                        set(f,'CurrentAxes',handles.signalGroup(i_group).sweepBar);
                        pointB = [0 1]; cla;
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

 %% Button to create Global alternance map
    function createalternance_button_callback(~,~)
        
        handles.alternance_start = str2double(get(starttimealternancemap_edit,'String'));
        handles.alternance_end = str2double(get(endtimealternancemap_edit,'String'));
        handles.minapd = str2double(get(minapd_edit,'String'));
        handles.maxapd = str2double(get(maxapd_edit,'String'));
        handles.percentAPD = str2double(get(percentapd_edit,'String'));
        
        drawTimeLines(handles.alternance_start,...
                      handles.alternance_end, handles, f);
        
        area_coords = [0, 0,...
                       size(handles.activeCamData.cmosData, 1),...
                       size(handles.activeCamData.cmosData, 2)];
        
        gg=msgbox('Creating global alternance Map...');
        
        alternanceMap(handles.activeCamData.cmosData,...
                        handles.alternance_start,handles.alternance_end,...
                        handles.minapd, handles.maxapd,...
                        handles.percentAPD,...
                        area_coords,...
                        handles.activeCamData.Fs,...
                        redblue(256),...
                        handles.activeCamData.screen,...
                        handles);
        
        handles.activeCamData.drawMap = 1;
        close(gg)
    end

 %% Button to Calculate Regional APD
    function calc_apd_button_callback(~,~)
     
        handles.alternance_start = str2double(get(starttimealternancemap_edit,'String'));
        handles.alternance_end = str2double(get(endtimealternancemap_edit,'String'));
        handles.minapd = str2double(get(minapd_edit,'String'));
        handles.maxapd = str2double(get(maxapd_edit,'String'));
        handles.percentAPD = str2double(get(percentapd_edit,'String'));
        
        drawTimeLines(handles.alternance_start,...
                      handles.alternance_end, handles, f);
        
        area_coords = getrect(handles.activeCamData.screen);
        
        gg=msgbox('Creating regional alternance Map...');
        
        alternanceMap(handles.activeCamData.cmosData,...
                        handles.alternance_start,handles.alternance_end,...
                        handles.minapd, handles.maxapd,...
                        handles.percentAPD,...
                        area_coords,...
                        handles.activeCamData.Fs,...
                        redblue(256),...
                        handles.activeCamData.screen,...
                        handles);
        
        handles.activeCamData.drawMap = 1;
        close(gg)
    end


%% APD Min editable textbox
     function minapd_edit_callback(source,~)
         val = get(source,'String');
         handles.minapd = str2double(val);
         if handles.minapd < 1
             msgbox('Please enter valid number in milliseconds')
         end
         if handles.maxapd <= handles.minapd
             msgbox('Maximum APD needs to be greater than Minimum APD','Title','Warn')
         end
     end
 
 %% APD Max editable textbox
     function maxapd_edit_callback(source,~)
         val = get(source,'String');
         handles.maxapd = str2double(val);
         if handles.maxapd < 1
             msgbox('Please enter valid number in milliseconds')
         end
         if handles.maxapd <= handles.minapd
            msgbox('Maximum APD needs to be greater than Minimum APD','Title','Warn')
         end
     end
 
  %% percent APD editable textbox
     function percentapd_edit_callback(source,~)
         val = get(source,'String');
         handles.percentAPD = str2double(val);
         
         percentage_min = 0;
         percentage_max = 100;
         
         if handles.percentAPD < percentage_min || handles.percentAPD > percentage_max
             msg = sprintf('Please enter the number between %d and %d', percentage_min, percentage_max);
             msgbox(msg, 'Warning', 'Warn')
             set(percentapd_edit, 'String', '55');
         end
         
     end
 
 
 %% Export picture from the screen
    function export_button_callback(~,~)  
       if isempty(handles.activeCamData.saveData)
            error = 'ExportedData must exist! Function cancelled.';
            msgbox(error,'Incorrect Input','Error');
            return
       else   
            alternanceMap = handles.activeCamData.saveData;   
            figure;
            imagesc(alternanceMap, 'AlphaData', ~isnan(alternanceMap));
            set(gca, 'Color', 'k');
            colormap redblue(256);
            alternance_max = max(max(abs(alternanceMap(:))));
            alternance_min = -alternance_max;
            caxis([alternance_min alternance_max]);
            cb = colorbar;
            cb_label = sprintf('Alternance for APD%d (ms)', int8(handles.percentAPD));
            ylabel(cb, cb_label);
       end
    end
end