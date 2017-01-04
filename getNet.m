%# This script is to get a connected graph within a spatial range and of specified highway types

%# Output
%# egs_final - renumbered edge start node id, renumbered edge end node id, start node xy, end node xy, 
%#             way id, highway type, freeway flag, oneway flag, original start node id, original end node id

function [egs_final,xy_bounds] = getNet(egAll,ndAll,lon,lat,hwyTypes,compIdx)

    %# get in-bounds and specific highway edges
    [egs, xy_bounds] = getInBoundHwyEdges(egAll,ndAll,lon,lat,hwyTypes); % egs_bounds is the max and min xy values of all edges


    %# get all nodes of valid edges, renumbering them
    nd_ids = unique([egs(:,1); egs(:,2)]);
    nds = [[1:length(nd_ids)]' nd_ids ndAll(nd_ids,2:3)]; % renumbered id, original id, original xy


    %# use the renumbered nodes to build a graph
    [~,idx1] = ismember(egs(:,1), nd_ids);
    [~,idx2] = ismember(egs(:,2), nd_ids);
    egSub = [idx1 idx2 egs(:,3:end)];
    %drawEg(egSub(:,3:4), egSub(:,5:6));


    %# use all valid edges to build a graph, however this graph is likely to contain multiple components, we get one of its components
    [G_pre,~,~] = initNet(egSub); 
    [~,G_sub_nd] = getComponent(G_pre,compIdx);

    %# second round nodes renumbering and edges updating
    nds_final = nds(G_sub_nd,:);
    nds_final = [[1:size(nds_final,1)]' nds_final(:,2:end)];
    [~,idx1] = ismember(egs(:,1), nds_final(:,2));
    [~,idx2] = ismember(egs(:,2), nds_final(:,2));
    egSub_pre = [idx1 idx2 egs(:,3:end)];
    egs_final = [];
    for i = 1:size(egSub_pre,1)
        if(egSub_pre(i,1) == 0 | egSub_pre(i,2) == 0)
            continue;
        end
        egs_final = [egs_final; [egSub_pre(i,:) nds_final(idx1(i),2) nds_final(idx2(i),2)]];
    end

end