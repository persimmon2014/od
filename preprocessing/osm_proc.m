%# Process an osm file and store cooresponding information.

%# sf_way - all ways of sf with out-bounds nodes removed and single node way removed.
%#          each cell has the info: way id, valid node ids, highway type, freeway flag, oneway flag
%# sf_node - all in-bounds and on-the-way nodes of sf, each row: nd id, nd x, nd y, nd lon, nd lat
%# sf_edge - all edges from sf_way; each row: start nd idx, end nd idx, start nd xy, end nd xy, way id, way type, fwy flag, oneway flag
%# sf_loop - all loops, each row: loop id, x, y, lon, lat

%# Note, current 168 index is in GMT, to map to PST we need left shift the index by 7 (i.e. circshift(xx,-7)) 
%# E.g. the 140 hour is supposed to be Friday 7pm, however in our current index, the correct hour index is 147

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


clear all; close all; clc; format long g;
format long g;
addpath(genpath('./func'));


%#------------------------------------------------------------
%# process ways: not all ways are actual roads, there are buildings and rivers for example;
%#               we only address certain types of the highway class fow now.
%# input: an osm file
%# output: way_all - all ways, each way has the following information: way id, node ids, highway type 
%#------------------------------------------------------------
if(false)

% specify a city
filename = '../data/map_data/bj/bj.osm';
try
    mapxml = xmlread(filename);    
    wayArray = mapxml.getElementsByTagName('way');  % get all ways
catch
    error('Failed to read XML file %s.', filename)
end

wayAll = {}; % store way information
for i = 0 : wayArray.getLength-1   
    %# get a way
    way = wayArray.item(i); 
    
    %# if this way is a currently addressed type, we store its info: wayId, node ids, highwayType
    wayInfo = [];
    
    %# get its attributes
    wayId = str2num(getAttr(way,'id')); 
    wayInfo = [wayInfo; wayId];
    
    %# process the first node in a way
    ndIds = []; % temporarily store all node ids
    childNode = way.getFirstChild.getNextSibling; % the first child of a way node is not a real node, so we get its sibling.
    if childNode.getNodeType == childNode.ELEMENT_NODE;    
        nid = str2num(getAttr(childNode,'ref'));
        ndIds = [ndIds; nid];
    end     
        
    %# process the rest nodes in a way
    childNode = childNode.getNextSibling;    
    while ~isempty(childNode)  
        if childNode.getNodeType == childNode.ELEMENT_NODE;  % there are two types of child nodes of a way: nd and tag 
            %# get node id, not all nodes represent ways
            nid = getAttr(childNode,'ref');
            
            if(length(nid) > 0) % it is a "nd", store its id
                nid = str2num(nid);
                ndIds = [ndIds; nid];
            else % it is a "tag", get its attribute
                if(strcmp(getAttr(childNode,'k'),'highway') == 1)
                    %# if this way is a currently addressed type, store it
                    type = checkHighwayType(getAttr(childNode,'v'));
                    if(type > 0)
                        wayInfo = [wayInfo; ndIds; type];
                        len = length(wayAll);
                        wayAll{len+1} = wayInfo;
                        break;
                    end
                end
            end
        end     
        childNode = childNode.getNextSibling;     
    end 
end

%# store all ways
if(false)
    xx_way_pre = wayAll; % xx - city name
    clear wayAll;
    save('tmp.mat','xx_way_pre','-append');
end
clear wayArray;
end




%#------------------------------------------------------------
%# process nodes: after above procedure all highways are stored in wayAll;
%#                however, there exist some nodes on ways that are not in the node list of an osm file
%# output: wayAll_nd - all in-bounds and on-the-way nodes, each row: nd id, nd x, nd y, nd lon, nd lat
%#------------------------------------------------------------
if(false)
%# (In workshop/map_matching/mm.cpp) We first read all nodes within certain range of lat and lon of an osm file and write the transformed coordinates to an external file.
%# We then get wayAll from previous procedure and go through each way to find all unique nodes and look up their coords from the external file.

%# specify a city
load('od.mat','bj_way_pre');
ndAll = dlmread('../data/map_data/bj/nodes_coords'); % read the external file which stores coordinates of all nodes of an osm file
wayAll = bj_way_pre;

%# get all unique nodes but notice not all nodes have lat and lon from the osm file
wayAll_nid = [];
for i = 1:size(wayAll,2)
    wayAll_nid = [wayAll_nid; wayAll{i}(2:end-1)];
end
wayAll_nid = unique(wayAll_nid);

%# find coordinates of all valid nodes of all ways and store them
[~,idx_pre] = ismember(wayAll_nid,ndAll(:,1));
idx = idx_pre(idx_pre~=0);
wayAll_nd = ndAll(idx,:);
  
%# store all valid nodes
if(false)
    xx_node = wayAll_nd; % xx - city name
    save('final.mat','xx_node','-append');
end
end



%#------------------------------------------------------------
%# update ways: after the first procedure above all highways are stored in wayAll;
%#              however there exist some nodes on ways that are not in the node list of an osm file
%# output: wayAll_update - all ways except now each way only contain nodes that have coordinates and contain more than one node; 
%#                         each way has the following information: way id, valid node ids, highway type, freeway flag, oneway flag
%#------------------------------------------------------------
if(false)
%# specify a city
sf = 0;
bj = 1;
assert((sf+bj) == 1, 'Error: multiple citis selected!');

if(sf)
load('od.mat','sf_way_pre','sf_node');
wayAll = sf_way_pre;
ndAll = sf_node;
fwyId = dlmread('/playpen/traffic_dynamics/data/map_data/sf/fwy_ids');
onewayId = dlmread('/playpen/traffic_dynamics/data/map_data/sf/oneway_ids');
end

if(bj)
    load('od.mat','bj_way_pre','bj_node');
    wayAll = bj_way_pre;
    ndAll = bj_node;     
    onewayId = dlmread('/playpen/traffic_dynamics/data/map_data/bj/oneway_ids');
end


wayAll_update = {};  % restore all ways

%sf_way_spec = [];    % store way specification in a mat: way id, way type, way length, fwy flag, oneway_flag
%sf_way_node = []; % store way-node matrix (#way-by-#node)

for i = 1:size(wayAll,2)
    wayId = wayAll{i}(1); % get way id
    wayType = wayAll{i}(end); % get way highway type
     
    wayNd = wayAll{i}(2:end-1); % get original nodes of a way
    wayNd_valid = []; % remove those nodes without coordinates and store the rest
    for j = 1:length(wayNd)
       idx = find(ndAll(:,1) == wayNd(j));
       if(idx > 0)
           wayNd_valid = [wayNd_valid; wayNd(j)];
       end
    end
    
    %# if we have more than one valid node for a way
    if(length(wayNd_valid) > 1)
        %# store way information:   way id, valid node ids, way type, fwy flag, oneway flag
        if(sf)
            fwyFlag = ismember(wayId,fwyId);
        else
            fwyFlag = 0;
        end
        onewayFlag = ismember(wayId,onewayId);
        len = length(wayAll_update);
        wayAll_update{len+1} = [wayId; wayNd_valid; wayType; fwyFlag; onewayFlag];
        
        %# compute way length and store way specification: way id, way type, way length, fwy flag, oneway flag
%         [~,idx2] = intersect(sf_node(:,1),wayNd_update);
%         wayNodeXY = sf_node(idx2,2:3);
%         sumDis = [cumsum(sqrt(diff(wayNodeXY(:,1)).^2 + diff(wayNodeXY(:,2)).^2))];
%         wayLen = sumDis(end);
%         fwy_flag = ismember(wayId,fwyId);
%         oneway_flag = ismember(wayId,onewayId);
%         sf_way_spec = [sf_way_spec; [wayId,wayType,wayLen,fwy_flag,oneway_flag]];
        
        %# store way-node matrix (#way-by-#node)
%         way_node_row = zeros(1,size(sf_node,1));
%         way_node_row(idx2) = 1;
%         sf_way_node = [sf_way_node; way_node_row];
    end
    
end
%# store updated ways
if(false)
    xx_way = wayAll_update; % xx - city name
    clear wayAll_update;
    save('final.mat','xx_way','-append');
end
end



%#------------------------------------------------------------
%# generate edges: produce all edges
%# output: egAll - each row represents an edge with info: start nd idx, end nd idx, start nd xy, end nd xy, way id, highway type, freeway flag, oneway flag
%#------------------------------------------------------------
if(false)
load('od.mat','bj_way','bj_node');
wayAll = bj_way; ndAll = bj_node;
egAll = [];

for i = 1:size(wayAll,2) % each way: way id, valid node ids, highway type, freeway flag, oneway flag
    wayId = wayAll{i}(1); % get way id
    wayNd = wayAll{i}(2:end-3); % get way nodes
    wayInfo = wayAll{i}(end-2:end); % get way info: higway type, freeway flag, oneway flag
    
    for j = 2:length(wayNd)
       sid = find(ndAll(:,1) == wayNd(j-1));
       eid = find(ndAll(:,1) == wayNd(j));
       assert(sid > 0 & eid > 0, 'Error: either sid or eid is wrong!');
       egAll = [egAll; [sid, eid, ndAll(sid,2:3), ndAll(eid,2:3), wayId, wayInfo']];
    end
end
    
%# store the value
if(false)
    bj_edge = egAll; % xx_edge: xx - city name
    save('od.mat','bj_edge','-append');     
end
    
end



%#------------------------------------------------------------
%# generate edges for NYC: NYC is different since all nodes and edges are processed using C++
%# there are some edges in the original links.csv that have the end nodes not in nodes.csv
%#------------------------------------------------------------
if(true)
load('od.mat','ny_node');
fwyId = dlmread('/playpen/traffic_dynamics/data/map_data/ny/fwy_ids');
onewayId = dlmread('/playpen/traffic_dynamics/data/map_data/ny/oneway_ids');
ndAll = dlmread('/playpen/traffic_dynamics/data/map_data/ny/ny_travel_time_work/nodes_tran');
egAll = dlmread('/playpen/traffic_dynamics/data/map_data/ny/ny_travel_time_work/links_tran');

egAll_update = [];

for i = 1:size(egAll,1) 
    sid = find(ndAll(:,1) == egAll(i,1));
    eid = find(ndAll(:,1) == egAll(i,2));
    
    if(sid > 0 & eid > 0)
        fwyFlag = ismember(egAll(i,7),fwyId);
        onewayFlag = ismember(egAll(i,7),onewayId);       
        entry = egAll(i,:);
        entry(1) = sid;
        entry(2) = eid;
        entry(end-1) = fwyFlag;
        entry(end) = onewayFlag;
        egAll_update = [egAll_update; entry];
    end
end
    
%# store the value
if(false)
    ny_edge = egAll_update; % xx_edge: xx - city name
    save('od.mat','ny_edge','-append');     
end
    
end



%#------------------------------------------------------------
%# process ways: (not used, too slow) generate way ids for oneways and fwys
%# input: an osm file
%#------------------------------------------------------------
% if(false)
% 
% % specify a city
% filename = '../data/map_data/sf/sf.osm';
% try
%     mapxml = xmlread(filename);
%     wayArray = mapxml.getElementsByTagName('way');  % get all ways
% catch
%     error('Failed to read XML file %s.', filename)
% end
% 
% onewayId = []; % store oneway ids
% fwyId = [];    % store fwy ids
% for i = 0 : wayArray.getLength-1   
%     %# get a way and its id
%     way = wayArray.item(i); 
%     wayId = str2num(getAttr(way,'id'));
%     
%     %# the first child of a way node is not a real node, so we get its sibling.
%     childNode = way.getFirstChild.getNextSibling;
%     childNode = childNode.getNextSibling;   % process the rest nodes in a way  
%     while ~isempty(childNode)  
%         if childNode.getNodeType == childNode.ELEMENT_NODE;  % there are two types of child nodes of a way: nd and tag 
%             %# get a node tag
%             if(strcmp(getAttr(childNode,'k'),'oneway') == 1)
%                 if(strcmp(getAttr(childNode,'v'),'yes') == 1)  
%                     disp('got an oneway');
%                     onewayId = [onewayId; wayId];
%                 end
%             elseif(strcmp(getAttr(childNode,'k'),'tiger:name_type') == 1 | strcmp(getAttr(childNode,'k'),'tiger:name_type_1') == 1)
%                 if(strcmp(getAttr(childNode,'v'),'Fwy') == 1)    
%                     disp('got a fwy');
%                     fwyId = [fwyId; wayId];
%                 end
%             end
%         end     
%         childNode = childNode.getNextSibling;     
%     end 
% end
% end


%#------------------------------------------------------------
%# process nodes: (not used, too slow) the nodes are transformed using C++
%#------------------------------------------------------------
% if(false)
%     
% filename = '../data/map_data/sf/sf.osm';
% try
%     mapxml = xmlread(filename);
% catch
%     error('Failed to read XML file %s.', filename)
% end
% 
% fprintf('Start addressing nodes...\n');
% ndArray = mapxml.getElementsByTagName('node'); % get all nodes 
% nodes = []; % store node information: id, x-coord(longitude), y-coord(latitude)
% for i = 1 : ndArray.getLength    
%     nd = ndArray.item(i);
%     id = getAttr(nd,'id');
%     
%     if(length(id) > 0)
%         idx = find(node_all == str2num(id));
%         if(idx > 0)
%             y = getAttr(nd,'lat');
%             x = getAttr(nd,'lon');
%             if(length(x) > 0 & length(y) > 0)
%                 nodes = [nodes; [str2num(id),str2num(x),str2num(y)]];
%                 if(size(nodes,1) == size(node_all))
%                     break;
%                 end
%             end
%         end
%     end
% end
% clear ndArray;
% fprintf('Finished addressing nodes!\n');
% end




