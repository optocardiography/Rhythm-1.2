function [data] = binning(data, kernel_size, kernel_name)
%% Spatial filtration of data with given kernel

% INPUTS
% data = cmos data with structure N * M * time
% kernel_size = size of the window to convolve with data
% kernel_name = "uniform" or "gaussian" 

% OUTPUT 
% [data] = binned data

% AUTHOR
% Pikunov Andrey - pikunov@phystech.edu

% Email optocardiography@gmail.com for any questions or concerns.
% Refer to efimovlab.org for more information.


%% Implementation
switch kernel_name
    case 'uniform'
        kernel = ones(kernel_size, kernel_size) / kernel_size^2;
        for i = 1 : size(data, 3)
            data(:, :, i) = conv2(data(:, :, i), kernel, 'same');
        end
    case 'gaussian'
        sigma = kernel_size / (3 * 2); % so we put 3 sigma inside the window
        for i = 1 : size(data, 3)
            data(:, :, i) = imgaussfilt(data(:, :, i), sigma);
        end
end
