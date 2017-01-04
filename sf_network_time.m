%# This script is to get a connected subnetwork in SF, so we can generate synthetic road conditions on it.

%# highway types that are addressed
% highway = {'motorway', ...      % 1
%            'trunk', ...         % 2
%            'primary', ...       % 3
%            'secondary', ...     % 4
%            'tertiary', ...      % 5
%            'unclassified', ...  % 6
%            'residential', ...   % 7
%            'motorway_link', ... % 8
%            'trunk_link', ...    % 9
%            'primary_link', ...  % 10
%            'secondary_link', ...% 11
%            'tertiary_link'};    % 12


clear all; close all; clc;
addpath(genpath('./func/'));
addpath(genpath('../ue/func/'));

%# ---------------------
%# variables
%# ---------------------
city = 1; % 1-sf,2-ny,3-by
compIdx = 1; % the ith largest connected network
taz_thres = 350; % the distance used to make sure TAZs are spreaded out.
%# ---------------------

switch city
    case 1
        load('od.mat','sf_way','sf_node','sf_edge','sfTAZ_trans');
        wayAll = sf_way;
        ndAll  = sf_node;
        egAll  = sf_edge;
        tazAll = sfTAZ_trans;
        hwyTypes = [1 2 3 4 5 6 8 9 10 11 12];
        lon = [-122.4467 -122.3782];
        lat = [37.7711 37.8118];
        %drawNet(wayAll,ndAll,hwyTypes);
    case 2
    case 3
end


%# get a connected graph within a spatial range and of specified highway types

[egs,xy_bounds] = getNet(egAll,ndAll,lon,lat,hwyTypes,compIdx);

%# get spreaded nodes as origins and destinations
od_nds = getOD(xy_bounds, tazAll, egs, taz_thres);

% drawEg(egs(:,3:4), egs(:,5:6));
% hold on;
% scatter(nd_retain(:,2), nd_retain(:,3), 'x');

[G_tmin,G_tmax,G_len] = initNet(egs); 

% nn = size(od_nds,1);
% od_pth = [];
% for i = 1:nn
%     for j = 1:nn
%         if(i == j)
%             od_pth = [od_pth; [od_nds(i,1) od_nds(j,1) 0]];
%         else
%             [pth,cost] = shortestpath(G_tmin,i,j);
%             od_pth = [od_pth; [od_nds(i,1) od_nds(j,1) length(pth)]];
%         end
%     end    
% end


nNd = 50; % numnodes(G_tmin);
od = sparse(nNd,nNd);
% ratio = 1000;
% for i = 1:size(od_pth,1)
%     if(od_pth(i,1) <= nNd & od_pth(i,2) <= nNd)
%         od_mat(od_pth(i,1),od_pth(i,2)) = od_pth(i,3) * ratio;
%     end
% end

od(1,2) = 500; od(1,3) = 600; od(1,4) = 500; od(1,5) = 1000;
od(2,1) = 500; od(2,3) = 400; od(2,4) = 500; od(2,5) = 1100;
od(3,1) = 400; od(3,2) = 500; od(3,4) = 500; od(3,5) = 1100;
od(4,1) = 500; od(4,2) = 500; od(4,3) = 400; od(4,5) = 1000;
od(5,1) = 1000; od(5,2) = 1200; od(5,3) = 1200; od(5,4) = 1000;


H = subgraph(G_tmin,[1:nNd]);
cap = 100; % default edge capacity
net = [H.Edges.EndNodes H.Edges.Weight ones(numedges(H),1) * cap];
[lk_flows,lk_times,~] = uefw(net, od, 2, 'ue');  % 'ue' or 'so'

[~,~,c] = find(lk_flows{end});




    
    
    
    

%# using solutions to UE model as ground truth
if(false)
    
    nNd = numnodes(H_len);
    od_demand = zeros(nNd,nNd);
    for i = 1:length(od_ctr)
        for j = 1:length(od_ctr)          
            if(i == j)
                continue;
            end
            o = od_ctr(i);
            d = od_ctr(j);
            od_demand(o,d) = info;
            
%             %# find how many tazs are associated with this pair of origin and destination
%             o_taz = taz_nd(find(taz_nd(:,2) == o),1);
%             d_taz = taz_nd(find(taz_nd(:,2) == d),1);
%             
%             %# sum taz load 
%             odd = 0; % the od demand for a pair of origin and destination
%             for k1 = 1:length(o_taz)
%                 for k2 = 1:length(d_taz)
%                     odd = odd + od_gps(o_taz(k1),d_taz(k2));
%                 end
%             end
%             od_demand(o,d) = round(odd/od_ratio); % od_cap; randi([10 15],1,1);
        end
    end

    %# assign all entries in od_demand some value
    % for i = 1:nNd
    %     for j = 1:nNd
    %         od_demand(i,j) = od_cap; %randi([10 15],1,1);
    %     end
    % end
    % r = randi([od_cap od_cap],1,nNd*nNd);
    % od_demand = reshape(r,[nNd nNd]);
    
    %# solve UE model
    cap = 1000; % default edge capacity
    eCaps = ones(length(H_tmin.Edges.Weight),1) * cap;
    ladder = [H_tmin.Edges.EndNodes H_tmin.Edges.Weight eCaps];
    [~,link_times,~] = uefw(ladder, 1, od_demand, 3, 'ue');  % 'ue' or 'so'
    
    %# check results
    [~,~,e_times] = find(link_times{end});
    H_true = H_len;
    H_true.Edges.Weight = e_times;
end






%# vintage code for backup
% function [nodeIdx, wayId] = get_nodeIdx_osm(lon, lat)
% 
% load('sf.mat','sfWay','sfWayNode','sfWayCtrLonLat');
% 
% % lon = [-122.4179 -122.4137];
% % lat = [37.7979 37.8004];
% 
% %# find all ways within the range
% coords = sfWayCtrLonLat;
% idx = find(coords(:,2) >= lon(1) & coords(:,2) <= lon(2) & coords(:,3) >= lat(1) & coords(:,3) <= lat(2));
% wayId = coords(idx,1);
% 
% %# collect all node ids of all within-range ways
% nodeIdx = [];
% for i = 1:length(wayId)   
%     wayEntry = find(sfWay(:,1) == wayId(i));
%     nodeIdx = [nodeIdx find(sfWayNode(wayEntry,:) == 1)];
% end
% 
% nodeIdx = unique(nodeIdx)';
% 
% end



% function [] = network_stats_taz(lon, lat, taz)
%     
% %     lon = [-122.4475 -122.3777];
% %     lat = [37.7702 37.8121];
%         
%     [ndIdx, wayIdx] = get_nodeIdx_osm(lon, lat);
%     mean_poly_cvx = [];
%     for i = 1:length(taz)
%         mean_poly_cvx = [mean_poly_cvx; mean(taz{i})];
%     end
%     pcall = mean_poly_cvx;
%     nTaz = length(pcall(find(pcall(:,1) >= lon(1) & pcall(:,1) <= lon(2) & pcall(:,2) >= lat(1) & pcall(:,2) <= lat(2)),1));
%     fprintf('Within the range specified by lon and lat: #nodes = %d, #ways = %d, #taz = %d\n',length(ndIdx),length(wayIdx),nTaz);
%     
% end