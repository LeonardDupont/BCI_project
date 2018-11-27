%% The purpose of this script is to analyse the different frequency components of our epochs
subjects = {'Subject1', 'Subject2', 'Subject5', 'Subject6', 'Subject8', 'Subject9', 'Subject11', 'Subject12', 'Subject13', 'Subject14'};
%subjects = {'Subject2','Subject6','Subject13'};
%now we need to import our data back into matlab
[emergency,em_subjects] = extract_emergencies(subjects);
[others,oth_subjects] = extract_others(subjects);
%channels = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19};
channels = {2 5 11 12 15 16}; %central scalp + medial
fs = 500; %Hz
%%
%we now have two matrices with clean epochs, either emergency or
%non-emergency ones. 
%extract_powerbands is a function that gives back an average power for all
%of our four spectral bands. 

[em_powerbands,em_ch_subjects,em_pw_subjects] = extract_powerbands(em_subjects,channels,emergency,fs);
[oth_powerbands,oth_ch_subjects,oth_pw_subjects] = extract_powerbands(oth_subjects,channels,others,fs);

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


%% BOXPLOTs PER SUBJECTS (CHANNELS AVERAGED)
bands={'delta','theta','alpha','beta'};
for band=1:4
    subplot(2,2,band), hold on
    title(['Comparison of the ', bands{band}, ' bands in the two conditions'])
    boxplot([v_em(:,band),v_oth(1:7,band)],'Labels',{'emergency','other'})
    xlabel('Conditions')
    ylabel('Relative magnitude')
    hold off
end


%% BOXPLOTS PER CHANNELS (SUBJECTS AVERAGED)
bands_title={'\delta','\theta','\alpha','\beta'};
bands={'delta','theta','alpha','beta'};
averaged_subjects_em = zeros(4,length(channels),length(em_subjects));
averaged_subjects_oth = zeros(4,length(channels),length(oth_subjects));

%EMERGENCY
for channel=1:length(channels)
    for band=1:4
        for sub=1:length(em_subjects)
          averaged_subjects_em(band,channel,sub) = em_ch_subjects.(em_subjects{sub}).(bands{band})(channel,1);
        end
    end
end

%OTHERS
for channel=1:length(channels)
    for band=1:4
        for sub=1:length(oth_subjects)
           averaged_subjects_oth(band,channel,sub) = oth_ch_subjects.(oth_subjects{sub}).(bands{band})(channel,1);
        end
    end
end


sub_max = min(length(em_subjects),length(oth_subjects));
c=1;
for band=1:4
    for channel=1:length(channels)
        subplot(4, 6,c), hold on
        title(['Channel n°',num2str(channels{channel}),' -- ',bands_title{band}])
        emerg = squeeze(averaged_subjects_em(band,channel,1:sub_max));
        oth = squeeze(averaged_subjects_oth(band,channel,1:sub_max));
        boxplot([emerg,oth],'Labels',{'emergency','other'},'BoxStyle','filled','Colors','rb')
        xlabel('Conditions')
        %ylabel('Spectral power (nV^{2}.Hz^{-1})')
        hold off
        c=c+1;
    end
end

    





