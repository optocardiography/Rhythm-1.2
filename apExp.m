%handles - rhythm handles
%AP[maxFrame][2] - time and AP value
%msPerFrame - ms per frame
function apExp(handles, pacingCL, truncateAfter)
    offset = 20;
    markerpos = handles.activeCamData.markers(1,:);
    maxFrame = handles.activeCamData.maxFrame;
    msPerFrame = handles.time(maxFrame)/(maxFrame-1)*1000;
    AP = [handles.time(:), squeeze(handles.activeCamData.cmosData(markerpos(2), markerpos(1), :))];
    deriv = [AP(1:size(AP,1)-1, 1),diff(AP(:,2))];
    %finding the first derivative peak
    [~,first] = max(deriv(1:round(pacingCL/msPerFrame), 2));
    %creating array for all the depolarization points
    depol = zeros(1);
    depol(1) = first;
    %finding depolarization points of APs that have all phases present in
    %data

    f = (maxFrame-first)/(pacingCL/msPerFrame);
    if rem(maxFrame-first, pacingCL/msPerFrame) > truncateAfter
        for i=2:ceil(f)
            depol(i) = depol(i-1) + pacingCL/msPerFrame; 
        end
    else
        for i=2:fix(f)
             depol(i) = depol(i-1) + pacingCL/msPerFrame; 
        end
    end

    %while((first + (i)*period/msPerFrame) <= maxFrame)
        %%startPoint = depol(i-1)+range;
        %%endPoint = depol(i-1)+range+offset;
        %%[~, depol(i)] = max(deriv(startPoint:endPoint,2));
        %depol(i) = depol(i-1) + period;
        %i = i + 1;
    %end

    depolCount = length(depol);
    %check if there is a resting phase in data before the 1st AP;
    %if not, it is not used in final calculation
    if(first < round(offset/msPerFrame))
        startFrom = 2;
    else
        startFrom = 1;
    end

    %calculate average AP

    %avgAPsize = round(period/msPerFrame);
    avgAPsize = round(truncateAfter/msPerFrame);
    avgAP = zeros(avgAPsize,2);
    AP_output = zeros(avgAPsize, depolCount+1);
    AP_output(:,1) = handles.time(1:avgAPsize);

    j = 1;
    for j = 1:avgAPsize
        tmp_sum = 0;
        for i = startFrom:depolCount
            AP_output(j,i+1) = AP(depol(i) - round(offset/msPerFrame) + j - 1,2);
            tmp_sum = tmp_sum + AP_output(j,i+1);
        end
        avgAP(j,2) = tmp_sum / (depolCount - startFrom + 1);
    end
    avgAP(:,1) = handles.time(1:avgAPsize);
    [filename, path] = uiputfile('ensembleAverage.txt');
    dlmwrite(strcat(path,filename), avgAP,'\t');
end
