model = 'SVM_model1.mat';
load(model);

%%%% This will import the previously saved model in the matlab workspace.
%%%% There are 7 distinct struct fields:
%
%  -apply_model_results : contains the test results from SIGMAbox 
%  -feature_result : all information about features before the ranking
%  -init_method : info about feature-extraction methods (thresholds,
%   unit, method number usw.)
%  -init_parameter : info about the channels, the user, the computer
%  -performance_result : performance in the test phase
%  -selected_model : contains everything about the built classifier
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SVM = selected_model.classObj; %we isolate the SVM in a variable
filt = init_parameter.filt_band_param; %we extract transfer functions parameters for filtering later on
nb_features = length(apply_model_results.used_parameters); %this will be the number of features we use

load('subject_13.mat') ; %we load our EEG data. Provided it is a s_EEG struct...
raw_data = s_EEG.data;  
[~,~,z] = size(raw_data); % [channels x points x epochs]
expectations = s_EEG.labels;
channel_Fp1 = 17;
fs = 500; %Hz

predictions = zeros(1,z);
%%
%%% 1 - We are going to feed our SVM with epochs to classify at regular
%%% time intervals
for epoch=1:z
    
    test_data = raw_data(:,:,epoch);   
    clean= automated_preprocessing(test_data,channel_Fp1,fs,0); %function also calls in artefact prob
    
    if ~clean %if it's not the case
        disp('The analysed epoch is artefacted. Aborting feature extraction procedure and moving to next epoch.') 
        predictions(epoch) = 0;
        expectations(epoch) = 0; %this will not be taken into account in the confusion matrix
    else
        filt_ham_data = filt_and_ham_epoch(test_data,fs); %we get the filtered (BPF) + hamming-treated epoch
        feature_matrix = bfeature_extraction_BCI(filt_ham_data,nb_features,filt,init_method); %extracting 9 best feature values
        predictions(epoch) = predict(SVM,feature_matrix); %and make the prediction
        disp(['Predicted value by the SVM is ',num2str(predictions(epoch)), '. Expected value was ', num2str(expectations(epoch))]) %display result live
    end
    
    pause(2); %we make a 2s pause
    
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
        true_positive = true_positive + 1 ; 
    elseif (expectations(label)==-1) && (predictions(label)==-1)
        true_negative = true_negative + 1;
    end
end

false_negative = length(find(predictions==-1)) - true_negative;
false_positive = length(find(predictions==1)) - true_positive;

true_positive = (true_positive * 100)/length(~find(expectations==0));
true_negative = (true_negative * 100)/length(~find(expectations==0));
false_negative = (false_negative * 100)/length(~find(expectations==0));
false_positive = (false_positive * 100)/length(~find(expectations==0));

confusion = [true_positive  true_negative ; false_positive  false_negative];

