%# This script is to find mapping nodes after a subgraph is selected
%# input: g_mat is used to generate a graph which has many components, each row has (origin start node id, origin end node id, weights)
%#        h is one of the component and it is in a graph representation

function mapping = getNodesMap(h,g_mat)
    
    assert(size(g_mat,2) == 3, 'Error in g_mat!');
    
    w = h.Edges.Weight;
    [~,idx] = ismember(w,g_mat(:,3));
    mapping = [h.Edges.EndNodes g_mat(idx,:)];

end