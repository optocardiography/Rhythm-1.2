% GUI for Conduction Velosity Analysis
% Inputs: 
% conductionVelocityGroup -- pannel to draw on
% handles     -- rhythm handles
% f           -- figure of the main rhythm window
% 
% by Roman Pryamonosov, Roman Syunyaev, and Alexander Zolotarev

function GUI_conductionVelocity(conductionVelocityGroup, handles, f)
% New pushbutton with callback definition.
starttimecmap_text = uicontrol('Parent',conductionVelocityGroup, ...
                                       'Style','text','FontSize',10, ...
                                       'String','Start Time',...
                                       'Units','normalized',...
                                       'Position',[.05 .8 .5 .1]);
starttimecmap_edit = uicontrol('Parent',conductionVelocityGroup,...
                                       'Style','edit', 'FontSize',10, ... 
                                       'Units','normalized',...
                                       'Position',[0.6 0.8 .3 .15],...
                                       'Callback', @startTime_callback);
endtimecmap_text = uicontrol('Parent',conductionVelocityGroup, ...
                                     'Style','text','FontSize',10,...
                                     'String','End Time',...
                                     'Units','normalized',...
                                     'Position',[0.05 0.5 0.5 0.15]);
endtimecmap_edit = uicontrol('Parent',conductionVelocityGroup,...
                                     'Style','edit','FontSize',10,...
                                     'Units','normalized',...
                                     'Position',[0.6 0.5 0.3 0.15],...
                                     'Callback', @endTime_callback);
createcmap_button = uicontrol('Parent',conductionVelocityGroup,...
                                     'Style','pushbutton',...
                                     'FontSize',10,...
                                     'String','Calculate',...
                                     'Units','normalized',...
                                     'Position',[0.01 0 0.7 0.15],...
                                     'Callback',@createcmap_button_callback);
                                 
export_icon = imread('icon.png');
export_icon = imresize(export_icon, [20, 20]);                           
export_button = uicontrol('Parent',conductionVelocityGroup,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[0.75, 0, 0.15, 0.15]...
                        ,'Callback',{@export_button_callback});
set(export_button,'CData',export_icon)   
                    
set(starttimecmap_edit, 'String', '0.75');
set(endtimecmap_edit, 'String', '0.85');
startTime_callback(starttimecmap_edit);
    % Save handles in figure with handle f.
    guidata(conductionVelocityGroup, handles);

function startTime_callback(source,~)
        val_start = str2double(get(source,'String'));
        val_end = str2double(get(endtimecmap_edit,'String'));
        if (val_start < 0)
            set(source,'String', 0);
            val_start = 0;
        end
        if (val_start >= val_end)
            set(source,'String', num2str(val_start));
            val_start = val_end;
            val_end = val_start+0.01;
            set(endtimecmap_edit,'String', num2str(val_end));
            set(source,'String', num2str(val_start));
        end
        drawTimeLines(val_start, val_end, handles, f);
    end

    function endTime_callback(source,~)
        val_start = str2double(get(starttimecmap_edit,'String'));
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
                    plot(startLineA, pointB, 'b', 'Parent', handles.sweepBar)
                    hold on
                    axis([0 handles.time(end) 0 1])
                    plot(playTimeA, pointB, 'r', 'Parent', handles.sweepBar)
                    hold on
                    plot(endLineA, pointB, '-b','Parent',handles.sweepBar)
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


% callback functions    
    % Button to create conduction velocity map
    function createcmap_button_callback(~,~)
        % get the bounds of the conduction velocity window
        c_start = str2double(get(starttimecmap_edit,'String'));
        c_end = str2double(get(endtimecmap_edit,'String'));
        drawTimeLines(c_start,c_end, handles, f);
        handles.c_start = c_start;
        handles.c_end = c_end;
        
        set(f,'CurrentAxes',handles.activeScreen);        
        axis([0 100 0 100])
        rect = getrect(handles.activeScreen);
        gg=msgbox('Building Conduction Velocity Map...');
        cMap(handles.activeCamData.cmosData,handles.c_start,handles.c_end,...
            handles.activeCamData.Fs,handles.activeCamData.bg,rect, f,...
            handles.activeScreen, handles);
        handles.activeCamData.drawMap = 1;
        close(gg)
    end

%% Export picture from the screen
    function export_button_callback(~,~)  
       if isempty(handles.activeCamData.saveData)
           error = 'ExportedData must exist! Function cancelled.';
           msgbox(error,'Incorrect Input','Error');
           return
       else
        figure;
 
            startp = round(handles.c_start*handles.activeCamData.Fs);
            endp = round(handles.activeCamData.Fs*handles.c_end);
            contourf(flipud(handles.activeCamData.saveData),(endp-startp)/2,'LineColor','none');
            contourcmap('copper','SourceObject', movie_scrn, 'ColorAlignment', 'center');
            hold on;
            quiver_step = 2;
            q = quiver(handles.activeCamData.saveX_plot(1:quiver_step:end), ...
                   handles.activeCamData.saveY_plot(1:quiver_step:end), ...
                   handles.activeCamData.saveVx_plot(1:quiver_step:end), ...
                   handles.activeCamData.saveVy_plot(1:quiver_step:end),3,'w');
             
            q.LineWidth = 2;
            q.AutoScaleFactor = 2;
            hold off;

        %colormap jet;
        colormap copper;
        colorbar;
       end
    end
end