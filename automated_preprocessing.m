function [clean] = automated_preprocessing(raw_data,channel,fs,window_and_filt)
% This function will be implemented in the offline BCI
% to filter the data, apply a hamming window and test
% for the presence of artefacts. Indeed, while we did 
% use manual rejection to build our classifier, we 
% want to be snappy in the BCI. 
%
% We will use a threshold detection, a blocking detection, skewness and
% kurtosis.
%%%%%%%%%%
%
% INPUT % 
%
% raw_data     AN EPOCH of y points with x channels
%
% channel      the channel number to take (probably Fp1)
%
% fs           sampling rate
%
% w_and_f      1 if you want to BPF and apply hamming to your data, 0
%              otherwise
% 
% 
% OUTPUT %
%
% clean      0 if artifact, 1 if clean
%
% data       data that went through the BPF and the Hamming window
%
%%%%%%%%%%


[~,y] = size(raw_data);
clean = 1; 

% BLOCKING DETECTION
window = 7 * 1e-3; %ms
points = window * fs; 

N = round(y/points);
for w_nb = 1:N
    start = floor((w_nb-1)*points)+1;
    stop = floor(w_nb*points);
    analysed = raw_data(channel,start:stop);
    kurt = kurtosis(analysed);
    if isnan(kurt)
        clean = 0;
        return
    end
end

% ALL NEXT STEPS REQUIRE FITLERING AND HAMMING

if window_and_filt

    windowed_f_d = filt_and_ham_epoch(raw_data,fs);
    windowed_filt_data = windowed_f_d(channel,:);
else
    windowed_filt_data = raw_data(channel,:);
end


% THRESHOLD DETECTION 
peak_threshold = 1.7e4; %threshold for peak detection 
[~, ~,~,h1] = findpeaks(windowed_filt_data, 'MinPeakProminence', peak_threshold); % positive peaks
[~, ~,~,h2] = findpeaks(-windowed_filt_data, 'MinPeakProminence', peak_threshold); % negative peaks (flip data)
if ~isempty(h1) && ~isempty(h2)
    clean = 0;
    return
end

% SYMMETRY
skwn = skewness(windowed_filt_data);
if abs(skwn) < 1e-5
    clean = 0;
    return
end




