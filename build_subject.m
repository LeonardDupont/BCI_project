function [s_EEG,epoch_nb] = build_subject(subject_number,channels,channels_n)
% This function is used to prepare .mat files in the right format (struct).
% It travels through the previously stored epochs (analysis_191118.m),
% takes in only the clean ones, filters, applies a hamming window and
% produces a labels-list. 
%
% INPUT
% 
% subject_number        an integer
%
% channels              integers referring to channels to be kept
%
% channels_n            corresponding names of channels 
%
%
% OUTPUT
%
% s_EEG                 the final datastruct to be saved
%
% epoch_nb              the number of epochs stored in the struct (purely
%                       informative)



f1=1; %low(baseline removed)
f2=45; %high(electric artefact and above)
fs=500; %sampling frequency 
[num,dem]=butter(2,[f1,f2]*2/fs); % we build a filter

clean = dir('*clean_epoch*'); %we search for the epochs that are artefact-free 
subject_name = ['subject_',num2str(subject_number),'.mat']; %the will be the subject name
sampling_rate = fs;
epoch_nb = length(clean); %the number of clean epochs

ch_count = 1;
for channel=1:length(channels)
    channel_names{1,ch_count} = channels_n{channel};
    ch_count = ch_count+1;
end %we build a list with the names of the channels we keep (although we'll probably keep them all)


if isempty(clean) %if there is no clean epoch for the subject... 
    disp(['No clean epoch for ', subject_name, '.']) %say it!
    s_EEG = 0;
    return
else %otherwise 
    data = zeros(length(channels),150,length(clean)); %create right-sized matrix for the data
    labels = zeros(1,length(clean)); %and assigned labels (-1;+1)
    for epoch=1:length(clean) %we go through the clean epochs of our subject
        name = clean(epoch).name; %name of the prepared epoch
        epp = load(name); %we load the raw epoch
        
        %FILTERING AND HAMMING
        h_window = hamming(150);
        windowed_data = zeros(length(channels),150);
        for channel=1:length(channels)
            data_filt = filtfilt(num,dem,epp.good_epoch(channel,:));
            windowed_data(channel,:) = h_window'.*data_filt; %we filter the data and apply hamming
        end
        
        data(:,:,epoch)=windowed_data; %and store all channels of the epoch in the matrix
        
        if contains(name,'emergency')
            labels(1,epoch) = 1; %then we assign label values
        else
            labels(1,epoch)= -1;
        end
    end
end

s_EEG.data = data;
s_EEG.labels = labels;
s_EEG.sampling_rate = sampling_rate;
s_EEG.subject_number = subject_number;
s_EEG.channel_names = channel_names; %in the end, we build a struct that will be understood by SigmaBox



        

