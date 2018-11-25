function [emergency, em_subjects] = extract_emergencies(subjects)
% This function takes in a cell of subject names (subjects)
% and travels in subfolders of the given name to extract
% epochs (with all channels) of clean emergency recordings.

em_subjects = {};
ok = 1;
for sub=1:length(subjects) %we travel through the cell
    cd(subjects{sub}) %and go into the subfolder of the subject
    em = dir('*emergency*'); %we check which files in the directory contain the name 'emergency'
    
    if isempty(em) %if there is none...
       disp(['No emergency recording without artefact for ', subjects{sub},'. Next subject.'])
       cd .. %then we go back to the main directory
       
    else %otherwise...
      em_subjects{ok} = subjects{sub};
      ok = ok + 1;
      for k=1:length(em) %... we travel through the emergency file names
          
         epoch_nb = ['epoch',num2str(k)];
         epp = load(em(k).name); 
         emergency.(subjects{sub}).(epoch_nb) = epp.good_epoch(:,:); %and store epochs in a struct
         
      end
      cd .. %next subject, going back to the main directory
    end
end
