function [ output_table ]  = APExport(handles)
    markers = handles.activeCamData.markers;
    [markersCount,~] = size(markers);
    output = zeros(handles.maxFrame, markersCount+1);
    output(:,1) = handles.time(1:handles.maxFrame)';
    variableNames = "t";
    for i = 1:markersCount
        output(:,i+1) = squeeze(handles.activeCamData.cmosData(markers(i,2), markers(i,1), :));
        variableNames = variableNames + " m" + num2str(i);
    end
    output_table = array2table(output,'VariableNames',cellstr(strsplit(variableNames)));
end