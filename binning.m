function [data_binned] = binning(data, mask, kernel_size, kernel_name)
%% Spatial filtration of data with given kernel

% INPUTS
% data = cmos data with structure N * M * time
% mask = mask to avoid BG pixels 
% kernel_size = size of the window to convolve with data (odd integer)
% kernel_name = "uniform" or "gaussian" 

% OUTPUT 
% [data_binned] = binned data

% AUTHOR
% Pikunov Andrey - pikunov@phystech.edu

% Email optocardiography@gmail.com for any questions or concerns.
% Refer to efimovlab.org for more information.

%profile on;

switch kernel_name
    case 'uniform'
        kernel = ones(kernel_size, kernel_size) / kernel_size^2;
    case 'gaussian'
        sigma = kernel_size / (2 * 2); % so we put 2 sigma inside the window
        kernel = kernel_gaussian(kernel_size, sigma, 0);
end

N = size(data, 1); % for y loop
M = size(data, 2); % for x loop
T = size(data, 3); % for time loop

data_binned = zeros(size(data));

kernel_size_half = floor(kernel_size / 2);

tic;

for y = 1 : N
    for x = 1 : M
        
        if mask(y, x) == 1
            
            range_x = [x - kernel_size_half, x + kernel_size_half];
            range_y = [y - kernel_size_half, y + kernel_size_half];
            
            left_margin = 0;
            right_margin = 0;
            up_margin = 0;
            bottom_margin = 0;
            
            if range_x(1) < 1
                left_margin = abs(1 - range_x(1));
            end
            if range_x(2) > M
                right_margin = abs(M - range_x(2));
            end
            if range_y(1) < 1
                up_margin = abs(1 - range_y(1));
            end
            if range_y(2) > N
                bottom_margin = abs(N - range_y(2));
            end
            
            mask_window = mask(range_y(1) + up_margin : range_y(2) - bottom_margin,...
                               range_x(1) + left_margin : range_x(2) - right_margin);
            
            mask_window = create_fake_borders(mask_window, left_margin,...
                                              right_margin,...
                                              up_margin,...
                                              bottom_margin);      
            
            kernel_current = kernel .* mask_window;
            kernel_current = kernel_current(1 + up_margin : end - bottom_margin,...
                                            1 + left_margin : end - right_margin);   
            kernel_current = kernel_current / sum(sum(kernel_current)); % renormalizing        
            kernel_current = repmat(kernel_current, 1, 1, T);
            %for t = 1 : T
                
                data_window = data(range_y(1) + up_margin : range_y(2) - bottom_margin,...
                                   range_x(1) + left_margin : range_x(2) - right_margin,...
                                   :);

                data_binned(y, x, :) = sum(sum(data_window .* kernel_current));

            %end
        end
    end
    
end

%disp('time binning (min) = ');
%disp(toc / 60);

end


function A = create_fake_borders(matrix, left_margin,...
                                          right_margin,...
                                          up_margin,...
                                          bottom_margin)
                                      
    n = size(matrix, 1);
    m = size(matrix, 2);
    
    A = zeros(n + up_margin + bottom_margin,...
              m + left_margin + right_margin);
    
    up = 1 + up_margin;
    bottom = up_margin + n;
    left = 1 + left_margin;
    right = left_margin + m;
    
    A(up : bottom, left : right) = matrix;      
    
end


function kernel = kernel_gaussian(kernel_size, sigma, mu)
% returns gaussian square kernel
    
    kernel = zeros(kernel_size, kernel_size);

    i_center = kernel_size / 2 + 0.5;
    j_center = i_center;
    
    i_center_int = round(kernel_size / 2);
    j_center_int = round(kernel_size / 2);
    
    for i = i_center_int : kernel_size
        for j = j_center_int : kernel_size
            r = [i - i_center, j - j_center];
            r_norm = norm(r);
            kernel_element = exp(-(r_norm - mu)^2 / (2 * sigma^2));
            
            kernel(i, j) = kernel_element;
            kernel((kernel_size + 1) - i, j) = kernel_element;
            kernel(i, (kernel_size + 1) - j) = kernel_element;
            kernel((kernel_size + 1) - i, (kernel_size + 1) - j) = kernel_element;
        end
    end
    
    kernel = kernel / sum(sum(kernel));
    
end
