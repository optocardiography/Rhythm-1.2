function [data] = remove_Drift(data, method_name, method_params)
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


%% Baseline Correction with Asymmetric Least SquaresSmoothing

switch method_name
    
    case 'polynomial'
        
        tempx = 1 : size(data,3);
        tempy = reshape(data, size(data, 1) * size(data, 2), []);
        ord = method_params;
        for i = 1 : size(data, 1) * size(data, 2)
            if sum(tempy(i, :)) ~= 0
            [p, s, mu] = polyfit(tempx,tempy(i, :), ord);
            y_poly = polyval(p, tempx, s, mu);
            tempy(i, :) = tempy(i, :) - y_poly;
            end
        end
        data = reshape(tempy, size(data, 1), size(data, 2), size(data, 3));
        
    case 'least squares'

        % TODO: move to GUI
        smoothness_param = 1e6;
        asym_param = .05;
        
        n_iter = method_params;

        data_slice_size = size(data(1, 1, :));

        for i = 1 : size(data, 1)
            for j = 1 : size(data, 2)
                data_slice = data(i, j, :);
                if any(data_slice ~= 0) % avoid masked pixels
                    baseline = asLS_baseline(data_slice, smoothness_param, asym_param, n_iter);
                    data(i, j, :) = data_slice - reshape(baseline, data_slice_size);
                end
            end
        end
end
