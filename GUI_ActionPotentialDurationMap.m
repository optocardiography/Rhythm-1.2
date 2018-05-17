% GUI for Action Potentioal Duration analysis
% Inputs: 
% apdMapGroup -- pannel to draw on
% handles     -- rhythm handles
% f           -- figure of the main rhythm window
% 
% by Roman Pryamonosov, Roman Syunyaev, and Alexander Zolotarev 
function GUI_ActionPotentialDurationMap(apdMapGroup, handles, f)
handles.objectToDrawOn = apdMapGroup;

starttime_apdmap_text = uicontrol('Parent',apdMapGroup, ...
                                       'Style','text','FontSize',10, ...
                                       'String','Start Time',...
                                       'Units','normalized',...
                                       'Position',[.05 .9 .5 .1]);
starttimeapdmap_edit = uicontrol('Parent',apdMapGroup,...
                                       'Style','edit', ...
                                       'FontSize',10, ...
                                       'Units','normalized',...
                                       'Position',[.6 .9 .3 .1],...
                                       'Callback', @startTime_callback);
endtime_apdmap_text   = uicontrol('Parent',apdMapGroup, ...
                                       'Style','text',...
                                       'FontSize',10, 'String','End Time',...
                                       'Units','normalized',...
                                       'Position',[.05 .8 .5 .1]);
endtimeapdmap_edit   = uicontrol('Parent',apdMapGroup,...
                                       'Style','edit',...
                                       'FontSize',10, ...
                                       'Units','normalized',...
                                       'Position',[.6 .8 .3 .1], ...
                                       'Callback', @endTime_callback);
create_apdmap_button  = uicontrol('Parent',apdMapGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',10, 'String','Mapping',...
                                       'Units','normalized',...
                                       'Position',[.01 0 .7 .1],...
                                       'Callback',@createapd_button_callback);

minapd_text = uicontrol('Parent',apdMapGroup,'Style','text',...
                                'FontSize',10,'String','Min APD',...
                                'Units','normalized',...
                                'Position',[.05 .6 .5 .1]);
minapd_edit = uicontrol('Parent',apdMapGroup,'Style','edit',...
                                'FontSize',10,'String','0',...
                                'Units','normalized',...
                                'Position',[.6 .6 .3 .1],...
                                'Callback',{@minapd_edit_callback});
maxapd_text = uicontrol('Parent',apdMapGroup,'Style','text',...
                                'FontSize',10,'String','Max APD',...
                                'Units','normalized',...
                                'Position',[.05 .5 .5 .1]);
maxapd_edit = uicontrol('Parent',apdMapGroup,'Style','edit',...
                                'FontSize',10,'String','100',...
                                'Units','normalized',...
                                'Position',[.6 .5 .3 .1],...
                                'Callback',{@maxapd_edit_callback});
percentapd_text= uicontrol('Parent',apdMapGroup,'Style','text',...
                                'FontSize',10,'String','%APD',...
                                'Units','normalized',...
                                'Position',[0.05 .4 .5 .1]);
percentapd_edit= uicontrol('Parent',apdMapGroup,'Style','edit',...
                                'FontSize',10,'String','0.8',...
                                'Units','normalized',...
                                'Position',[.6 .4 .3 .1],...
                                'callback',{@percentapd_edit_callback});
remove_motion_click = uicontrol('Parent',apdMapGroup,'Style','checkbox',...
                                'FontSize',10,'String','Remove Motion',...
                                'Units','normalized',...
                                'Position',[.1 .3 .8 .1]);
calc_apd_button = uicontrol('Parent',apdMapGroup,'Style','pushbutton',...
                                'FontSize',10,'String','Regional APD Calculation',...
                                'Units','normalized',...
                                'Position',[.01 .1 .7 .1],...
                                'Callback',{@calc_apd_button_callback});
export_icon = imread('icon.png');
export_icon = imresize(export_icon, [20, 20]);                           
export_button = uicontrol('Parent',apdMapGroup,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[0.75, 0, 0.2, 0.2]...
                        ,'Callback',{@export_button_callback});
set(export_button,'CData',export_icon)                      
% Save handles in figure with handle f.
guidata(apdMapGroup, handles);
set(starttimeapdmap_edit, 'String', '0.7');
set(endtimeapdmap_edit, 'String', '1.5');
startTime_callback(starttimeapdmap_edit);

% callback functions
 %% APD MAP
 function startTime_callback(source,~)
        val_start = str2double(get(source,'String'));
        val_end = str2double(get(endtimeapdmap_edit,'String'));
        if (val_start < 0)
            set(source,'String', 0);
            val_start = 0;
        end
        if (val_start >= val_end)
            set(source,'String', num2str(val_start));
            val_start = val_end;
            val_end = val_start+0.01;
            set(endtimeapdmap_edit,'String', num2str(val_end));
            set(source,'String', num2str(val_start));
        end
        drawTimeLines(val_start, val_end, handles, f);
    end

    function endTime_callback(source,~)
        val_start = str2double(get(starttimeapdmap_edit,'String'));
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

 
 %% Button to create Global APD map
    function createapd_button_callback(~,~)
        
        % get the bounds of the apd window
        apd_start = str2double(get(starttimeapdmap_edit,'String'));
        apd_end = str2double(get(endtimeapdmap_edit,'String'));
        drawTimeLines(apd_start, apd_end, handles, f);
        handles.apd_start = apd_start;
        handles.apd_end = apd_end;
        gg=msgbox('Creating Global APD Map...');
        handles.percentAPD = str2double(get(percentapd_edit,'String'));
        apdMap(handles.activeCamData.cmosData,handles.apd_start,handles.apd_end,...
                handles.activeCamData.Fs,handles.percentAPD,...
                handles.activeCamData.cmap, handles.activeCamData.screen, handles);
        handles.activeCamData.drawMap = 1;
        close(gg)
     end
 %% Button to Calculate Regional APD
    function calc_apd_button_callback(~,~)
         % Read APD Parameters
         %apdmaptime_edit_callback();
         handles.activeCamData.drawMap = 1;
         handles.apd_start = str2double(get(starttimeapdmap_edit,'String'));
         handles.apd_end = str2double(get(endtimeapdmap_edit,'String'));
         handles.percentAPD = str2double(get(percentapd_edit,'String'));
         handles.maxapd = str2double(get(maxapd_edit,'String'));
         handles.minapd = str2double(get(minapd_edit,'String'));
         % Read remove motion check box
         remove_motion_state =get(remove_motion_click,'Value');
         axes(handles.activeCamData.screen)
         coordinate=getrect(handles.activeCamData.screen);
         gg=msgbox('Creating Regional APD...');
         apdCalc(handles, handles.activeCamData.cmosData,handles.apd_start,handles.apd_end,...
             handles.activeCamData.Fs,handles.percentAPD,handles.maxapd,...
             handles.minapd,remove_motion_state,coordinate,handles.activeCamData.bg,handles.activeCamData.cmap);
         close(gg)
    end


%% APD Min editable textbox
     function minapd_edit_callback(source,~)
         val = get(source,'String');
         handles.minapd = str2double(val);
         if handles.minapd<1 %%% need to account for numbers to large || handles.percentAPD>100
             msgbox('Please enter valid number in milliseconds')
         end
         if handles.maxapd<=handles.minapd
             msgbox('Maximum APD needs to be greater than Minimum APD','Title','Warn')
         end
     end
 %% APD Max editable textbox
     function maxapd_edit_callback(source,~)
         val = get(source,'String');
         handles.maxapd = str2double(val);
         if handles.maxapd<1 % Need to acount for numbers that are too large|| handles.maxapd>100
             msgbox('Please enter valid number in milliseconds')
         end
         if handles.maxapd<=handles.minapd
            msgbox('Maximum APD needs to be greater than Minimum APD','Title','Warn')
         end
     end
 %% percent APD editable textbox
     function percentapd_edit_callback(source,~)
         val = get(source,'String');
         handles.percentAPD = str2double(val);
         if handles.percentAPD<.1 || handles.percentAPD>1
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
        imagesc (handles.activeCamData.saveData);
        colormap jet;
        colorbar;
       end
    end
end
