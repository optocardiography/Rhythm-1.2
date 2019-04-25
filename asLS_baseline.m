function baseline = asLS_baseline(signal, smoothness_param, asym_param, n_iter)
% Baseline Correction with Asymmetric Least Squares Smoothing
% Paul H. C. EilersHans F.M. Boelens, October 21, 2005

% Explanation from the article:
%     Both have to be tuned to the data at hand.
%     We found that generally 0.001 < asym_param < 0.1 is a good choice (for a signal with positive peaks)
%     and 10^2 < smoothness_param < 10^9, but exceptions may occur.
%     In any case one should vary smoothness_param on a grid that is approximately linear for log(smoothness_param).
%     Often visualinspection is sufficient to get good parameter values.

signal_length = length(signal);
signal = signal(:);

penalty_vector = ones(signal_length, 1);

difference_matrix = diff(speye(signal_length), 2);

smoothness_matrix = smoothness_param*ones(1,size(difference_matrix,1));

for count = 1 : n_iter
    
    Weights = spdiags(penalty_vector, 0, signal_length, signal_length);
    
    C = chol(Weights + (smoothness_matrix .* difference_matrix') * difference_matrix);
    
    baseline = C \ (C' \ (penalty_vector .* signal));
    
    penalty_vector = (asym_param) .* (signal > baseline) + (1-asym_param) .* (signal < baseline);
end
