%# highway types that are used in visulization
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

load('od.mat','ny_node','ny_edge')
ndAll = ny_node; egAll = ny_edge;


%%%--------------------------------------------------
%# construct a subnetwork by first look up travel times given a date
%# then build a network based on links which have travel times
%%%--------------------------------------------------
path = '/playpen/traffic_dynamics/data/map_data/ny/travel_times/';
year = 2012; month = 5; day = 8; hour = 8;
hidx = (day-1)*24+hour;

%# get ny travel times of the specified date above
m = dlmread(strcat(path,'travel_times_',num2str(year),'/',num2str(month),'/',num2str(day)));  

%# get ny travel times of the specified hour in that day and store it in "mh"
mh = m(find(m(:,end) == hidx),:);

%# get rid of invalid entries in "mh"
[~,idx1] = ismember(mh(:,1),ndAll(:,1));
[~,idx2] = ismember(mh(:,2),ndAll(:,1)); 
nullIdx = unique([find(idx1 == 0); find(idx2 == 0)]);
mh(nullIdx,:) = []; 
idx1(nullIdx) = [];
idx2(nullIdx) = [];


%# construct a sub-network, idx1 and idx2 are node indices of all edges in ndAll
ndSub = unique([idx1;idx2]);

%# idx3 and idx4 are renumbering idx1 and idx2 from 1 to the total number of unique nodes for the sub-network, we need this renumbering to create a graph
[~,idx3] = ismember(idx1,ndSub);
[~,idx4] = ismember(idx2,ndSub);


gSub = [idx3 idx4 ndAll(idx1,1) ndAll(idx2,1) mh(:,3:4)]; % ndAll(ndSub(1129),1) - 1129 is from either idx3 or idx4

%# however idx3 and idx4 have some duplicate entries if we reverse their order, this will fail the generation of a graph since we have a duplicate edge
%# we remove dubplicate edges
[~,ia,~] = unique(sort(gSub(:,1:2),2),'rows');
gSub_unique = gSub(ia,:);

%# build a graph, however G_times are likely to have multiple components
G_times  = graph(gSub_unique(:,1), gSub_unique(:,2), gSub_unique(:,end-1));

%# we get the compIdx-th largest component
compIdx = 1;
gSub_comp = getComponent(G_times,compIdx);

%# get the mapping before the component nodes and original nodes
gSub_comp_info = getNodesMap(gSub_comp,[gSub_unique(:,3), gSub_unique(:,4), gSub_unique(:,end-1)]);

gf = subgraph(gSub_comp,[1:100]);
plot(gf);


% gSub_comp.numnodes
% numel(unique([gSub_comp.Edges.EndNodes(:,1);gSub_comp.Edges.EndNodes(:,2) ]))
% min(unique([gSub_comp.Edges.EndNodes(:,1);gSub_comp.Edges.EndNodes(:,2) ]))
% max(unique([gSub_comp.Edges.EndNodes(:,1);gSub_comp.Edges.EndNodes(:,2) ]))



%%%--------------------------------------------------
%# construct a subnetwork which contain travel times
%# first build network according to highway types, extract one connected components, and look up for travel times
%# however, this may results a lot of links have no travel times
%%%--------------------------------------------------
%# get edges that are of the specified highway types
%# each row: sid, eid, sid x, sid y, eid x, eid y
if(0)
types = [1]; % specify highway types

egSub = [];
for i = 1:length(types)
    egSub = [egSub; egAll(find(egAll(:,8) == types(i)),[1:6])];
end
egSub_len = distance(egSub(:,3:4), egSub(:,5:6));


ndSub = unique([egSub(:,1);egSub(:,2)]);

[~,idx1] = ismember(egSub(:,1),ndSub);
[~,idx2] = ismember(egSub(:,2),ndSub);


%# stores nodes and edge length for edges that are of specified highway types
gSub = [idx1 idx2 ndAll(egSub(:,1),1) ndAll(egSub(:,2),1) egSub_len];
[~,ia,~] = unique(egSub_len);
egSub_len = egSub_len(ia);
gSub = gSub(ia,:); % check origin node id matching: ndAll(ndSub(1129),1) - 1129 is from either nd_maps(:,1) or nd_maps(:,2)
G_len  = graph(gSub(:,1), gSub(:,2), egSub_len);

%# however gSub is likely to have multiple connected components, here we get its ith largest connected component
%# nComp stores the sorted component index according to how many nodes are in that component
bins = conncomp(G_len);
nComp = [1:numel(unique(bins))]';
for i = 1:numel(unique(bins))
    nComp(i,2) = numel(find(bins == i));   
end
nComp = flip(sortrows(nComp,2));
    
%# the ith largest connected component is specified in compIdx
compIdx = 1; % the sub, connected graph with the compIdx-th most nodes (e.g., compIdx=1, gets the connected component with the most nodes)
gSubComp = rmnode(G_len, find(bins ~= nComp(compIdx,1)));
assert(numel(unique(conncomp(gSubComp))) == 1, 'Error: the graph is not strongly connected!');


gSubComp_len = gSubComp.Edges.Weight;
[~,idx3] = ismember(gSubComp_len,egSub_len);
gSubComp_nd = gSub(idx3,:);


path = '/playpen/traffic_dynamics/data/map_data/ny/travel_times/';
year = 2013;
month = 1;
day = 1;
[timesDay, tripsDay] = getTravelTimes(gSubComp_nd(:,3:4),path,year,month,day);
end







    
    