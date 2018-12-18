function [output] = est_dist_draw(labels)
%This function is a special one

prob_1 = length(find(labels==1))/length(labels);
if rand() > prob_1
    output = 1;
else
    output = -1;
end

