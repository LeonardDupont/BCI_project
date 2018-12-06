function [final_data] = filt_and_ham_epoch(raw_epoch, fs)
% This function takes in an EEG epoch with all channels and sequentially 
% applies a Butterworth band-pass filter (1-45Hz) and a Hamming window for
% further preprocessing. 

[x,y] = size(raw_epoch);

%filter
data_filt = zeros(x,y); %for one channel
final_data = zeros(x,y);
f1=1; %low(baseline removed)
f2=45; %high(electric artefact and above)
[num,dem]=butter(2,[f1,f2]*2/fs);
%hamming
h_window = hamming(y);

%operating loop
for channel=1:x
    data_filt(channel,:) = filtfilt(num,dem,raw_epoch(channel,:)); %filter
    final_data(channel,:) = (h_window)'.*data_filt(channel,:); %hamming
end
