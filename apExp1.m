function apExp1(handles)
    markerpos = handles.activeCamData.markers(1,:);
    AP = [handles.time(:), squeeze(handles.activeCamData.cmosData(markerpos(2), markerpos(1), :))];
    
    [filename, path] = uiputfile('waveforms.txt');
    dlmwrite(strcat(path,filename), AP,'\t');
end