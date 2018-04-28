
% This is the example/template of a GUI program by Alexander Zolotarev and 
% Roman Pryamonosov. It should consist of two
% parts. First is the painting of all texts, edits, popup-menu and buttons.
% Any button should have button function which runs after clicking on this
% button. This is second part.

% GUI_example have some input arguments. These arguments refer to
% the same arguments in function mapPopUp_callback in rhythm.m

% INPUTS:
% examplePanel -- uibuttongroup, called "map" in rhythm.m 
% handles      -- rhythm.m handle class. Use it to interact with rhythm.m
% f            -- figure of the rhythm.m main window

% add your own arguments if you need

% It is necessary to provide final data for saving in the end of
% subprogram. Please mark your final data (usually
% 100x100 pixels) for mapping on the screen  as handles.activeCamData.saveData. 
% Also, it is necessary to add export button and function
% export_button_callback for saving the map.


function GUI_example(examplePanel,handles, f)

%So this is painting part. User can add any graphic objects here. We
%recommend to use normalized units as a coordinates. Uicontrol with button
%should have Callback.

%example of text+edit
timeText = uicontrol('Parent',examplePanel, ...
                                       'Style','text','FontSize',10, ...
                                       'String','Time',...
                                       'Units','normalized',...
                                       'Position',[.05 .8 .5 .1]);
timeEdit = uicontrol('Parent',examplePanel,...
                                       'Style','edit','FontSize',10, ... 
                                       'Units','normalized',...
                                       'Position',[0.6 0.8 .3 .15], ...
                                       'Callback', @timeEdit_callback);
% example of button
exampleButton_create  = uicontrol('Parent',examplePanel,...
                                       'Style','pushbutton',...
                                       'FontSize',10,...
                                       'String','Calculate',...
                                       'Units','normalized',...
                                       'Position',[0.01 0.1 0.7 0.15],...
                                       'Callback',@exampleButton_callback);                                    
export_icon = imread('icon.png');
export_icon = imresize(export_icon, [20, 20]);
export_button = uicontrol('Parent',examplePanel,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[0.75, 0.1, 0.15, 0.15]...
                        ,'Callback',{@export_button_callback});                                  
set(export_button,'CData',export_icon)                                   
% Please don't forget to add default values.
set(timeEdit, 'String', '0.75');
% Save handles in figure
guidata(examplePanel, handles);


%Second part
% callback functions
%% Time Callback
function timeEdit_callback(~,~) 
    disp (['current value is ', get(timeEdit,'String')]);
    
end
    
%% Button Callback
    function exampleButton_callback(~,~)
        
        %insert your code to get the edit ot pop-up menu values
        %also don't forget to check these values
        disp ('example button callback!');
        
        % example of getting value
        time = str2double(get(timeEdit,'String'));
        if ~(time >= 0 && time <= max(handles.time))
            msgbox('The TIME must be >= 0 and <= max (handles.time)! Now setting it to 0.');
            set(timeEdit,'String',0)
        end
        
        % user can use another separate subprogram "exampleMap" to create or image the
        % map. If you want to do it, create exampleMap file and send any
        % data to this subprogram
        
        % gg=msgbox('Building  Example Map...');
        % exampleMap(handles.activeCamData.cmosData,handles.activeCamData.screen, handles);
        % handles.activeCamData.drawMap = 1;
        % close(gg)
    end

 %% Export button callback 
    function export_button_callback(~,~)  
        disp ('export button callback!');
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