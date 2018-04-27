
% There is the example of any new GUI program. It should consist of two
% parts. First is the painting of all texts, edits, popup-menu and buttons.
% Any button should have button function which runs after clicking on this
% button. This is second part.

%Firstly, GUI_example have some input arguments. These arguments refer to
%the same arguments in function mapPopUp_callback in rhythm.m

%First input argument must be uibuttongroup, called "map" in rhythm.m and
%"exampleMapGroup" here. Parameters of this uibuttongroup are within
%mapPopUp_callback in rhythm.m

%It is strongly recommended to use "handles" and "f" among input arguments.
%"Handles" is a reference to the class storing data, that contains all
%data.
%"f" is the main figure, and if user wants to change something
%on the main screen in real time, he/she need to add "f".

%Other input arguments are up to you.

%It is necessary to provide final data for saving in the end of
%subprogram. Please mark your final data (usually
%100x100 pixels) for mapping on the screen  as handles.activeCamData.saveData. 
%Also, it is necessary to add export button and function
%export_button_callback for saving the map.


function GUI_example(exampleMapGroup,handles, f)

%So this is painting part. User can add any graphic objects here. We
%recommend to use normalized units as a coordinates. Uicontrol with button
%should have Callback.

%example of text+edit
starttimemap_text = uicontrol('Parent',exampleMapGroup, ...
                                       'Style','text','FontSize',10, ...
                                       'String','Start Time',...
                                       'Units','normalized',...
                                       'Position',[.05 .8 .5 .1]);
starttimemap_edit = uicontrol('Parent',exampleMapGroup,...
                                       'Style','edit','FontSize',10, ... 
                                       'Units','normalized',...
                                       'Position',[0.6 0.8 .3 .15]);
% example of button
create_map_button  = uicontrol('Parent',exampleMapGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',10,...
                                       'String','Calculate',...
                                       'Units','normalized',...
                                       'Position',[0.01 0.1 0.7 0.15],...
                                       'Callback',@createmap_button_callback);                                    
export_icon = imread('icon.png');
export_icon = imresize(export_icon, [20, 20]);
export_button = uicontrol('Parent',activationMapGroup,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[0.75, 0.1, 0.15, 0.15]...
                        ,'Callback',{@export_button_callback});                                  
set(export_button,'CData',export_icon)                                   
% Please don't forget to add default values.
set(starttimeamap_edit, 'String', '0.75');
set(endtimeamap_edit, 'String', '0.85');
% Save handles in figure
guidata(activationMapGroup, handles);


%Second part
% callback functions
%% ACTIVATION MAP
%% Button to create activation map
    function createmap_button_callback(~,~)
        
        %insert your code to get the edit ot pop-up menu values
        %also don't forget to check these values
        
        % example of getting value
         a_start = str2double(get(starttimemap_edit,'String'));
         if a_start >= 0 && a_start <= max(handles.time)
             handles.a_start = a_start;
         else
             error = 'The START TIME is wrong!';
             set(starttimeamap_edit,'String',0)
         end
        
        %user can use another separate subprogram "exampleMap" to create or image the
        %map. If you want to do it, create exampleMap file and send any
        %data to this subprogram
        gg=msgbox('Building  Example Map...');
        exampleMap(handles.activeCamData.cmosData,handles.activeCamData.screen, handles);
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
        imagesc(handles.activeCamData.saveData);
        colormap jet;
        colorbar;
       end
    end
end


