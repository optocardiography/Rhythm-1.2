% GUI for Activation Map 
% Inputs: 
% activationMapGroup -- pannel to draw on
% handles     -- rhythm handles
% f           -- figure of the main rhythm window
% 
% by Roman Pryamonosov, Roman Syunyaev, and Alexander Zolotarev

function GUI_ActivationMap(activationMapGroup,handles, f)

fontSize = 9;
pos_bottom = 1; % initial position (top)
element_height = 0.08; % default, you may adjust it

%% FROM TOP TO BOTTOM

%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.6;
starttimeamap_text = uicontrol('Parent',activationMapGroup, ...
                                       'Style','text','FontSize',fontSize, ...
                                       'String','Start Time (s)',...
                                       'Units','normalized',...
                                       'HorizontalAlignment','left',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height]);

pos_left = 0.6;                        
element_width = 1 - pos_left;                                      
starttimeamap_edit = uicontrol('Parent',activationMapGroup,...
                                       'Style','edit','FontSize',fontSize, ... 
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height],...
                                       'Callback',@startTime_callback);
                                   
%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.6;
endtimeamap_text   = uicontrol('Parent',activationMapGroup, ...
                                       'Style','text','FontSize',fontSize,...
                                       'String','End Time (s)',...
                                       'Units','normalized',...
                                       'HorizontalAlignment','left',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height]);
                                   
pos_left = 0.6;                        
element_width = 1 - pos_left;                                      
endtimeamap_edit   = uicontrol('Parent',activationMapGroup,...
                                       'Style','edit','FontSize',fontSize,...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height],...
                                       'Callback',@endTime_callback);

%% 
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.6;
numOfLevels_text = uicontrol('Parent',activationMapGroup,'Style','text',...
                             'FontSize',fontSize,'String','Step length (ms)',...
                             'Units','normalized',...
                             'Position',[pos_left, pos_bottom, element_width, element_height],...
                             'HorizontalAlignment','left',...
                             'Visible','on');

pos_left = 0.6;                        
element_width = 1 - pos_left; 
numOfLevels_edit = uicontrol('Parent',activationMapGroup,'Style','edit',...
                             'FontSize',fontSize,'Units','normalized',...
                             'Position',[pos_left, pos_bottom, element_width, element_height],...
                             'Visible','on',...
                             'Callback', @numOfLevels_callback);
 
%%  AND NOW FROM BOTTOM TO TOP                       
                         
%%   
pos_left = 0;
pos_bottom = 0;
element_width = 1;
isolinesCheckBox = uicontrol('Parent',activationMapGroup,'Style','checkbox',...
                             'String', 'Draw Isolines','FontSize',fontSize,...
                             'Units','normalized',...
                             'HorizontalAlignment','left',...
                             'Position',[pos_left, pos_bottom, element_width, element_height],...
                             'HorizontalAlignment','left',...
                             'Visible','on');
                                   
%%   
pos_left = 0;
pos_bottom = pos_bottom + element_height;
element_width = 0.75;
create_amap_button  = uicontrol('Parent',activationMapGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',fontSize,...
                                       'String','Regional map',...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height],...
                                       'Callback',@createamap_button_callback);

pos_left = 0.75;
element_width = 0.25;                                   
export_icon = imread('icon.png');
export_icon = imresize(export_icon, [20, 20]);
export_button = uicontrol('Parent',activationMapGroup,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[pos_left, pos_bottom, element_width, 2*element_height]...
                        ,'Callback',{@export_button_callback});                                      

                    
pos_left = 0;
pos_bottom = pos_bottom + element_height;
element_width = 0.75;
create_amap_button  = uicontrol('Parent',activationMapGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',fontSize,...
                                       'String','Global map',...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height],...
                                       'Callback',@createamap_global_button_callback);
%%                               
set(export_button,'CData',export_icon)                                  
set(starttimeamap_edit, 'String', '0.75');
set(endtimeamap_edit, 'String', '0.85');
startTime_callback(starttimeamap_edit);
% Save handles in figure with handle f.

set(numOfLevels_edit,'String',num2str( 1./ handles.activeCamData.Fs));
numOfLevels_callback(numOfLevels_edit);
guidata(activationMapGroup, handles);



% callback functions
%% ACTIVATION MAP
%%
    function numOfLevels_callback(source,~)
        startTime = str2double(get(starttimeamap_edit ,'String'));
        endTime = str2double(get(endtimeamap_edit ,'String'));
        val_map_step = str2double(get(source,'String'));
        if (val_map_step < 1 / handles.activeCamData.Fs)
            set(source,'String', num2str(1 / handles.activeCamData.Fs));
            val_map_step = 1 / handles.activeCamData.Fs;
        end
        if (val_map_step >= (endTime - startTime))
            set(source,'String', num2str((endTime - startTime)));
            val_map_step = endTime - startTime;
        end
        
        %         handles.numOfContourLevels = round(val_map_step * handles.activeCamData.Fs)+1;
        handles.numOfContourLevels = round((endTime - startTime) / val_map_step) + 1;
    end

%% Button to create activation map
    function startTime_callback(source,~)
        val_start = str2double(get(source,'String'));
        val_end = str2double(get(endtimeamap_edit,'String'));
        if (val_start < 0)
            set(source,'String', 0);
            val_start = 0;
        end
        if (val_start >= val_end)
            set(source,'String', num2str(val_start));
            val_start = val_end;
            val_end = val_start+0.01;
            set(endtimeamap_edit,'String', num2str(val_end));
            set(source,'String', num2str(val_start));
        end
        drawTimeLines(val_start, val_end, handles, f);
        set(numOfLevels_edit,'String', num2str( 1./handles.activeCamData.Fs));
        numOfLevels_callback(numOfLevels_edit);
    end

    function endTime_callback(source,~)
        val_start = str2double(get(starttimeamap_edit,'String'));
        val_end = str2double(get(source,'String'));
        if (val_start >= val_end)
            set(source,'String', num2str(val_start+0.01));
            val_end = val_start+0.01;
        end
        drawTimeLines(val_start, val_end, handles, f);
        set(numOfLevels_edit,'String', num2str( 1./handles.activeCamData.Fs));
        numOfLevels_callback(numOfLevels_edit);
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

    function createamap_button_callback(~,~)
        % get the bounds of the activation window
        a_start = str2double(get(starttimeamap_edit,'String'));
        a_end = str2double(get(endtimeamap_edit,'String'));
        drawTimeLines(a_start, a_end, handles, f);
        handles.a_start = a_start;
        handles.a_end = a_end;
        Rect = getrect(handles.activeScreen);
        rect=round(abs(Rect));
        axes(handles.activeCamData.screen)
        gg=msgbox('Building  Activation Map...');
        aMap(handles.activeCamData.cmosData,...
             handles.a_start,handles.a_end,rect,...
             handles.activeCamData.Fs,handles.activeCamData.cmap, handles.activeCamData.screen, handles);
        handles.activeCamData.drawMap = 1;
        close(gg)
    end

    function createamap_global_button_callback(~,~)
        % get the bounds of the activation window
        a_start = str2double(get(starttimeamap_edit,'String'));
        a_end = str2double(get(endtimeamap_edit,'String'));
        drawTimeLines(a_start, a_end, handles, f);
        handles.a_start = a_start;
        handles.a_end = a_end;
        N = size(handles.activeCamData.cmosData, 1);
        M = size(handles.activeCamData.cmosData, 2);
        rect = [1 1 M-1 N-1];
        axes(handles.activeCamData.screen)
        gg=msgbox('Building  Activation Map...');
        aMap(handles.activeCamData.cmosData,...
             handles.a_start,handles.a_end,rect,...
             handles.activeCamData.Fs,handles.activeCamData.cmap, handles.activeCamData.screen, handles);
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
            isDrawIsolines = get(isolinesCheckBox,'Value');
            if isDrawIsolines
                contourf(flipud(handles.activeCamData.saveData),handles.numOfContourLevels-1,'LineColor','k');
            else
                contourf(flipud(handles.activeCamData.saveData),handles.numOfContourLevels-1,'LineColor','none');
            end
            colormap jet;
            colorbar;
        end
    end
end
