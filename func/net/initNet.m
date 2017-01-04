%# This script is to generate initial graph with different weights

function [G_tmin, G_tmax, G_len] = initNet(edges)

    %# compute edge lengths
    e_len = distance(edges(:,3:4), edges(:,5:6));
    
    %# use edge lengths to get rid of duplicate edges
    [~,ia,~] = unique(e_len);
    e_len = e_len(ia);
    edges = edges(ia,:);

    %# arterial roads: 18m/s=40mph, 11.2m/s=25mph (speed limit)
    e_tmin = e_len ./ 27; % assume the actual maximum speed on arterial roads is 60mph     
    e_tmax = e_len ./ 1;

    %# free ways: 36m/s=80mph (computed maximum speed from all loop data), 29.2m/s=65mph (speed limit)
    fwy_id = find(edges(:,end-1) == 1);
    e_tmin(fwy_id) = e_len(fwy_id) ./ 36;

    %# produce the connected graph      
    G_tmin = graph(edges(:,1), edges(:,2), e_tmin);
    G_tmax = graph(edges(:,1), edges(:,2), e_tmax);
    G_len  = graph(edges(:,1), edges(:,2), e_len);
    
end





