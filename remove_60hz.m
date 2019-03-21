function filt_60hz_data = remove_60hz(data, Fs)
% Removing 60 Hz from cmos data using infinite impulse response band-stop filter.

% INPUTS
% data = cmos data

% OUTPUT
% filt_data = data without FIR 60 hz hum

% Email optocardiography@gmail.com for any questions or concerns.
% Refer to efimovlab.org for more information.



    b_iir = designfilt('bandstopiir','FilterOrder',4, ...
               'HalfPowerFrequency1',59.0,'HalfPowerFrequency2',61.0, ...
               'DesignMethod','butter','SampleRate',Fs);


    %% Apply Filter
    temp = reshape(data,[],size(data,3));
    filt_temp = zeros(size(temp));
    for i = 1:size(temp,1)
        if sum(temp(i,:)) ~= 0
            filt_temp(i,:) = filtfilt(b_iir, temp(i,:));
        end
    end

    filt_60hz_data = reshape(filt_temp,size(data,1),size(data,2),[]);
    
