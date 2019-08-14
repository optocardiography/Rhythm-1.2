function [data] = remove_Drift(data, mask, method_name, method_params)
%% Temporal drift removal from data with given method
 
% INPUTS
% data = cmos data (voltage, calcium, etc.) from the micam ultima system.
% method_name = 'polynomial' or 'least squares'
% method_params = vector of params for method to unpack

% OUTPUT
% data = data with removed drift

% METHOD
% . . .

% REFERENCES
% V.S. Chouhan, S.S. Mehta. Total Removal of Baseline Drift from ECG Signal.
% Proceedings of the International Conference on Computing: Theory and Applications (ICCTA'07)
% TODO

% ADDITIONAL NOTES
% This code is a bit sluggish.  To improve efficiency, I use the effects of
% remove_BKGRD to my advantage and only try to remove drift from pixels
% still containing signal (non-zero pixels). At some point, I hope Matlab
% comes up with a parallel solution for polyfit.

% RELEASE VERSION 1.0.0

% AUTHOR: Jacob Laughner (jacoblaughner@gmail.com)

% Email optocardiography@gmail.com for any questions or concerns.
% Refer to efimovlab.org for more information.

%%
switch method_name
    
    case 'polynomial'

        poly_order = method_params(1);
        data_slice_size = size(data(1, 1, :));
        time_linspace = 1 : size(data,3);
        time_linspace = reshape(time_linspace, data_slice_size);

        for i = 1 : size(data, 1)
            for j = 1 : size(data, 2)
                data_slice = data(i, j, :);
                if mask(i, j) ~= 0
                    [p, s, mu] = polyfit(time_linspace, data_slice, poly_order);
                    baseline = polyval(p, time_linspace, s, mu);
                    data(i, j, :) = data_slice - reshape(baseline, data_slice_size);
                end
            end
        end
        
    case 'asLS'

        smoothness_param = method_params(1);
        asym_param = method_params(2);
        n_iter = method_params(3);

        data_slice_size = size(data(1, 1, :));

        for i = 1 : size(data, 1)
            for j = 1 : size(data, 2)
                data_slice = data(i, j, :);
                if mask(i, j) ~= 0
                    baseline = asLS_baseline(data_slice, smoothness_param, asym_param, n_iter);
                    data(i, j, :) = data_slice - reshape(baseline, data_slice_size);
                end
            end
        end
end
