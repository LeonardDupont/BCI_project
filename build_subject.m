function [s_EEG,epoch_nb] = build_subject(subject_number,channels,channels_n)

clean = dir('*clean_epoch*');
subject_name = ['subject_',num2str(subject_number),'.mat'];
sampling_rate = 500;
epoch_nb = length(clean);

ch_count = 1;
for channel=1:length(channels)
    channel_names{1,ch_count} = channels_n{channel};
    ch_count = ch_count+1;
end


if isempty(clean)
    disp(['No clean epoch for ', subject_name, '.'])
    s_EEG = 0;
    return
else
    data = zeros(length(channels),150,length(clean)); %create right-sized matrix
    labels = zeros(1,length(clean));
    for epoch=1:length(clean)
        name = clean(epoch).name;
        epp = load(name);
        data(:,:,epoch)=epp.good_epoch;
        if contains(name,'emergency')
            labels(1,epoch) = 1;
        else
            labels(1,epoch)= -1;
        end
    end
end

s_EEG.data = data;
s_EEG.labels = labels;
s_EEG.sampling_rate = sampling_rate;
s_EEG.subject_number = subject_number;
s_EEG.channel_names = channel_names;



        

