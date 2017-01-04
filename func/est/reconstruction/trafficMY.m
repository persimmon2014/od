
function [final_weights, log_mse, log_mm] = trafficMY(G_tmin, G_tmax, G_len, G_true, traces_true, cvx_method, mm_method, my_iter, em_iter, em_samples)

quiet = true;

%# cvx_method: 1-2norm; 2-2norm+lasso; 3-1norm; 4-1norm+lasso
if(cvx_method > 0)
    G_iter = reconCVX(G_tmin, G_tmax, traces_true, cvx_method);
else
    G_iter = G_tmin;
end

[traces_est, mm_info] = mapMatching(G_iter, G_len, traces_true);

log_mse = [immse(G_iter.Edges.Weight,G_true.Edges.Weight)];
log_mm = {mm_info}; 


if(my_iter > 0)
    if(~quiet)
        fprintf('Start to iterate...\n');
    end
    for k = 1:my_iter

        [weights_em, mse_em] = trafficEM(G_iter, G_true, traces_est, em_iter, em_samples);
        [traces_est, mm_info] = mapMatching(G_iter, G_len, traces_true);
        G_iter.Edges.Weight = weights_em; 

        log_mse = [log_mse; mse_em]; 
        len = length(log_mm);
        log_mm{len+1} = mm_info;

        if(~quiet)
            fprintf('Iteration %d: net mse = %f, mean acc=%f, std acc=%f, mean time diff=%f, std time diff = %f\n',k, update_mse, mm_acc(1), mm_acc(2), mm_acc(3), mm_acc(4));
        end
    end
end

final_weights = G_iter.Edges.Weight;

if(~quiet)
    fprintf('Finished iterating.\n');
end

end



