function [others,oth_subjects] = extract_others(subjects)
% This function takes in a cell of subject names (subjects)
% and travels in subfolders of the given name to extract
% epochs (with all channels) of clean non-emergency ('other') recordings.

oth_subjects = {};
ok = 1;

for sub=1:length(subjects)
    cd(subjects{sub})
    oth = dir('*other*');
    
    if isempty(oth)
       disp(['No non-emergency recording without artefact for ', subjects{sub},'. Next subject.'])
       cd ..
       
    else
      oth_subjects{ok} = subjects{sub};
      ok = ok + 1;
      for k=1:length(oth)
          
         epoch_nb = ['epoch',num2str(k)];
         epp = load(oth(k).name);
         others.(subjects{sub}).(epoch_nb) = epp.good_epoch(:,:);
         
      end
      cd ..
    end
end
