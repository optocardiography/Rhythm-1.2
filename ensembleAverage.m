function [ output_table ]  = ensembleAverage(handles, pacingCL_t, truncateAfter_t, startingTime_t)
    Fs = handles.activeCamData.Fs;
    pacingCL = pacingCL_t*Fs/1000;
    truncateAfter = truncateAfter_t*Fs/1000;
    startingFrame = 1 + startingTime_t*Fs/1000;
    
    output_length = min(min(pacingCL, truncateAfter + 1), handles.maxFrame);
    
    APcount = floor((handles.maxFrame - startingFrame + pacingCL - output_length) / pacingCL);
    
    markers = handles.activeCamData.markers;
    [markersCount,~] = size(markers);
    output = zeros(output_length, 1 + markersCount*(APcount + 1));
    output(:,1) = handles.time(1:output_length)';
    APs = zeros(output_length, APcount);
    variableNames = "t";
    for i = 1:markersCount
        AP = squeeze(handles.activeCamData.cmosData(markers(i,2), markers(i,1), :));
        for j = 1:APcount
            variableNames = variableNames + " m" + num2str(i) + "ap" + num2str(j) + " ";
            APs(:,j) = AP(startingFrame + (j-1)*pacingCL : startingFrame + (j-1)*pacingCL + output_length - 1);
        end
        avgAP = sum(APs, 2)/APcount;
        filledColumnsCount = 1 + (APcount + 1)*(i-1);
        output(:,filledColumnsCount + 1 : filledColumnsCount + APcount) = APs(:, :);
        variableNames = variableNames + " m" + num2str(i) + "avg";
        output(:,filledColumnsCount + APcount + 1) = avgAP;
    end
    output_table = array2table(output, 'VariableNames', cellstr(strsplit(variableNames)));

end