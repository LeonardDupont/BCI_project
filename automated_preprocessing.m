function [clean] = automated_preprocessing(raw_data,channel,fs)
% This function will be implemented in the offline BCI
% to filter the data, apply a hamming window and test
% for the presence of artefacts. Indeed, while we did 
% use manual rejection to build our classifier, we 
% want to be snappy in the BCI. 
%
% We will use a threshold detection, a blocking detection, skewness and
% kurtosis.

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

%%%% FILTER 
data_filt = zeros(1,y); %for one channel
f1=1; %low(baseline removed)
f2=45; %high(electric artefact and above)
[num,dem]=butter(2,[f1,f2]*2/fs);
data_filt(1,:) = filtfilt(num,dem,raw_data(channel,:));

%%%% HAMMING 
h_window = hamming(y);
windowed_filt_data = (h_window)'.*data_filt(channel,:);


% THRESHOLD DETECTION 
peak_threshold = 1.6e4; %threshold for peak detection 
[~, ~,~,h1] = findpeaks(windowed_filt_data(epoch,:), 'MinPeakProminence', peak_threshold); % positive peaks
[~, ~,~,h2] = findpeaks(-windowed_filt_data(epoch,:), 'MinPeakProminence', peak_threshold); % negative peaks (flip data)
if ~isempty(h1) && ~isempty(h2)
    clean = 0;
    return
end

% SYMMETRY
skwn = skewness(windowed_filt_data);
if skwn < 1e-5
    clean = 0;
    return
end




