%# This script is to get od pairs from GPS traces in SF. Since each cab records whether the cab is occupied or not, we treat an occupied
%# subsequence as a trip. The first and last points of a trip is treated as an od pair.

%# Output
%# sf_od - for each cab, we store the od pairs it generated; in each cell each row, we store an od pair: O-xy, O-time, O-zone idx, D-xy, D-time, D-zone idx
%# sf_od_cab_names - for each cab, we store the file name. This is exactly corresponds to the order in sf_od.

clear all; close all; clc;
addpath(genpath('../func'));

load('../od.mat','sfTAZ_trans');
all_poly = sfTAZ_trans; % load all SF TAZ coordinates

ori_path  = '../../data/gps_data/original/cabspottingdata/';
tran_path = '../../data/gps_data/processed/transform/';
listing = dir(ori_path); % get all file names
cab_names = {listing.name}; % there are two empty folder names which are not actual cab names are also stored.

[~,n] = size(cab_names);
od_all = cell(n,1);
parfor i = 1:n % we can use parfor here
    
    file_name = char(cab_names(i)); 
    
    od = [];
    if(length(file_name) > 3 & file_name(1:3) == 'new')       
        disp(file_name);
        
        %# get an original GPS trace and its transformed coordinates
        ori_trace = dlmread(strcat(ori_path, file_name), ' '); 
        tran_trace = dlmread(strcat(tran_path, file_name), ' ');
        ori_trace(:,1:2) = tran_trace;
        
        %# SF GPS data are not temporarlly sorted. Here, we sort a trace according to timestamps.
        ori_trace = sortrows(ori_trace,4);
        
        %# get occupied subsequence information
        subSeq_info = findSeq(ori_trace(:,3));
        occupiedSeq_idx = find(subSeq_info(:,1) == 1);
        occupiedSeq = subSeq_info(occupiedSeq_idx,2:3); % each row records an occupied subsequence starting entry and ending entry

        %# compute od pair from each subsequence
        for j = 1:size(occupiedSeq,1)          
            subseq = ori_trace(occupiedSeq(j,1):occupiedSeq(j,2),[1 2 4]);
            od_pair = extractOD(subseq,all_poly);
            if(length(od_pair) > 0)
                od = [od; od_pair];
            end
        end
       
    end   
    
    if(length(od) > 0)
        od_all{i} = od;
    end
    
    
end

%# post processing to get rid of empty cells in sf_od
sf_od = {};
sf_od_cab_names = {};
for i=1:size(od_all,1)
    tmp = od_all{i};
    if(length(tmp) > 0)
       len = length(sf_od);
       sf_od{len+1} = tmp;
       sf_od_cab_names{len+1} = char(cab_names(i));
    end
end



%# for each point, find its taz
% taz_idx = ones(length(trace(:,4)),1)*-1;
% for j = 1:length(all_poly)
%     polyXY = all_poly{j};
%     in = inpolygon(traceXY(:,1), traceXY(:,2), polyXY(:,1), polyXY(:,2));
%     [n,~] = find(in == 1);
%     taz_idx(n) = j;
% end
% 
% 
% 
% %# build sparse OD matrix based on GPS count
% count = ones(size(od_pair,1),1);
% od_gps = sparse(od_pair(:,1),od_pair(:,2),count);%         %# for each point, find its taz
%         taz_idx = ones(length(trace(:,4)),1)*-1;
%         for j = 1:length(all_poly)
%             polyXY = all_poly{j};
%             in = inpolygon(traceXY(:,1), traceXY(:,2), polyXY(:,1), polyXY(:,2));
%             [n,~] = find(in == 1);
%             taz_idx(n) = j;
%         end
%         
%         %# remove points which have no taz
%         taz_idx = taz_idx(find(taz_idx ~= -1));
%         
%         %# for consecutive points that are in the same taz, keeps one of them
%         taz_idx_nodup = [];
%         pre = taz_idx(1);
%         for j = 2:length(taz_idx);
%             if(taz_idx(j) ~= pre)
%                taz_idx_nodup = [taz_idx_nodup; taz_idx(j)];
%                pre = taz_idx(j);
%             end
%         end        
%         assert(isempty(find(diff(taz_idx_nodup) == 0)), 'Error: consecutive counts!');
%         
%         %# collect od pair by looking at consecutive taz indices
%         for j = 1:length(taz_idx_nodup)-1
%             od_pair = [od_pair; [taz_idx_nodup(j) taz_idx_nodup(j+1)]];
%         end



%# build sparse OD matrix based on GPS count
% count = ones(size(od_pair,1),1);
% od_gps = sparse(od_pair(:,1),od_pair(:,2),count);

