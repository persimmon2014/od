

clear all; close all; clc;

load('sf_extra.mat','od_all');

% tmp_all = [];
% parfor i = 1:length(od_all)
%    if(length(od_all{i}) > 0)
%        tmp = od_all{i};
%        tmp = [tmp zeros(size(tmp,1),1) zeros(size(tmp,1),1)]
%        for j = 1:size(tmp,1)
%            tmp(j,9) = timeConvert(tmp(j,3));
%            tmp(j,10) = timeConvert(tmp(j,7));
%        end
%        tmp_all = [tmp_all; tmp];
%    end 
%     
% end

load('trash.mat','tmp_all');

od_count = cell(168,1);
for i = 1:168
    o_tmp = tmp_all(find(tmp_all(:,9) == i),[4 8]);
    d_tmp = tmp_all(find(tmp_all(:,10) == i),[4 8]);
    
    od_count{i} = unique([o_tmp; d_tmp],'rows');
end

size_all = [];
for i = 1:168
    size_all = [size_all; size(od_count{i},1)];
end

aaa = [tmp_all(:,3); tmp_all(:,7)];


idx_all = [];
for i = 1:length(aaa)
    idx = timeConvert(aaa(i));
    idx_all = [idx_all;idx];
    
end




 
    