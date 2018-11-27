function [powerbands,pw_values,pw_ch] = extract_powerbands(subjects,channels,datastruct,fs)
% This function computes the frequency power over subjects and channels specified in entry, 
% starting with a dataset contained in 'datastruct'. In our case, datastruct was
% obtained after using the extract_emergencies or extract_others functions.
% The calculated powerbands are:
%
%     delta       1-4Hz
%     theta       4-8Hz
%     alpha       8-12Hz
%     beta        12-25Hz
%
% The output unit is in nV^2.Hz-1, we might as well multiply everything by
% 10^18 to get back to V^2.Hz-1. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUT
%
% subjects      A CELL of subjects names {'Subject1', 'Subject2, (...),
%               'Subjectn'} - please mind typo - to average data from.
%               Casually, one can use the output name lists from the
%               extract functions.
%
% channels     A list of channels to analyse data from. All = [1:1:19].
%
% datastruct   The struct containing data. Its structure is as follows:
%                       1. datastruct
%                         2. 'Subject(n)'
%                           3. Epoch(i)(channel,points)
%
% fs           The sampling frequency in Hz
%
%%%%%%%%%%%%%%%%%%%%%%
%
% OUTPUT
%
% powerbands  A 4x1 vector such that powerbands = [delta,theta,alpha,beta]
%
% pw_ch       powerbands for each subject and epoch over all channels
%
% pw_values   powerbands for all subjects and channels (concatenated
%             epochs over each epoch).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% The issue with the initially windowed data is that the epoch length is
% too small (300ms at 500Hz, ie 150 points). Hence our frequency resolution
% for a single sample is 3.33Hz and this is not good at all... We decide to
% concatenate all epochs for a given channel.

clear pw_values
clear powerbands
clear pw_ch

band_names = {'delta','theta','alpha','beta'};

for sub=1:length(subjects) %we will travel in the input subject list
    
    nb_epochs = numel(fieldnames(datastruct.(subjects{sub}))); 
    %finding the nb of emergency-other epochs (subfields) for each subject
    
    for channel=1:length(channels) %we go through each epoch
        concatenated_ch = zeros(nb_epochs*150,1);
        diffh = 0;
        for epoch=1:nb_epochs
            ep_name = ['epoch',num2str(epoch)]; %therefore, this is our epoch field name
            EP_raw =  datastruct.(subjects{sub}).(ep_name);
            concatenated_ch((epoch-1)*150+1:epoch*150,1) = EP_raw(channels{channel},:)-diffh;
            
            if epoch ~= nb_epochs
                ep_name_next = ['epoch',num2str(epoch+1)];
                EP_raw_next = datastruct.(subjects{sub}).(ep_name_next);
                diffh =  EP_raw_next(channels{channel},1) - concatenated_ch(epoch*150,1);
            end
        end
        
        Fast_fourier = fft(concatenated_ch,length(concatenated_ch)); %computes the fft
        Fast_fourier(1)=0;
        FF = abs(Fast_fourier(1:length(Fast_fourier)/2+1));
        
        f_res = fs/length(concatenated_ch);
        pts = 1/f_res; %number of points for 1 hz
        
        
        total = trapz(FF); %to compute the relative magnitude
        pw_values.(subjects{sub}).(band_names{1})(channel,1) = trapz(FF(1:round(4*pts)))/total;
        pw_values.(subjects{sub}).(band_names{2})(channel,1) = trapz(FF(round(4*pts):round(8*pts)))/total;
        pw_values.(subjects{sub}).(band_names{3})(channel,1) = trapz(FF(round(8*pts):round(12*pts)))/total;
        pw_values.(subjects{sub}).(band_names{4})(channel,1) = trapz(FF(round(12*pts):round(25*pts)))/total;
 
    end
end

% We have now built the struct pw_values with the following structure:
%    1. pw_values
%       2. Subject(n)(channels,band)
%
% We already got rid of the epoch dimension because of the poor FFT
% resolution we had otherwise.
% Let's average over channels.


for sub=1:length(subjects) %we loop through subjects again
    all_ch = zeros(length(channels),1);
    for band=1:4
        for channel=1:length(channels)
            all_ch(channel) = pw_values.(subjects{sub}).(band_names{band})(channel,1);
        end
    pw_ch.(subjects{sub})(band) = mean(all_ch);
    end
end




% We have now built the struct pw_ch with the following structure:
%    1. pw_ch
%       2. Subject(n)(band)
%
% The ultimate average can be done over all subjects for a given band

powerbands=zeros(4,1);

for sub=length(subjects)
    for band=1:4
        powerbands(band) = powerbands(band) + pw_ch.(subjects{sub})(band);
    end
end

powerbands = powerbands/length(subjects); %mean computation
