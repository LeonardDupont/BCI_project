%% PREPROCESSING ALGORITHM
% This script is meant for the analysis of the epochs of subjects.
% All sections have to be executed sequentially and separately. 
%% OPENING DATA

subjects = {'subject1', 'subject2', 'subject5', 'subject6', 'subject8', 'subject9', 'subject11', 'subject12', 'subject13', 'subject14'};
c=1;
for k = [1 2 5 6 8 9 11 12 13 14]
    name = sprintf('subject_%1.0f.mat',k);
    [data,labels] = get_info_EEG(name);
    d.(subjects{c}).data = data;
    d.(subjects{c}).labels = labels;
    clear data, clear labels
    c = c + 1;
end
clear c 
%here we create a struct d containing fields with subjects data, namely
%data points and labels
%% we already have epochs
%we go onto the pre-processing steps: (1) large amplitude threshold (2) manual validation
subject=4; %ATTENTION, indice dans la liste subjects! (subjects{3} = subject5)
disp(subjects{subject})
channel_T8 = 9; %temporal region %frontal region
channel_Fp1 = 17;

[x,y,z] = size(d.(subjects{subject}).data);

% FILTERING (BAND PASS) %
fe=500; %sampling rate Hz
f1=1; %low(baseline removed)
f2=45; %high(electric artefact and above)
[num,dem]=butter(2,[f1,f2]*2/fe);

data_filt = zeros(x,y,z); %for one channel
for channel=1:x
    for epoch=1:z
        raw = d.(subjects{subject}).data(channel,:,epoch);
        data_filt(channel,:,epoch) = filtfilt(num,dem,raw);
    end
end
%%
% MANUAL SORTING% 
data_raw = d.(subjects{subject}).data;
epoch_sorting_dyn(channel_Fp1,data_filt,data_raw,1)

% HOW TO SORT EPOCHS?
% On se base sur Fp1, une électrode du cortex préfontral sensible aux
% clignements des yeux, mouvements de la mâchoire, ce qui permet d'avoir un rejet sévère. 
% 
% On suppose que si un artéfact est détecté sur une électrode, il est
% présent sur toutes les autres et vice versa:
%    P(pas artefact electrode i / pas artefact electrode j) = 0.9
%
% Ainsi, on considère artéfacté l'epoch sur toutes les channels. 
%% GETTING THE VECTOR
sorted_epochs = getGlobal_sorted; 
%% we now save the clean epochs into .mat files
folder_name = [subjects{subject},'_sorted'];
mkdir(folder_name)
cd(folder_name) % create a folder with the right name (it's gonna be a mess of 100 epochs)

for k=1:100
    sorting = sorted_epochs(k);
    success = d.(subjects{subject}).labels(k);
        
         if (sorting==1) && (success==1) %if data is not artefacted and it was an emergency success... 
             epoch_name = [subjects{subject},'_clean_epoch_',num2str(k),'_emergency.mat'];
             good_epoch = d.(subjects{subject}).data(:,:,k);
             save(epoch_name,'good_epoch')
             clear good_epoch
             
         elseif (sorting==1) && (success==-1)
             epoch_name = [subjects{subject},'_clean_epoch_',num2str(k),'_other.mat'];
             good_epoch = d.(subjects{subject}).data(:,:,k);
             save(epoch_name,'good_epoch')
             clear good_epoch
             
         elseif (sorting==0)
             epoch_name = [subjects{subject},'_artifacted_epoch_',num2str(k),'.mat'];
             bad_epoch =  d.(subjects{subject}).data(:,:,k);
             save(epoch_name,'bad_epoch')
             clear bad_epoch
         end      
end
cd ..
%name_vect = ['sorting_vector_',subjects{subject},'.mat'];
%save(name_vect,'sorted_epochs')





