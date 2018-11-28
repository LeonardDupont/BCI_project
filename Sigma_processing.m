subjects = {1,2,5,6,8,9,11,12,13,14};
channels_n = {'P7','P4','Cz','Pz','P3','P8','O1','O2','T8','F8','C4','F4','Fp2','Fz','C3','F3','Fp1','T7','F7'};
channels = 1:1:19;

epochs = zeros(length(subjects),1);
for sub = 1:length(subjects)
    sub_name = ['Subject',num2str(subjects{sub})];
    subject_name = ['subject_',num2str(subjects{sub})];
    cd(sub_name)
    [s_EEG,epoch_nb] = build_subject(subjects{sub},channels,channels_n);
    epochs(sub) = epoch_nb;
    save(subject_name,'s_EEG')
    cd ..
end
disp(epochs)

%%
training = [6,8,13,14];
test = [1,2,5,11]; %we now have a 80% training and 20% test epoch distribution






