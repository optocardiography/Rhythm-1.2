%% GUI for Alternance analysis
% Inputs: 
% alternanceMapGroup    -- pannel to draw on
% handles               -- rhythm handles
% f                     -- figure of the main rhythm window
% 
% by Dmitry Rybashlykov

function GUI_AlternanceMap(alternanceMapGroup, handles, f)
handles.objectToDrawOn = alternanceMapGroup;

starttime_alternance_text = uicontrol('Parent',alternanceMapGroup, ...
                                       'Style','text','FontSize',10, ...
                                       'String','Start Time',...
                                       'Units','normalized',...
                                       'Position',[.05 .9 .5 .1]);
starttimealternancemap_edit = uicontrol('Parent',alternanceMapGroup,...
                                       'Style','edit', ...
                                       'FontSize',10, ...
                                       'Units','normalized',...
                                       'Position',[.6 .9 .3 .1],...
                                       'Callback', @startTime_callback);
endtime_alternancemap_text   = uicontrol('Parent',alternanceMapGroup, ...
                                       'Style','text',...
                                       'FontSize',10, 'String','End Time',...
                                       'Units','normalized',...
                                       'Position',[.05 .8 .5 .1]);
endtimealternancemap_edit   = uicontrol('Parent',alternanceMapGroup,...
                                       'Style','edit',...
                                       'FontSize',10, ...
                                       'Units','normalized',...
                                       'Position',[.6 .8 .3 .1], ...
                                       'Callback', @endTime_callback);
create_alternancemap_button  = uicontrol('Parent',alternanceMapGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',10, 'String','Mapping',...
                                       'Units','normalized',...
                                       'Position',[.01 0 .7 .1],...
                                       'Callback',@createalternance_button_callback);
                                   
export_icon = imread('icon.png');
export_icon = imresize(export_icon, [20, 20]);                           
export_button = uicontrol('Parent',alternanceMapGroup,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[0.75, 0, 0.2, 0.1],...
                        'Callback',{@export_button_callback});
set(export_button,'CData',export_icon)

% Save handles in figure with handle f.
guidata(alternanceMapGroup, handles);
set(starttimealternancemap_edit, 'String', '0.7');
set(endtimealternancemap_edit, 'String', '1.5');
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
        
        % get the bounds of the alternance window
        alternance_start = str2double(get(starttimealternancemap_edit,'String'));
        alternance_end = str2double(get(endtimealternancemap_edit,'String'));
        drawTimeLines(alternance_start, alternance_end, handles, f);
        handles.alternance_start = alternance_start;
        handles.alternance_end = alternance_end;
        gg=msgbox('Creating Global alternance Map...');
        alternanceMap(handles.activeCamData.cmosData,...
                        handles.alternance_start,handles.alternance_end,...
                        handles.activeCamData.Fs,...
                        redblue(256),...
                        handles.activeCamData.screen,...
                        handles);
        
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
            alternanceMap = handles.activeCamData.saveData;   
            figure;
            imagesc (handles.activeCamData.saveData);
            colormap redblue(16);
            colorbar;

            alternance_max = prctile(abs(alternanceMap(:)), 99);
            alternance_min = -alternance_max;

            caxis([alternance_min alternance_max]);
       end
    end
end