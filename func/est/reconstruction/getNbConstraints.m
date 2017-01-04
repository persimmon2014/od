% This script is to generate the matrix for each row that has 1 and -1 in
% order to force variables equal to each other in either l1 or l2 sense


function nbMat = getNbConstraints(G)

n_nodes = numnodes(G);
n_edges = numedges(G);


pre_mat = [];
for i = 1:n_nodes
    N = neighbors(G,i); % find all neighbor node ids for a node
    N2 = [ones(length(N),1)*i N]; % current node to neighbor node pairs 
    E = findedge(G,N2(:,1),N2(:,2)); % find edge ids for all edges that connects to a node
    
    if(length(E) > 1)
    E2 = nchoosek(E,2);
    
        for j = 1:size(E2,1)
           tmp = zeros(1,n_edges);
           tmp(E2(j,1)) = 1;
           tmp(E2(j,2)) = -1;
           pre_mat = [pre_mat; tmp];
        end
        
    end
end


nbMat = unique(pre_mat,'rows');

row_check = sum(nbMat,2); % sum by rows
assert(numel(find(row_check == 0)) == size(nbMat,1), 'Error!');

end