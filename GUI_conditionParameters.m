% Signal Processing instruments
% Inputs:  
% conditionParametersGroup -- pannel to draw on
% handles                  -- rhythm handles
% 
% by Roman Pryamonosov, Roman Syunyaev, and Alexander Zolotarev

function GUI_conditionParameters(conditionParametersGroup, handles)
% New pushbutton with callback definition.
% Signal Conditioning Button Group and Buttons

font_size = 9;
pos_bottom = 1; % initial position (top)
element_height = 0.065; % default, you may adjust it
% We will move from top to bottom and create buttons and labels
                        
%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.6;
removeBG_button = uicontrol('Parent',conditionParametersGroup,...
                            'Style','checkbox','FontSize',font_size,...
                            'String','Remove BG',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height],...
                            'Callback',@removeBGcheckbox_callback);

pos_left = 0.6;                        
element_width = 1 - pos_left;                        
brush_checkbox = uicontrol('Parent',conditionParametersGroup,...
                            'Style','checkbox','FontSize',font_size,...
                            'String','Brush',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height],...
                            'Callback',{@brush_checkbox_callback});
                        
    function brush_checkbox_callback(src,~)
        handles.drawBrush = get(src,'Value');
    end

%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 1;
bg_thresh_label = uicontrol('Parent',conditionParametersGroup, ...
                            'Style','text','FontSize',font_size,...
                            'String','Threshold',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height]);

%%
pos_left = 0;
slider_height = 0.05;
pos_bottom = pos_bottom - slider_height;
element_width = 1;
bg_thresh_slider = uicontrol('Parent',conditionParametersGroup,...
                            'Style', 'slider', 'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, slider_height],...
                            'SliderStep',[.01 .02], 'Value',0.5,...
                            'Callback',{@removeBG_callback});

%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.75;
removeIslandsCheckbox = uicontrol('Parent',conditionParametersGroup,'Style','checkbox',...
                          'FontSize',font_size,'String','Remove Islands',...
                          'Units','normalized',...
                          'Position',[pos_left, pos_bottom, element_width, element_height],...
                          'Callback', {@removeBG_callback});

pos_left = 0.75;
element_width = 1 - pos_left;
perc_ex_height = element_height;
perc_ex_edit = uicontrol('Parent',conditionParametersGroup,'Style','edit',...
                         'FontSize',font_size,...
                         'String',handles.removeIslandsPercent,...
                         'Units','normalized',...
                         'Position',[pos_left, pos_bottom, element_width, perc_ex_height],...
                         'Callback',@removeBG_callback);

%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 1;
fillHoles_checkbox = uicontrol('Parent',conditionParametersGroup,...
                            'Style','checkbox','FontSize',font_size,...
                            'String','Fill Holes',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height],...
                            'Callback',@removeBG_callback);
        
%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.5;
bin_button  = uicontrol('Parent',conditionParametersGroup,...
                        'Style','checkbox',...
                        'FontSize',font_size,...
                        'String','Bin',...
                        'Units','normalized',...
                        'Position',[pos_left, pos_bottom, element_width, element_height]);

pos_left = 0.5;     
element_width = 1 - pos_left;
kernel_popup = uicontrol('Parent',conditionParametersGroup,...
                      'Style','popupmenu',...
                      'FontSize',font_size,...
                      'String',{'gaussian', 'uniform'},...
                      'Units','normalized',...
                      'Position',[pos_left, pos_bottom, element_width, element_height]);                      

%%
pos_bottom = pos_bottom - element_height;

pos_left = 0.5;
element_width = 0.25;
kernel_size_label = uicontrol('Parent',conditionParametersGroup, ...
                            'Style','text','FontSize',font_size,...
                            'String','size',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height]);   
pos_left = 0.75;
element_width = 0.25;
kernel_edit_height = element_height;
kernel_size_edit = uicontrol('Parent',conditionParametersGroup,...
                         'Style','edit',...
                         'FontSize',font_size,...
                         'String','3',...
                         'Units','normalized',...
                         'Position',[pos_left, pos_bottom, element_width, kernel_edit_height],...
                         'Callback', @kernel_size_edit_callback);
                                            
%%     
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.5;
filt_button = uicontrol('Parent',conditionParametersGroup,'Style','checkbox',...
                        'FontSize',font_size,'String','Filter',...
                        'Units','normalized',...
                        'Position',[pos_left, pos_bottom, element_width, element_height]);
pos_left = 0.5;
element_width = 1 - pos_left;                    
filt_popup = uicontrol('Parent',conditionParametersGroup,...
                       'Style','popupmenu','FontSize',font_size,...
                       'String',{'[0 50]','[0 75]', '[0 100]', '[0 150]'},...
                       'Units','normalized',...
                       'Position',[pos_left, pos_bottom, element_width, element_height]);  
                   
set(filt_popup,'Value',3)

%%
pos_left = 0.5;
pos_bottom = pos_bottom - element_height;
element_width = 1 - pos_left;
filt_60hz_button = uicontrol('Parent',conditionParametersGroup,...
                             'Style','checkbox','FontSize',font_size,...
                             'String','60 Hz filter',...
                             'Units','normalized',...
                             'Position',[pos_left, pos_bottom, element_width, element_height]);

%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.5;
removeDrift_button = uicontrol('Parent',conditionParametersGroup,...
                        'Style','checkbox','FontSize',10,'String','Drift',...
                        'Units','normalized',...
                        'Position',[pos_left, pos_bottom, element_width, element_height]);

pos_left = 0.5;
element_width = 1 - pos_left;                      
drift_popup = uicontrol('Parent',conditionParametersGroup,...
                        'Style','popupmenu','FontSize',font_size,...
                        'String',{'polynomial', 'asLS'},...
                        'Units','normalized',...
                        'Position',[pos_left, pos_bottom, element_width, element_height],...
                        'Callback',@drift_popup_callback);                      
                    
%%
font_size_small = font_size - 1;
element_height_small = element_height * font_size_small / font_size;
pos_bottom = pos_bottom - element_height_small;

pos_left = 0;
element_width = 0.3;
asym_param_label = uicontrol('Parent',conditionParametersGroup, ...
                            'Style','text',...
                            'FontSize',font_size_small,...
                            'String','asymmetry',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height_small]);  
                        
pos_left = element_width;
element_width = 0.5 - pos_left;
asym_param_edit = uicontrol('Parent',conditionParametersGroup,...
                         'Style','edit',...
                         'Enable','off',...
                         'FontSize',font_size_small,...
                         'String','0.01',...
                         'Units','normalized',...
                         'Position',[pos_left, pos_bottom, element_width, element_height_small],...
                         'Callback', @asym_param_edit_callback);
                     
pos_left = 0.5;
element_width = 0.3;
first_drift_param_label = uicontrol('Parent',conditionParametersGroup, ...
                            'Style','text',...
                            'FontSize',font_size_small,...
                            'String','order',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height_small]); 
                        
pos_left = pos_left + element_width;
element_width = 1 - pos_left;
first_drift_param_height = element_height;
first_drift_param_edit = uicontrol('Parent',conditionParametersGroup,...
                         'Style','edit',...
                         'FontSize',font_size_small,...
                         'String','3',...
                         'Units','normalized',...
                         'Position',[pos_left, pos_bottom, element_width, element_height_small]);

%%                     
pos_bottom = pos_bottom - element_height_small;

pos_left = 0;
element_width = 0.3;
smooth_param_label = uicontrol('Parent',conditionParametersGroup, ...
                            'Style','text',...
                            'FontSize',font_size_small,...
                            'String','smoothness',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height_small]);   
pos_left = 0.3;
element_width = 1 - pos_left;
Max_value = 9; Min_value = 2;
slider_step = 1. / (Max_value - Min_value);
smooth_param_slider = uicontrol('Parent',conditionParametersGroup,...
                            'Style', 'slider', 'Units','normalized',...
                            'Enable','off',...
                            'Min',Min_value,'Max',Max_value,...
                            'SliderStep',[slider_step slider_step], 'Value',Max_value,...
                            'Position',[pos_left, pos_bottom, element_width, element_height_small]);
%% 
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 1;
inverse_button = uicontrol('Parent',conditionParametersGroup,...
                           'Style','checkbox','FontSize',font_size,...
                           'String','Inverse signal',...
                           'Units','normalized',...
                         'Position',[pos_left, pos_bottom, element_width, element_height]);
%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 1;
norm_button  = uicontrol('Parent',conditionParametersGroup,'Style','checkbox',...
                        'FontSize',font_size,'String','Normalize',...
                        'Units','normalized',...
                        'Position',[pos_left, pos_bottom, element_width, element_height]);
                                         
%%  
pos_left = 0;
pos_bottom = 0;
element_width = 1;
apply_button = uicontrol('Parent',conditionParametersGroup,...
                         'Style','pushbutton','FontSize',font_size,...
                         'String','Apply',...
                         'Units','normalized',...
                         'Position',[pos_left, pos_bottom, element_width, element_height],...
                         'Callback',@cond_sig_selcbk);

%%
guidata(conditionParametersGroup, handles);
if (handles.activeCamData.isloaded)
    removeBG_callback(removeBG_button);
end

    function removeBG_callback(hObject,~)
        %threshold = str2double(get(bg_thresh_edit,'String'));
        val = get(bg_thresh_slider,'Value');
        
        maxBG = max (handles.activeCamData.bg);
        minBG = min (handles.activeCamData.bg);
        
        frame = handles.activeCamData.bgRGB;
        BG = mat2gray(frame);
        
        BW = im2bw(BG,val); % create mask
        
        handles.activeCamData.thresholdSegmentation = BW;
        handles.activeCamData.finalSegmentation = handles.activeCamData.brushSegmentation | handles.activeCamData.thresholdSegmentation;
        
        handles.isFillHoles = get(fillHoles_checkbox,'Value');
        if handles.isFillHoles
            handles.activeCamData.finalSegmentation = imfill(handles.activeCamData.finalSegmentation,'holes'); %fill holes
        end
        
        handles.isRemoveIslands = get(removeIslandsCheckbox,'Value');
        handles.removeIslandsPercent = str2double (get(perc_ex_edit, 'String'));
        if handles.isRemoveIslands
            handles.activeCamData.finalSegmentation = bwareaopen(handles.activeCamData.finalSegmentation , ceil(handles.removeIslandsPercent*size(BG ,1)*size(BG,2))); % remove islands
        end
        drawFrame(handles.frame ,handles.activeScreenNo, handles);
        redrawWaveScreens(handles);
    end


    function removeBGcheckbox_callback(hObject,eventdata)
        removeBG_callback(hObject);
        handles.drawSegmentation = get(hObject,'Value');
        drawFrame(handles.frame ,handles.activeScreenNo, handles);
        redrawWaveScreens(handles);
    end


    function kernel_size_edit_callback(source,~)
        
        kernel_size = str2double(get(kernel_size_edit, 'String'));
        
        if (kernel_size < 3) || (mod(kernel_size, 2) ~= 1)
            
            error_report = 'Kernel size must be odd value greater than 3!';
            msgbox(error_report, 'Incorrect Input', 'Error');
            
            kernel_size = max(3, floor(kernel_size));
            
            if (mod(kernel_size, 2) ~= 1)
                kernel_size = kernel_size + 1;
            end
            
            set(kernel_size_edit, 'String', string(kernel_size));
        end
    end


    function asym_param_edit_callback(source,~)
        asym_param = str2double(get(asym_param_edit, 'String'));
        if (asym_param <= 0) || (asym_param >= 1)
            error_report = ['Asymmetry parameter must belong to (0, 1)!' newline ...
                            'Note: use values from 0.001 to 0.1 for signal with positive peaks (/\-shaped) and from 0.9 to 0.999 for signal with negative peaks (\/-shaped).'];
            msgbox(error_report, 'Incorrect Input', 'Error');
            set(asym_param_edit, 'String', 0.01);
        end
    end


    function drift_popup_callback(source,~)
       
        drift_popup_state = get(drift_popup,'Value');
        method_name_list = get(drift_popup, 'String');
        
        method_name = method_name_list{drift_popup_state};
        if strcmp(method_name, 'polynomial')
            set(first_drift_param_label,'String','order');
            set(smooth_param_slider,'Enable','off');
            set(asym_param_edit,'Enable','off');
        elseif strcmp(method_name, 'asLS')
            set(first_drift_param_label,'String','iterations'); 
            set(smooth_param_slider,'Enable','on');
            set(asym_param_edit,'Enable','on');
        end
    end


%% Condition Signals Selection Change Callback
    function cond_sig_selcbk(hObject,~)
        
        % Read check box
        removeBG_state          = get(removeBG_button,'Value');
        bin_state               = get(bin_button,'Value');
        filt_state              = get(filt_button,'Value');
        filt_60hz_state         = get(filt_60hz_button,'Value');
        drift_state             = get(removeDrift_button,'Value');
        norm_state              = get(norm_button,'Value');
        inverse_state           = get(inverse_button,'Value');
        
        % Grab pop up box values
        bin_pop_state           = get(kernel_popup,'Value');
        
        % Create variable for tracking conditioning progress
        trackProg = [removeBG_state,...
                     filt_state,...
                     filt_60hz_state,...
                     bin_state,...
                     drift_state,...
                     norm_state,...
                     inverse_state];
        trackProg = sum(trackProg);
        
        counter = 0;
        g1 = waitbar(counter,'Conditioning Signal');
        
        % Return to raw unfiltered cmos data    
        handles.normflag = 0; % Initialize normflag
        handles.activeCamData.cmosData = handles.activeCamData.cmosRawData;
        handles.activeCamData.drawMap = 0;
        handles.activeCamData.drawPhase = 0;
        handles.matrixMax = 1;
        handles.normalizeMinVisible = 0.3;
        
        mask = handles.activeCamData.finalSegmentation;
        if handles.drawSegmentation == 0
            mask = ones(size(mask));
        end
        
        %% Remove Background
        if removeBG_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Removing Background');
            handles.activeCamData.cmosData = handles.activeCamData.cmosData.* repmat(mask,...
                                                                                     [1 1 size(handles.activeCamData.cmosData, 3)]);
        end
        
        %% Bin Data
        if bin_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg, g1, 'Binning Data');
            
            if bin_pop_state == 1
                kernel_name = 'uniform';
            elseif bin_pop_state == 2
                kernel_name = 'gaussian';
            end
            
            kernel_size = str2double(get(kernel_size_edit, 'String'));
           
            handles.activeCamData.cmosData = binning(handles.activeCamData.cmosData, mask, kernel_size, kernel_name);
        end
        
        %% Filter Data
        if filt_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Filtering Data');
            filt_pop_state = get(filt_popup,'Value');
            if filt_pop_state == 4
                or = 100;
                lb = 0.5;
                hb = 150;
            elseif filt_pop_state == 3
                or = 100;
                lb = 0.5;
                hb = 100;
            elseif filt_pop_state == 2
                or = 100;
                lb = 0.5;
                hb = 75;
            else
                or = 100;
                lb = 0.5;
                hb = 50;
            end
            handles.activeCamData.cmosData = filter_data(handles.activeCamData.cmosData,...
                                                         handles.activeCamData.Fs,...
                                                         or, lb, hb);
        end
        
        %% Remove 60 Hz hum
        if filt_60hz_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg, g1, 'Removing 60 Hz hum');
            handles.activeCamData.cmosData = remove_60hz(handles.activeCamData.cmosData,...
                                                         handles.activeCamData.Fs);
        end
        
        %% Remove Drift
        if drift_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Removing Drift');
            
            drift_popup_state = get(drift_popup,'Value');
            method_name_list = get(drift_popup, 'String');
            
            method_name = method_name_list{drift_popup_state};
            
            first_drift_param = str2double(get(first_drift_param_edit, 'String'));
            first_drift_param = round(first_drift_param);
            set(first_drift_param_edit,'String',num2str(first_drift_param));
            
            if strcmp(method_name, 'polynomial')
                order = first_drift_param;
                method_params = [order];
            elseif strcmp(method_name, 'asLS')
                n_iter = first_drift_param;
                smoothness_param_power = get(smooth_param_slider, 'Value');
                smoothness_param = 10^smoothness_param_power;
                asym_param = str2double(get(asym_param_edit, 'String'));
                method_params = [smoothness_param, asym_param, n_iter];
            end
            
            handles.activeCamData.cmosData = remove_Drift(handles.activeCamData.cmosData, mask,...
                                                          method_name, method_params);
        end

        %% Inverse Data
        if inverse_state==1
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Inversing Data');
            handles.activeCamData.cmosData=-handles.activeCamData.cmosData+max(handles.activeCamData.cmosData(:))+min(handles.activeCamData.cmosData(:));
        end
                
        %% Normalize Data
        if norm_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Normalizing Data');
            handles.activeCamData.cmosData = normalize_data(handles.activeCamData.cmosData);
            handles.normflag = 1;
        end
                
        %% Delete the progress bar
        delete(g1)
        
        %% Save conditioned signal
        hObject.UserData = handles.activeCamData.cmosData;
        
        %% Save handles in figure with handle f.
        guidata(conditionParametersGroup, handles);
        guidata(handles.activeScreen, handles);
        if isempty(handles.activeCamData.cmosData)
            msgbox('Warning: No data selected','Title','warn')
        else
            cla(handles.activeScreen);
            handles.matrixMax = .9 * max(handles.activeCamData.cmosData(:));
            currentframe = handles.frame;
            if handles.normflag == 0
                drawFrame(currentframe, handles.activeScreenNo, handles);
                redrawWaveScreens(handles);
                hold on
            else
                drawFrame(currentframe, handles.activeScreenNo, handles);
                redrawWaveScreens(handles);
                caxis([0 1])
                hold on
            end
            set(handles.activeScreen,'YTick',[],'XTick',[]);% Hide tick markes
        end
        
    end
guidata(conditionParametersGroup, handles);
end
