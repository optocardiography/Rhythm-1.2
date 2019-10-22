% Signal Processing instruments
% Inputs:  
% conditionParametersGroup -- pannel to draw on
% handles                  -- rhythm handles
% 
% by Roman Pryamonosov, Roman Syunyaev, and Alexander Zolotarev

function GUI_conditionParameters(conditionParametersGroup, handles)
% New pushbutton with callback definition.
% Signal Conditioning Button Group and Buttons

font_size = 8.5;
pos_bottom = 1; % initial position (top)
element_height = 0.0625; % default, you may adjust it

font_size_small = font_size * 0.9;
element_height_small = element_height * font_size_small / font_size;

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
                            'Style','checkbox','FontSize',font_size_small,...
                            'String','Brush',...
                            'Enable','off',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height],...
                            'Callback',{@brush_checkbox_callback});
                        
%%
pos_left = 0;
pos_bottom = pos_bottom - element_height_small;
element_width = 0.3;
bg_thresh_label = uicontrol('Parent',conditionParametersGroup, ...
                            'Style','text','FontSize',font_size_small,...
                            'String','threshold',...
                            'HorizontalAlignment','right',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height_small]);

pos_left = pos_left + element_width;
element_width = 1 - pos_left;
bg_thresh_slider = uicontrol('Parent',conditionParametersGroup,...
                            'Style', 'slider',...
                            'Enable','off',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height_small],...
                            'SliderStep',[.01 .02], 'Value',0.5,...
                            'Callback',{@removeBG_callback});

%%
pos_bottom = pos_bottom - element_height_small;
pos_left = 0.1;
element_width = 0.65;
removeIslandsCheckbox = uicontrol('Parent',conditionParametersGroup,'Style','checkbox',...
                          'FontSize',font_size_small,...
                          'String','remove islands',...
                          'Enable','off',...
                          'Units','normalized',...
                          'Position',[pos_left, pos_bottom, element_width, element_height_small],...
                          'Callback', {@removeBG_callback});

pos_left = pos_left + element_width;
element_width = 1 - pos_left;
perc_ex_edit = uicontrol('Parent',conditionParametersGroup,'Style','edit',...
                         'FontSize',font_size_small,...
                         'String',handles.removeIslandsPercent,...
                         'Units','normalized',...
                         'Enable','off',...
                         'Position',[pos_left, pos_bottom, element_width, element_height_small],...
                         'Callback',@removeBG_callback);

%%
pos_left = 0.1;
pos_bottom = pos_bottom - element_height_small;
element_width = 0.4;
fillHoles_checkbox = uicontrol('Parent',conditionParametersGroup,...
                            'Style','checkbox','FontSize',font_size_small,...
                            'String','fill holes',...
                            'Units','normalized',...
                            'Enable','off',...
                            'Position',[pos_left, pos_bottom, element_width, element_height_small],...
                            'Callback',@removeBG_callback);
                                   
upload_icon = imread('upload_pictogram.png');
upload_icon = imresize(upload_icon, [15, 15]); 

button_width = 2 * element_height;
pos_left = 0.75;
upload_button = uicontrol('Parent',conditionParametersGroup,...
                          'Style','pushbutton',...
                          'Units','normalized',...
                          'Enable','off',...
                          'Position',[pos_left, pos_bottom, button_width, element_height_small],...
                          'Callback',@upload_button_callback);
set(upload_button,'CData',upload_icon);   

download_icon = imread('download_pictogram.png');
download_icon = imresize(download_icon, [15, 15]); 

button_width = 2 * element_height;
pos_left = 0.875;
download_button = uicontrol('Parent',conditionParametersGroup,...
                          'Style','pushbutton',...
                          'Units','normalized',...
                          'Enable','off',...
                          'Position',[pos_left, pos_bottom, button_width, element_height_small],...
                          'Callback',@download_button_callback);
set(download_button,'CData',download_icon); 
                        

%%
pos_left = 0.1;
pos_bottom = pos_bottom - element_height_small;
element_width = 1 - pos_left;
polygon_mask_button = uicontrol('Parent',conditionParametersGroup,...
                         'Style','pushbutton','FontSize',font_size_small,...
                         'String','draw polygon',...
                         'Units','normalized',...
                         'Enable','off',...
                         'Position',[pos_left, pos_bottom, element_width, element_height_small],...
                         'Callback',@polygon_mask_button_callback);
%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.5;
bin_button  = uicontrol('Parent',conditionParametersGroup,...
                        'Style','checkbox',...
                        'FontSize',font_size,...
                        'String','Binning',...
                        'Units','normalized',...
                        'Position',[pos_left, pos_bottom, element_width, element_height],...
                        'Callback',@bin_button_callback);

pos_left = 0.5;     
element_width = 1 - pos_left;
kernel_popup = uicontrol('Parent',conditionParametersGroup,...
                      'Style','popupmenu',...
                      'FontSize',font_size_small,...
                      'String',{'gaussian', 'uniform'},...
                      'Units','normalized',...
                      'Enable','off',...
                      'Position',[pos_left, pos_bottom, element_width, element_height_small]);                      

%%
pos_bottom = pos_bottom - element_height_small;
pos_left = 0.5;
element_width = 0.25;
kernel_size_label = uicontrol('Parent',conditionParametersGroup, ...
                            'Style','text','FontSize',font_size_small,...
                            'String','size',...
                            'HorizontalAlignment','right',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height_small]);   
pos_left = 0.75;
element_width = 0.25;
kernel_size_edit = uicontrol('Parent',conditionParametersGroup,...
                         'Style','edit',...
                         'FontSize',font_size_small,...
                         'String','3',...
                         'Units','normalized',...
                         'Enable','off',...
                         'Position',[pos_left, pos_bottom, element_width, element_height_small],...
                         'Callback', @kernel_size_edit_callback);
                                            
%%     
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.5;
filt_button = uicontrol('Parent',conditionParametersGroup,'Style','checkbox',...
                        'FontSize',font_size,'String','Low-pass (Hz)',...
                        'Units','normalized',...
                        'Position',[pos_left, pos_bottom, element_width, element_height],...
                        'Callback', @filt_button_callback);
pos_left = 0.5;
element_width = 1 - pos_left;                    
filt_popup = uicontrol('Parent',conditionParametersGroup,...
                       'Style','popupmenu','FontSize',font_size_small,...
                       'String',{'[0 50]','[0 75]', '[0 100]', '[0 150]'},...
                       'Value',3,...
                       'Enable','off',...
                       'Units','normalized',...
                       'Position',[pos_left, pos_bottom, element_width, element_height_small]);  

%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 1 - pos_left;
filt_60hz_button = uicontrol('Parent',conditionParametersGroup,...
                             'Style','checkbox','FontSize',font_size,...
                             'String','Band-stop 60 Hz',...
                             'Units','normalized',...
                             'Position',[pos_left, pos_bottom, element_width, element_height]);

%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.5;
removeDrift_button = uicontrol('Parent',conditionParametersGroup,...
                        'Style','checkbox','FontSize',font_size,...
                        'String','Drift',...
                        'Units','normalized',...
                        'Position',[pos_left, pos_bottom, element_width, element_height],...
                        'Callback',{@removeDrift_button_callback});

pos_left = 0.5;
element_width = 1 - pos_left;                      
drift_popup = uicontrol('Parent',conditionParametersGroup,...
                        'Style','popupmenu','FontSize',font_size_small,...
                        'Enable','off',...
                        'String',{'polynomial', 'asLS'},...
                        'Units','normalized',...
                        'Position',[pos_left, pos_bottom, element_width, element_height_small],...
                        'Callback',@drift_popup_callback);                      
                    
%%
pos_bottom = pos_bottom - element_height_small;
pos_left = 0;
element_width = 0.3;
asym_param_label = uicontrol('Parent',conditionParametersGroup, ...
                            'Style','text',...
                            'FontSize',font_size_small,...
                            'String','asymmetry',...
                            'HorizontalAlignment','right',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height_small]);  
                        
pos_left = element_width;
element_width = 0.5 - pos_left;
asym_param_edit = uicontrol('Parent',conditionParametersGroup,...
                         'Style','edit',...
                         'Enable','off',...
                         'FontSize',font_size_small,...
                         'String','0.05',...
                         'Units','normalized',...
                         'Position',[pos_left, pos_bottom, element_width, element_height_small],...
                         'Callback', @asym_param_edit_callback);
                     
pos_left = 0.5;
element_width = 0.25;
first_drift_param_label = uicontrol('Parent',conditionParametersGroup, ...
                            'Style','text',...
                            'FontSize',font_size_small,...
                            'String','order',...
                            'HorizontalAlignment','right',...
                            'Units','normalized',...
                            'Position',[pos_left, pos_bottom, element_width, element_height_small]); 
                        
pos_left = pos_left + element_width;
element_width = 1 - pos_left;
first_drift_param_height = element_height;
first_drift_param_edit = uicontrol('Parent',conditionParametersGroup,...
                         'Style','edit',...
                         'FontSize',font_size_small,...
                         'Enable','off',...
                         'String','1',...
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
                            'HorizontalAlignment','right',...
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
ensembleAverageFull_button = uicontrol('Parent',conditionParametersGroup,...
                                       'Style','checkbox','FontSize',font_size,...
                                       'String','Full Ensemble Averaging',...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height],...
                                       'Callback',{@ensembleAverageFull_button_callback});
                                   
%%  
pos_bottom = pos_bottom - element_height_small;
pos_left = 0;
element_width = 0.75;
ensembleAverageFull_label = uicontrol('Parent',conditionParametersGroup, ...
                                      'Style','text',...
                                      'FontSize',font_size_small,...
                                      'String','period (s)',...
                                      'HorizontalAlignment','right',...
                                      'Units','normalized',...
                                      'Position',[pos_left, pos_bottom, element_width, element_height_small]); 

pos_left = pos_left + element_width;
element_width = 1 - pos_left;
ensembleAverageFull_edit = uicontrol('Parent',conditionParametersGroup,...
                                     'Style','edit',...
                                     'FontSize',font_size_small,...
                                     'Enable','off',...
                                     'String','1.0',...
                                     'Units','normalized',...
                                     'Position',[pos_left, pos_bottom, element_width, element_height_small]);                      
%%
pos_left = 0;
pos_bottom = pos_bottom - element_height;
element_width = 0.5;
inverse_button = uicontrol('Parent',conditionParametersGroup,...
                           'Style','checkbox',...
                           'FontSize',font_size,...
                           'String','Inverse',...
                           'Units','normalized',...
                           'Position',[pos_left, pos_bottom, element_width, element_height]);

pos_left = pos_left + element_width;
element_width = 1 - pos_left;
norm_button  = uicontrol('Parent',conditionParametersGroup,...
                         'Style','checkbox',...
                         'FontSize',font_size,...
                         'String','Normalize',...
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

    function brush_checkbox_callback(src,~)
        handles.drawBrush = get(brush_checkbox,'Value');
        drawFrame(handles.frame ,handles.activeScreenNo, handles);
    end

    function removeBG_callback(hObject,~)
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
        
        state = get(removeBG_button,'Value');
        
        if state == 1
            set(brush_checkbox,'Enable','on');
            set(bg_thresh_slider,'Enable','on');
            set(removeIslandsCheckbox,'Enable','on');
            set(perc_ex_edit,'Enable','on');
            set(fillHoles_checkbox,'Enable','on');
            set(download_button,'Enable','on');
            set(upload_button,'Enable','on');
            brush_checkbox_callback();
            set(polygon_mask_button,'Enable','on');
        else
            set(brush_checkbox,'Enable','off');
            set(bg_thresh_slider,'Enable','off');
            set(removeIslandsCheckbox,'Enable','off');
            set(perc_ex_edit,'Enable','off');
            set(fillHoles_checkbox,'Enable','off');  
            set(download_button,'Enable','off');
            set(upload_button,'Enable','off');
            handles.drawBrush = 0;
            set(polygon_mask_button,'Enable','off');
        end
    end


    function upload_button_callback(source,~)
        [filename, path] = uigetfile('*.txt', 'Load mask', handles.dir);
        if ~isequal(filename, 0)
            mask = load(strcat(path,filename));
            mask = logical(mask);
            handles.activeCamData.finalSegmentation = mask;
            drawFrame(handles.frame ,handles.activeScreenNo, handles);
        end
    end


    function download_button_callback(source,~)
        filename_default = strcat(handles.dir,'/mask.txt');
        [filename, path] = uiputfile('*.txt', 'Save mask', filename_default);
        if ~isequal(filename, 0)
            mask = double(handles.activeCamData.finalSegmentation);
            save(strcat(path,filename), 'mask', '-ascii', '-tabs');
        end
    end


    function polygon_mask_button_callback(source,~)
        [x, y] = getpts(handles.activeCamData.screen);
        poly_indices = convhull(x, y);
        mask = poly2mask(x(poly_indices), y(poly_indices),...
                         size(handles.activeCamData.cmosData, 1),...
                         size(handles.activeCamData.cmosData, 2));
        handles.activeCamData.finalSegmentation = mask;
        drawFrame(handles.frame ,handles.activeScreenNo, handles);
    end


    function bin_button_callback(source,~)
        
        state = get(bin_button,'Value');
        
        if state == 1
            set(kernel_popup,'Enable','on');
            set(kernel_size_edit,'Enable','on');
        else
            set(kernel_popup,'Enable','off');   
            set(kernel_size_edit,'Enable','off');                        
        end
    end


    function filt_button_callback(source,~)
        
        state = get(filt_button,'Value');
        
        if state == 1
            set(filt_popup,'Enable','on');
        else
            set(filt_popup,'Enable','off');     
        end
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


    function removeDrift_button_callback(source,~)
        
        drift_state = get(removeDrift_button,'Value');
        
        if drift_state == 1
            set(drift_popup,'Enable','on');
            set(first_drift_param_edit,'Enable','on');
            drift_popup_callback();
        else
            set(drift_popup,'Enable','off');
            set(first_drift_param_edit,'Enable','off');
            set(smooth_param_slider,'Enable','off');
            set(asym_param_edit,'Enable','off');
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
            set(first_drift_param_edit,'String','1');
            set(smooth_param_slider,'Enable','off');
            set(asym_param_edit,'Enable','off');
        elseif strcmp(method_name, 'asLS')
            set(first_drift_param_label,'String','iterations'); 
            set(first_drift_param_edit,'String','3');
            set(smooth_param_slider,'Enable','on');
            set(asym_param_edit,'Enable','on');
        end
    end


    function ensembleAverageFull_button_callback(source,~)
       
        state = get(ensembleAverageFull_button,'Value');
        
        if state == 1
            set(ensembleAverageFull_edit,'Enable','on');
        else
            set(ensembleAverageFull_edit,'Enable','off');     
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
        ensemble_state          = get(ensembleAverageFull_button,'Value');
        
        % Create variable for tracking conditioning progress
        trackProg = [removeBG_state,...
                     filt_state,...
                     filt_60hz_state,...
                     bin_state,...
                     drift_state,...
                     norm_state,...
                     inverse_state,...
                     ensemble_state];
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
        
        maxFrame = size(handles.activeCamData.cmosRawData, 3);
        handles.activeCamData.maxFrame = maxFrame;
        handles.maxFrame = maxFrame;
        
        mask = handles.activeCamData.finalSegmentation;
        if handles.drawSegmentation == 0
            mask = ones(size(mask));
        end
        
        %% Remove Background
        if removeBG_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg,g1,'Removing Background');
            handles.activeCamData.cmosData =...
                handles.activeCamData.cmosData.* repmat(mask,...
                   [1 1 size(handles.activeCamData.cmosData, 3)]);
                   
          set(removeBG_button,'Value',0);
          removeBGcheckbox_callback(hObject);
          handles.drawSegmentation = 0;  
          handles.drawBrush = 0;              
        end
        
        %% Bin Data
        if bin_state == 1
            % Update counter % progress bar
            counter = counter + 1;
            waitbar(counter/trackProg, g1, 'Binning Data');
            
            bin_pop_state = get(kernel_popup,'Value');
            kernel_name_list = get(kernel_popup, 'String');
            kernel_name = kernel_name_list{bin_pop_state};
            
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
        
        %% Full Ensemble Average
        if ensemble_state == 1
           counter = counter + 1;
           waitbar(counter/trackProg,g1,'Full Ensemble Average');
           CL = str2double(get(ensembleAverageFull_edit, 'String'));
           handles.activeCamData.cmosData = ensembleAverageFull(handles.activeCamData.cmosData,...
                                                                CL, handles.activeCamData.Fs);
                             
           maxFrame = size(handles.activeCamData.cmosData, 3);                                                  
           handles.maxFrame = maxFrame;                                                 
           handles.activeCamData.maxFrame = maxFrame;                                                
        end
            

        %% Inverse Data
        if inverse_state == 1
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
            drawFrame(currentframe, handles.activeScreenNo, handles);
            redrawWaveScreens(handles);
            if handles.normflag ~= 0
                caxis([0 1])
            end
            hold on
            set(handles.activeScreen,'YTick',[],'XTick',[]);% Hide tick markes
        end
        
    end
guidata(conditionParametersGroup, handles);
end
