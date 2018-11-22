function [epoched_data] = epoching_function(data,epoch_size,fs,channel)
% This function takes in raw EEG data and cuts it into non-overlapping
% windows. You must feed in 1 electrode at a time (cf.channel). Loop it 
% if you want to epoch several electrodes. 
%
% INPUT
%
% data           the raw data (matrix with electrodes and datapoints)
%
% epoch_size     the size of the epochs in s
%
% fs             the sampling frequency
%
% channel        the channel to epoch (electrode)
%
%
% OUTPUT
%
% epoched_data   the electrode data after being split

nb_points = fs*epoch_size; %we find the corresponding number of points per-channel
[~,b] = size(data); %we find the number of points per channel (recording length)
epoched_data = zeros(ceil(b/nb_points),nb_points); %and we prepare a matrix
m = ceil(b/nb_points);
x = (1:2500:30290); %we find the starting coordinates of each epoch
for k=1:m-1 %for the m-1 first epochs, it's easy...
    start = x(k);
    epoched_data(k,:) = data(channel,start:start+nb_points-1);
end
epoched_data(m,1:b-x(end)+1)=data(channel,x(end):b); %but for the last one, we might not have (nb_points) left. We add the last values separatly.
%It leaves a number of unreplaced '0's within the initial matrix, but who
%cares? 





    


