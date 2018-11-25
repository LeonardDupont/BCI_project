%% The purpose of this script is to analyse the different frequency components of our epochs
fs = 500;
subjects = {'Subject1', 'Subject2', 'Subject5', 'Subject6', 'Subject8', 'Subject9', 'Subject11', 'Subject12', 'Subject13', 'Subject14'};
%subjects = {'Subject2','Subject6','Subject13'};
%now we need to import our data back into matlab
[emergency,em_subjects] = extract_emergencies(subjects);
[others,oth_subjects] = extract_others(subjects);
channels = [1 2 7 8 11 15 16 19];
fs = 500; %Hz
%%
%we now have two matrices with clean epochs, either emergency or
%non-emergency ones. 
%extract_powerbands is a function that gives back an average power for all
%of our four spectral bands. 

[em_powerbands,~,em_pw_subjects] = extract_powerbands(em_subjects,channels,emergency,fs);
[oth_powerbands,~,oth_pw_subjects] = extract_powerbands(oth_subjects,channels,others,fs);

%% Extraction from the output struct into matrices 
v_em = zeros(numel(fieldnames(em_pw_subjects)),4);
v_oth = zeros(numel(fieldnames(oth_pw_subjects)),4);

for sub=1:numel(fieldnames(em_pw_subjects))
    for band=1:4
       v_em(sub,band) = em_pw_subjects.(em_subjects{sub})(band);
    end
end

for sub=1:numel(fieldnames(oth_pw_subjects))
    for band=1:4
       v_oth(sub,band) = oth_pw_subjects.(oth_subjects{sub})(band);
    end
end


%% BOXPLOTs
bands={'delta','theta','alpha','beta'};
for band=1:4
    subplot(2,2,band), hold on
    title(['Comparison of the ', bands{band}, ' bands in the two conditions'])
    boxplot([v_em(:,band),v_oth(1:7,band)],'Labels',{'emergency','other'})
    xlabel('Conditions')
    ylabel('Spectral power (nV^{2}.Hz^{-1})')
    hold off
end







