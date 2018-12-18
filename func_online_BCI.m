function [predictions,expectations,confusion,time_needed] = func_online_BCI(model_name,s_EEG,display,waiting_time,cheat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% @ Inssia Dewany, Edwin Gatier, Matthieu Sanchez, Léonard Dupont
% 2018 BIN Master, BCI module - ESPCI & ENS Paris
%
% This function uses the extracted SVM algorithm from SIGMA box and applies
% it on a dataset contained in the s_EEG struct, according to the usual
% format. It can be regarded as a 2-step function:
%
%%%% 1. Feeding the SVM with epochs from s_EEG at regular time intervals
%%%% 2. Assessing the reliability of the model on the s_EEG dataset
%
% INPUT        s_EEG              usual struct
%              model_name         char sequence, model name in cd
%              display            1 or 0 depending if you want to see
%                                 the live progress through epochs
%              waiting_time       time between each epoch (s)
%              cheat              if 1, the programme will cheat
%
% OUTPUT       predictions        what the SVM predicted
%              expectations       actually corresponds to s_EEG.labels
%              confusion          matrix with true +/- and false +/-
%              time_needed        list of times needed to predict the label
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mdl = load(model_name);
SVM = mdl.selected_model.classObj; %we isolate the SVM in a variable
filt = mdl.init_parameter.filt_band_param; %we extract transfer functions parameters for filtering later on
nb_features = length(mdl.apply_model_results.used_parameters); %this will be the number of features we use

raw_data = s_EEG.data;  
[~,~,z] = size(raw_data); % [channels x points x epochs]
expectations = s_EEG.labels;
channel_Fp1 = 17;
fs = 500; %Hz

predictions = zeros(1,z);
time_needed = zeros(1,z);


%%% 1 - We are going to feed our SVM with epochs to classify at regular
%%% time intervals
for epoch=1:z
    
    test_data = raw_data(:,:,epoch); 
    tic %start timer
    clean= automated_preprocessing(test_data,channel_Fp1,fs,0); %function also calls in artefact prob
    
    if ~clean %if it's not the case
        if display
            disp('The analysed epoch is artefacted. Aborting feature extraction procedure and moving to next epoch.') 
        end
        predictions(epoch) = 0;
        expectations(epoch) = 0; %this will not be taken into account in the confusion matrix
    else
        if ~cheat
            filt_ham_data = filt_and_ham_epoch(test_data,fs); %we get the filtered (BPF) + hamming-treated epoch
            feature_matrix = bfeature_extraction_BCI(filt_ham_data,nb_features,filt,mdl.init_method); %extracting 9 best feature values
            predictions(epoch) = predict(SVM,feature_matrix); %and make the prediction
        else
            predictions(epoch) = est_dist_draw(expectations);
        end
        if display
            disp(['Predicted value by the SVM is ',num2str(predictions(epoch)), '. Expected value was ', num2str(expectations(epoch))]) %display result live
        end  
    end
    
    time_needed(1,epoch) = toc;
    pause(waiting_time); %we make a 2s pause
    
end

%%% 2 - Now, we will assess its reliability
% REMINDERS : 
%       sensitivity : true positive rate, i.e expectation = prediction = 1
%       specificity : true negative rate, i.e expectation = prediction = -1
%
% Here we will build the confusion matrix for our studied subject
true_positive = 0;
true_negative = 0;

for label = 1:length(expectations)
    if (expectations(label)==1) && (predictions(label)==1)
        true_positive = true_positive + 1 ; %then it's a true positive
    elseif (expectations(label)==-1) && (predictions(label)==-1)
        true_negative = true_negative + 1; %then it's a true negative
    end
end

false_negative = length(find(predictions==-1)) - true_negative; %remaining -1 that are not true negatives
false_positive = length(find(predictions==1)) - true_positive;

true_positive = (true_positive)/length(find(expectations~=0));
true_negative = (true_negative)/length(find(expectations~=0));
false_negative = (false_negative)/length(find(expectations~=0));
false_positive = (false_positive)/length(find(expectations~=0));

confusion = [true_positive  true_negative ; false_positive  false_negative];
