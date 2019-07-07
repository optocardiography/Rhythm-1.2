%% GUI for Alternance analysis
% Inputs:
% PhaseAnalysisGroup    -- pannel to draw on
% handles               -- rhythm handles
% f                     -- figure of the main rhythm window
%
% by Andrey Pikunov

function GUI_PhaseAnalysis(PhaseAnalysisGroup, handles, f)
handles.objectToDrawOn = PhaseAnalysisGroup;

font_size = 9;
pos_left = 0;
pos_bottom = 0;
element_width = 1;
element_height = 0.065;
transform_to_phase_button  = uicontrol('Parent',PhaseAnalysisGroup,...
                                       'Style','pushbutton',...
                                       'FontSize',font_size,...
                                       'String','Signal -> Phase',...
                                       'Units','normalized',...
                                       'Position',[pos_left, pos_bottom, element_width, element_height],...
                                       'Callback',@transform_to_phase_callback); 
                                   
    function transform_to_phase_callback(~,~)
        mask = handles.activeCamData.finalSegmentation;
        phase = transform_to_phase(handles.activeCamData.cmosData, mask);
        
        % for BG image drawing
        for i = 1 : size(phase, 1)
            for j = 1 : size(phase, 2)
                if mask(i, j) == 0
                    phase(i, j, :) = -(pi + 0.01) * ones(size(phase(i, j, :)));
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%

        handles.activeCamData.cmosData = phase;
        
        cla(handles.activeScreen);
        handles.matrixMax = pi;
        handles.normalizeMinVisible = -pi;
        currentframe = handles.frame;
        drawFrame(currentframe, handles.activeScreenNo, handles);
        redrawWaveScreens(handles);
        hold on
    end
end