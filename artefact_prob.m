function probability = artefact_prob(data, epoch)
% This function takes in an epoch of a dataset and returns a probability of
% artefact presence based on kurtosis, skewness and threshold crossing. 
% The channel is already specified (restricted data).
%
% INPUT
%
% data             the complete dataset
% epoch            the epoch to analyse
%
% OUTPUT
%
% probability      value between 0 and 1 
%
% METHOD: based on a weighted sum of presence of our three artefact
% indicator. Weights are calculated based on the amplitude between the 
% threshold and the measured value.
%       example: if kurtosis(threshold) = 3.5 and the measured kurtosis
%       is 5, then the weight will be abs(3.5-5). 
% If the threshold is not crossed, then the weight is not added to the
% calculation.

% KURTOSIS
kurtosis_th = [2.5 3.5]; 
kurt = kurtosis(data(epoch,:));
Dist_k = max(abs(kurt-kurtosis_th(1)),abs(kurt-kurtosis_th(2)));
D_k_max = max(4,Dist_k); %maximum value of abs(kurtosis_th - kurtosis_measured)

if (2.5<=kurt) && (kurt<=3.5)
    iskurt=0;
else
    iskurt=1;
end

% PEAK 
peak_threshold = 1.2e4; %threshold for peak detection 
[~, ~,~,h1] = findpeaks(data(epoch,:), 'MinPeakProminence', peak_threshold); % positive peaks
[~, ~,~,h2] = findpeaks(-data(epoch,:), 'MinPeakProminence', peak_threshold); % negative peaks (flip data)
hh = max(max(h1),max(h2)); %we find the biggest peak of all if there is one
Dist_h = hh - peak_threshold; %we compute the amplitude of the difference to the threshold for peak height
D_pk_max = max(2e4, Dist_h);

if isempty(hh) % there is no peak, positive or negative
    ispeak=0;
else
    ispeak=1;
end


% SKEWNESS
skwn_max = 0; %2e-16 for a perfect sine wave
S = 100; %random coefficient
skwn = skewness(data(epoch,:));
Dist_sk = S/(1+abs(skwn_max - skwn));
if abs(skwn)>1
    isskwn=0;
else
    isskwn=1;
end


% PROBABILITY COMPUTATION

probability = (iskurt*Dist_k + ispeak*Dist_h + isskwn*Dist_sk)/(D_k_max + D_pk_max + 1); 






