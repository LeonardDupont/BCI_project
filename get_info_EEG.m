function [data, labels] = get_info_EEG(number)
%This function takes in a subject EEG recording according to the usual
%format in the BCI class and creates output arguments that can be used for
%analysis. 


subject_nb = dir(number);
subject_load = load(subject_nb.name);

data = subject_load.s_EEG.data(:,:,:);
labels = subject_load.s_EEG.labels;




