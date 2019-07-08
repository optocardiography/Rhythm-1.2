
function redrawWaveScreens(handles)
if handles.bounds(handles.activeScreenNo) == 0
    visualizeWaveScreens(0, handles); % ����� ��� � GUI_conditionParameters
    for i_cam=1:5
        cla(handles.signalScreens(i_cam));
    end
    M = handles.activeCamData.markers; [a,~]=size(M);
    hold on
    for x=1:a
        if handles.activeCamData.drawPhase == 0
            signal_current = squeeze(handles.activeCamData.cmosData(M(x,2),M(x,1),:));
        else
            signal_current = squeeze(handles.activeCamData.cmosPhase(M(x,2),M(x,1),:));
        end
        plot(handles.time(1:handles.activeCamData.maxFrame),...
            signal_current,...
            handles.markerColors(x),'LineWidth',2,'Parent',handles.signalScreens(x));
        set(handles.activeScreen,'YTick',[],'XTick',[]);% Hide tick markes
    end
    hold off
elseif handles.bounds(handles.activeScreenNo) == 1
    % draw signal screens for the screen group 1
    visualizeWaveScreens(1, handles); % ����� ��� � GUI_conditionParameters
    for i_marker=1:5
        for i_cam = 1:4
            cla(handles.signalGroup(i_marker).signalScreen(i_cam));
        end
    end
    
    M = handles.markers1;
    msize = size(handles.markers1,1);
    hold on
    for i_marker=1:msize
        for i_cam = 1:4
            if (handles.allCamData(i_cam).isloaded && handles.bounds(i_cam) == 1)
                if handles.activeCamData.drawPhase == 0
                    signal_current = squeeze(handles.allCamData(i_cam).cmosData(M(i_marker,2),M(i_marker,1),:));
                else
                    signal_current = squeeze(handles.allCamData(i_cam).cmosPhase(M(i_marker,2),M(i_marker,1),:));
                end
                plot(handles.time(1:handles.allCamData(i_cam).maxFrame),...
                    signal_current,...
                    handles.markerColors(i_marker),'LineWidth',2,...
                    'Parent',handles.signalGroup(i_marker).signalScreen(i_cam))
            end
        end
    end
    hold off
elseif handles.bounds(handles.activeScreenNo) == 2
    visualizeWaveScreens(1, handles); %����� ��� � GUI_conditionParameters
    % draw signal screens for the screen group 2
    for i_marker=1:5
        for i_cam = 1:4
            cla(handles.signalGroup(i_marker).signalScreen(i_cam));
        end
    end
    
    M = handles.markers2;
    msize = size(handles.markers2,1);
    hold on
    for i_marker=1:msize
        for i_cam = 1:4
            if (handles.allCamData(i_cam).isloaded && handles.bounds(i_cam) == 2)
                if handles.activeCamData.drawPhase == 0
                    signal_current = squeeze(handles.allCamData(i_cam).cmosData(M(i_marker,2),M(i_marker,1),:));
                else
                    signal_current = squeeze(handles.allCamData(i_cam).cmosPhase(M(i_marker,2),M(i_marker,1),:));
                end
                plot(handles.time(1:handles.allCamData(i_cam).maxFrame),...
                    signal_current,...
                    handles.markerColors(i_marker),'LineWidth',2,...
                    'Parent',handles.signalGroup(i_marker).signalScreen(i_cam))
            end
        end
    end
    hold off
end
set(handles.activeScreen,'YTick',[],'XTick',[]);% Hide tick markes
end

function visualizeWaveScreens(sync, handles)
if (sync)
    set([handles.signalPanel, handles.signalSlider], 'Visible','on');
    for i=1:5
        set(handles.signalScreens(i),'Visible','off');
    end
    % sync all screen signals and markers
    %    movieslider_callback(handles.movie_slider);
else
    % unbound all screens
    
    set([handles.signalPanel, handles.signalSlider, ], 'Visible','off');
    for i=1:5
        set(handles.signalScreens(i),'Visible','on');
    end
end
%     anyLoads = 0;
%     for i_cam=1:4
%         if handles.allCamData(i_cam).isloaded
%             anyLoads = 1;
%             break;
%         end
%     end
%     if anyLoads
%        movieslider_callback(movie_slider);
%     end
end