

function [final_weights, final_mse] = kernelEst(G_est, G_true, G_tmin, traces_est)

% decompose and allocation
est_weights = G_est.Edges.Weight;
true_weights = G_true.Edges.Weight;
min_weights = G_tmin.Edges.Weight;

final_weights = est_weights;

nTrace = size(traces_est,1);
edge_time_pairs = [];
for k = 1:nTrace    

    pth_est_time = traces_est{k,1}(3);
    pth_eIdx = traces_est{k,2};
    
    pth_alloc = min_weights(pth_eIdx);
    pth_alloc_ratio = pth_alloc ./ sum(pth_alloc);
    pth_alloc_time = pth_est_time .* pth_alloc_ratio;
    
    edge_time_pairs = [edge_time_pairs; [pth_eIdx pth_alloc_time]];       
end

% estimation
for i = 1:length(est_weights)
    t = edge_time_pairs(find(edge_time_pairs(:,1) == i),2);
    if(var(t) > 1e-3)
        [~,xi] = ksdensity(t);
        final_weights(i) = mean(xi);
    end
end


final_mse = immse(true_weights, final_weights);

end