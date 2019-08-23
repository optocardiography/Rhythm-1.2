function data_averaged = ensembleAverageFull(data, CL, Fs)
    % data - array
    % CL - cycle length (sec)
    % Fs - sampling frequency (Hz)
    
    [Y, X, T] = size(data);
    
    m = CL * Fs;                    % number of points in one cycle
    n = floor(T / m);               % number of whole cycles
    tail_length = T - n * m;        % length of tail
    
    data_averaged = zeros(X, Y, m);
    
    for i = 1:n
        i_start = (i-1) * m + 1;
        i_end = i * m;
        data_averaged = data_averaged + data(:, :, i_start : i_end);
    end
    
    i = n + 1;
    i_start = (i-1) * m + 1;
    i_end = T;
    
    data_averaged(:, :, 1 : tail_length) = data_averaged(:, :, 1 : tail_length) + data(:, :, i_start : i_end);
    
    data_averaged(:, :, 1 : tail_length) = data_averaged(:, :, 1 : tail_length) / (n + 1);
    data_averaged(:, :, tail_length+1 : end) = data_averaged(:, :, tail_length+1 : end) / n;
   
end