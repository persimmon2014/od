%# This script is to get edge indices of a path given the node sequence of that path.

function eidx = getPthEdgeIdx(G,pth)

    eidx = [];
    for k = 1:length(pth)-1      
       eidx = [eidx; findedge(G, pth(k), pth(k+1))];  % findedge returns the edge index in a graph
    end 

end