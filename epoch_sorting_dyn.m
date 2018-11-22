function [] = epoch_sorting_dyn(channel,data,data_raw,ham)
%Author: @leonarddupont - 2018 BCI course (ENS-ESPCI Paris)
%This function allows the user to navigate through the epochs of a given
%channel from a dataset. The way it works is the following: 
%
% 1 - Windowing with Hamming (casual Hadamar product) if hamming==1,
% otherwise leaving data as it is.
% _______________________________________________________________
% 2 - Manual sorting of the epochs: there is no actual output,
% the sorted_epoch vector of 0s (artifacted - LEFT ARROW) and 1s (valid - RIGHT ARROW)
%epochs is made global by the function and must be drawn back by the user
%at the end. 
% _______________________________________________________________
% INPUT
%
% channel    the channel to sort epochs from
% 
% data       the dataset, data(channel,datapoints,trials)
%
% OUTPUT
%
% a global vector with 0s and 1s to define which epochs are good or not
% can be recovered with the ' vector = getGlobal_sorted; ' command

[~,y,z] = size(data);

% 1 - Windowing (Hamming)

   if ham %if the user wants us to apply a hamming window
        windowed_data = zeros(z,y);
        h_window = hamming(y); %building a window of the right size
            for k=1:z
                 windowed_data(k,:) = (h_window)'.*data(channel,:,k);
            end %the we perform the hadamar product
   end
 

% 2 - Manual sorting
   
 fig=figure('Name',['channel',num2str(channel)]);  %overall figure name
 set(fig, 'KeyPressFcn',@keypress) %coupling the keypress with figure 
 time_vector = linspace(0,300,150); %building a time vector for the x-axis
 
 epoch = 1;
 sorted_epochs = zeros(1,z); %preparing vector, don't mind the red wavelets
 
 if ham~=1 %if we did not perform the windowing, then windowed_data = data
     windowed_data = zeros(z,y);
     for k=1:z
         windowed_data(k,:) = data(channel,:,k);
     end
 end

    function redraw() %will be executed each time until epoch == z
                clf
                hold on
                
                subplot(2,1,1)
                plot(time_vector,windowed_data(epoch,:))
                axis([0 300 -1.7e4 1.7e4])
                
                subplot(2,1,2)
                plot(time_vector,data_raw(channel,:,epoch))
                axis tight
                
                title(['Epoch n° ', num2str(epoch)])
                xlabel('time (ms)')
                ylabel('Raw EEG voltage')
     end
 
redraw()

       function keypress(~,evnt) %keypress reaction
            switch lower(evnt.Key)
                case 'rightarrow'
                    if epoch<=z
                        sorted_epochs(epoch) = 1; %we keep it
                        epoch = epoch + 1;
                    end
                case 'leftarrow'
                    if epoch<=z
                    sorted_epochs(epoch) = 0; %we do not
                    epoch = epoch + 1;
                    end
                otherwise
                    return  
            end
            redraw()
       end
   global sorted_epochs
end
 