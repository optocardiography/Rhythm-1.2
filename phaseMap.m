function phase = phaseMap(data,starttime,endtime,Fs,cmap)
%% Hilbert Transform Generated Phase Map
%
% INPUTS
% data = cmos data
% starttime = start time of viewing window
% endtime = end time of viewing window
% Fs = sampling frequency
% cmap = colormap (inverted/not inverted)
%
% OUTPUT
% A figure that has a color repersentation for phase
%
% REFERENCES
% None
%
% ADDITIONAL NOTES
% None
%
% RELEASE VERSION: 2014b v1.0
%
% AUTHOR: Jake Laughner
%
%
% MODIFICATION LOG:
% February 12, 2015 - I restructured the code to first calculate phase,
% then request a directory and filename for the video, and finally to step
% through the phase images capturing them as a video. I also added a
% progress bar.
%
% Email optocardiography@gmail.com for any questions or concerns.
% Refer to efimovlab.org for more information.



%% Code %%
% Calculate Hilbert Transform
if size(data,3) == 1
    data = data(:,round(starttime*Fs+1):round(endtime*Fs+1));
    temp = reshape(data,[],size(data,2)) - repmat(mean(reshape(data,[],size(data,2)),2),[1 size(data,2)]);
    hdata = hilbert(temp');
    phase = -1*angle(hdata)';
else
    data = data(:,:,round(starttime*Fs+1):round(endtime*Fs+1));
    temp = reshape(data,[],size(data,3)) - repmat(mean(reshape(data,[],size(data,3)),2),[1 size(data,3)]);
    hdata = hilbert(temp');
    phase = -1*angle(hdata)';
    phase = reshape(phase,size(data,1),size(data,2),[]);
% % %     % Choose location to save file and name of file
% % %     dir = uigetdir;
% % %     % If the cancel button is selected cancel the function
% % %     if dir == 0
% % %         return
% % %     end
% % %     % Request the desired name for the movie file
% % %     filename = inputdlg('Enter Filename:');
% % %     filename = char(filename);
% % %     % Check to make sure a value was entered
% % %     if isempty(filename)
% % %         error = 'A filename must be entered! Function cancelled.';
% % %         msgbox(error,'Incorrect Input','Error');
% % %         return
% % %     end
% % %     % Convert filename to a character string
% % %     filename = char(filename);
% % %     % Create path to file
% % %     movname = [dir,'/',filename,'.avi'];
% % %     
% % %     % Capture video fo the Hilbert Transform represented phase over window
% % %     fig = figure('Name',filename,'Visible','off');
% % %     pa = axes;
% % %     vidObj = VideoWriter(movname,'Motion JPEG AVI');
% % %     open(vidObj);
% % %     movegui(fig,'center')
% % %     set(fig,'Visible','on');
% % %     % Create progress bar
% % %     gg = waitbar(0,'Producing Phase Map','Visible','off');
% % %     tmp = get(gg,'Position');
% % %     set(gg,'Position',[tmp(1) tmp(2)/4 tmp(3) tmp(4)],'Visible','on')
% % %     axes(pa)
% % %     for i = 1:size(data,3)
% % %         imagesc(phase(:,:,i),'Parent',pa);
% % %         colormap(fig,cmap)
% % %         colorbar(pa)
% % %         caxis(pa,[-pi pi])
% % %         axis(pa,'image')
% % %         axis(pa,'off')
% % %         pause(.05)
% % %         F = getframe(fig);
% % %         writeVideo(vidObj,F);% Write each frame to the file.
% % %         % Update progress bar
% % %         waitbar(i/size(data,3))
% % %     end
% % %     close(gg)
% % %     close(fig)
% % %     close(vidObj) % Close the file.
end
end