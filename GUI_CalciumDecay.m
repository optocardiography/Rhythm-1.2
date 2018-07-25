% GUI for Calcium Decay Analysis
% Inputs: 
% CalciumDecayGroup -- pannel to draw on
% handles           -- rhythm handles
% f                 -- figure of the main rhythm window
% 
% by Roman Pryamonosov, Roman Syunyaev, and Alexander Zolotarev
function GUI_CalciumDecay(CalciumDecayGroup, handles, f)

starttimecalc_text = uicontrol('Parent',CalciumDecayGroup, ...
                                       'Style','text','FontSize',10, ...
                                       'String','Start Time',...
                                       'Units','normalized',...
                                       'Position',[.01 .9 .6 .09]);
starttimecalc_edit = uicontrol('Parent',CalciumDecayGroup,...
                                       'Style','edit','FontSize',10, ... 
                                       'Units','normalized',...
                                       'Position',[0.62 0.9 .25 .09],...
                                       'Callback',@startTime_callback);
endtimecalc_text   = uicontrol('Parent',CalciumDecayGroup, ...
                                       'Style','text','FontSize',10,...
                                       'String','End Time',...
                                       'Units','normalized',...
                                       'Position',[.01 .8 .6 .09]);
endtimecalc_edit   = uicontrol('Parent',CalciumDecayGroup,...
                                       'Style','edit','FontSize',10,...
                                       'Units','normalized',...
                                       'Position',[.62 .8 .25 .09],...
                                       'Callback',@endTime_callback);
percentsplit_text= uicontrol('Parent',CalciumDecayGroup,'Style','text',...
                                'FontSize',10,'String','% Split',...
                                'Units','normalized',...
                                'Position',[.01 .7 .4 .09]);
percentsplit_edit= uicontrol('Parent',CalciumDecayGroup,'Style','edit',...
                                'FontSize',10,'String','80',...
                                'Units','normalized',...
                                'Position',[.42 .7 .25 .09]);
                               
calculateTau=uicontrol('Parent',CalciumDecayGroup,'Style','pushbutton',...
                                        'FontSize',10,'String','Calculate Tau',...
                                        'Units','normalized',...
                                        'Position',[.01 .1 .7 .15],...
                                        'Callback',{@calcTau_callback});
export_icon = imread('icon.png');
export_icon = imresize(export_icon, [20, 20]);
export_button = uicontrol('Parent',CalciumDecayGroup,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[0.75, 0.1, 0.15, 0.15]...
                        ,'Callback',{@export_button_callback});                                  
set(export_button,'CData',export_icon) 
set(starttimecalc_edit, 'String', '0.75');
set(endtimecalc_edit, 'String', '1.85');
startTime_callback(starttimecalc_edit);

%% Callback functions
function startTime_callback(source,~)
        val_start = str2double(get(source,'String'));
        val_end = str2double(get(endtimecalc_edit,'String'));
        if (val_start < 0)
            set(source,'String', 0);
            val_start = 0;
        end
        if (val_start >= val_end)
            set(source,'String', num2str(val_start));
            val_start = val_end;
            val_end = val_start+0.01;
            set(endtimecalc_edit,'String', num2str(val_end));
            set(source,'String', num2str(val_start));
        end
        drawTimeLines(val_start, val_end, handles, f);
    end

    function endTime_callback(source,~)
        val_start = str2double(get(starttimecalc_edit,'String'));
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

function calcTau_callback(~,~)
    Fs = handles.activeCamData.Fs;
    bg = handles.activeCamData.bg;
    %Get input variables
    CTstart = str2double(get(starttimecalc_edit,'String'));
    CTend = str2double(get(endtimecalc_edit,'String'));
    
    drawTimeLines(CTstart, CTend, handles, f);
    
    CTstart=round(CTstart*Fs);
    CTend=round(CTend*Fs);
    PercentSplit = (str2double(get(percentsplit_edit,'String')))/100;
    cmosData = handles.activeCamData.cmosData;
    rect = getrect(handles.activeScreen);
    rect=round(rect);
    temp = cmosData(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),CTstart:CTend);
    Tau2=[];
    R=[];
    
    % Grab selected portion of trace and smooth it
    for i = 1:size(temp,1)
        for j = 1:size(temp,2)
            newtemp = temp(i,j,:);     % make transients positive
            tempmin = min(temp(i,j,:));        % remove baseline drift
            newtemp1 = newtemp - tempmin;
            Enddiastolic = round(median(newtemp(end-25:end)));
            DV = Enddiastolic - tempmin;
            newtemp1 = newtemp1 - DV;
            CT = conv2(newtemp1(1,:),1/31*ones(1,31),'same');   %SOBC changed newtemp1 to newtemp1(1,:)     %2D convolution to smooth trace
            CT = CT - min(CT)+0.00001;
            
            % Determine Start and end of trace to be fitted
            [maxamp maxamptime] = max(CT);          % Determine peak time
            [firstamp firstamptime] = find(CT(maxamptime:end)<PercentSplit*maxamp);      %determine time of percent split amplitude
            [secondamp secondamptime] = find(CT(maxamptime:end)<0.20*maxamp);     % determine time of 20% amplitude
            
            if length(firstamptime)>1 
            firstamptime=firstamptime(1);
            end
            if length(secondamptime)>1
                secondamptime=secondamptime(1);
            end
            if length(maxamptime)>1
            maxamptime=maxamptime(1);
            end
            start = maxamptime+firstamptime;
            stop = maxamptime+secondamptime;
            
       

            CT = CT/max(CT)*100;        %Normalize
            
            % Fit the Polynomial and find goodness of fit
            if ~isempty(firstamptime) & start<length(CT) & ~isempty(secondamptime) & stop<length(CT)
               CTfit = polyfit([0:length(CT(start:stop))-1],log(CT(start:stop)),1);
               [j1,j2,j3,j4,R1] = regress(log(CT(start:stop))',[0:length(CT(start:stop))-1;ones(1,length(CT(start:stop)))]');
               R(i,j) = round(R1(1)*100);
               Tau2(i,j) = -1/CTfit(1);
              
              
            else
                R(i,j) = nan;
                Tau2(i,j) = nan;
            end
            
%             % Remove noisy data
%             if maxamp/std(newtemp(1:25))<1.5 | R(i,j)<40 | Tau2(i,j)>40
%                 R(i,j) = nan;
%                 Tau2(i,j) = nan;
%             end
            
            if i == 1 && j == 1
                %Plot Fit
                Lam = -1/Tau2(i,j);
                figure()
                plot(CT(start:stop));
                hold;
                plot(exp(Lam*[0:length(CT(start:stop))-1]+CTfit(2)),'r');
                axis tight
                hold off
            end
        end
    end
    %figure
    %plot(CT)
    %hold on 
    %plot(CTfit,'g')
    % Calculate average and Report statistics
    Tau_mean=nanmean(Tau2(:));
    Tau_std=nanstd(Tau2(:));
    Tau_median=nanmedian(Tau2(:));
    Tau_members = numel(Tau2(isfinite(Tau2)));
    
    %Create Masks to plot Tau2
    Mask=zeros(size(bg));
    Mask(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3))=1;
    Mask2=zeros(size(bg));
    Mask2(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3))=Tau2;
    %Set limits and Build Image
    handles.T_min = mean(Tau2(isfinite(Tau2))) - 2*Tau_std;
    handles.T_max = mean(Tau2(isfinite(Tau2))) + 2*Tau_std;

    G =real2rgb(bg, 'gray');
    J=real2rgb(Mask2,'jet',[handles.T_min handles.T_max]);
    A=real2rgb(Mask,'gray');
    I = J .* A + G .* (1-A);
    handles.activeCamData.saveData = I;
          
          %Plot Rise Time Map and Histogram
          cla(handles.activeCamData.screen);
          set(handles.activeCamData.screen,'YTick',[],'XTick',[]);
          imagesc( handles.activeCamData.screen,I)
          colormap(jet);
          axis(handles.activeCamData.screen,'off')
          %axis image;
          %set(gca,'XTick',[],'YTick',[],'Xlim',[0 size(cmosData,1)],'YLim',[0 size(cmosData,2)]);
    handles.activeCamData.drawMap = 1;
    % Output results
     handles.activeCamData.meanresults = sprintf('Mean: %0.3f',Tau_mean);
     handles.activeCamData.medianresults = sprintf('Median: %0.3f',Tau_median);
     handles.activeCamData.SDresults = sprintf('S.D.: %0.3f',Tau_std);
     handles.activeCamData.num_membersresults = sprintf('#Members: %d',Tau_members);
     handles.activeCamData.angleresults = sprintf('Angle:');
     
      set(handles.meanresults,'String',handles.activeCamData.meanresults);
      set(handles.medianresults,'String',handles.activeCamData.medianresults);
      set(handles.SDresults,'String',handles.activeCamData.SDresults);
      set(handles.num_members_results,'String',handles.activeCamData.num_membersresults);
      set(handles.angleresults,'String',handles.activeCamData.angleresults);

  
       
end
  %% Export picture from the screen
 function export_button_callback(~,~)  
       if isempty(handles.activeCamData.saveData)
           error = 'ExportedData must exist! Function cancelled.';
           msgbox(error,'Incorrect Input','Error');
           return
       else
        figure;
            image (handles.activeCamData.saveData);
        colormap jet;
        colorbar('Ticks',[0:0.2:5],'TickLabels', [handles.T_min:(handles.T_max-handles.T_min)/5:handles.T_max]);
        
       end
    end
end