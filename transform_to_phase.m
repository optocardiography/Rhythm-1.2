function [data] = transform_to_phase(data, mask)
%% Spatial filtration of data with given kernel

% INPUTS
% data = cmos data with structure N * M * time

% OUTPUT 
% [data] = phase data

% METHOD
% Phase is being calculated as an angle of hilbert transform of centered signal.

% AUTHOR
% Pikunov Andrey - pikunov@phystech.edu

% Email optocardiography@gmail.com for any questions or concerns.
% Refer to efimovlab.org for more information.

%% Implementation
for i = 1 : size(data, 1)
    for j = 1 : size(data, 2)
        data_slice = data(i, j, :);
        if mask(i, j) ~= 0 
            data_slice = make_centered(data_slice); 
            data_slice_hilbert = hilbert(data_slice);
            data(i, j, :) = angle(data_slice_hilbert);
        end
    end
end


function [v] = make_centered(v)
v = v - min(v);
v = v - max(v) / 2;
