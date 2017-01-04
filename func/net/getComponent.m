%# This script is to get the ith large connected component within h

%# Input
%# h - the original graph which we are going to take a component of
%# idx - the idx-th largest component

%# Output
%# h_sub - a strongly connected component
%# h_sub_nd_idx - the node indices of h_sub that are originally in h

function [h_sub, h_sub_nd_idx] = getComponent(h,idx)

    if(nargin > 1)
        compIdx = idx;
    else 
        compIdx = 1;
    end

    assert(compIdx > 0, 'Error: compIdx is wrong!');
    bins = conncomp(h);
    h_sub_nd_idx = find(bins == compIdx);
    h_sub_nd_idx = h_sub_nd_idx';
    nComp = [1:numel(unique(bins))]';
    for i = 1:numel(unique(bins))
        nComp(i,2) = numel(find(bins == i));   
    end
    nComp = flip(sortrows(nComp,2));
    
    h_sub = rmnode(h, find(bins ~= nComp(compIdx,1)));
    assert(numel(unique(conncomp(h_sub))) == 1, 'Error: the graph is not strongly connected!');

end