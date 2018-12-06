function [feature_matrix] = bfeature_extraction_BCI(filt_ham_data,nb_features,filt,init_method)

feature_matrix = zeros(1,nb_features); %this is the matrix that we'll feed
%to the SVM classifier
%First we need to band-pass filter our data according to the frequencies
%in SIGMAbox to apply the feature extraction functions
% DELTA = 0.1 - 4 Hz
data_delta = filter(filt(1),filt_ham_data);
% THETA = 4 - 7 Hz
data_theta = filter(filt(2),filt_ham_data);
% BETA = 16 - 31 Hz
data_beta = filter(filt(4),filt_ham_data);

zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0);

feature_matrix(1,1) = fc_fractal_dimension(data_theta(17,:));
feature_matrix(1,2) = fc_fractal_dimension(data_beta(13,:));
feature_matrix(1,3) = kurtosis(abs(hilbert(data_beta(7,:))).^2);
feature_matrix(1,4) = kurtosis(data_beta(8,:));
feature_matrix(1,5) = length(find(diff(data_theta(16,:))<init_method(8).epsilon));
feature_matrix(1,6) = length(zci(data_beta(11,:)));
feature_matrix(1,7) = kurtosis(data_delta(18,:));
feature_matrix(1,8) = length(zci(data_beta(15,:)))/ length(data_beta(15,:));
feature_matrix(1,9) = length(find(diff(data_delta(12,:))<init_method(8).epsilon));
