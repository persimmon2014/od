
function [final_weights, final_mse] = trafficEM(G_est, G_true, traces_est, n_iter, n_samples)

% mean_prior = ones(n_edge,1) * (150/(17.88*0.7));
% var_prior = ones(n_edge,1) * 60; % 3600?

%# ----- variables -----
% n_iter = 1; % number of iterations for EM
% n_samples = 100; % during one iteration of EM, each sample is a division of an aggregate travel time to its consititution links
%# --------------------

quiet = true;

est_weights = G_est.Edges.Weight;
true_weights = G_true.Edges.Weight;

n_edge = length(est_weights);
%net_avg = mean(est_weights);

init_mean = est_weights; %# inital mean
init_var = ones(n_edge,1) * var(est_weights); %# initial variance
%init_var = ones(n_edge,1);

theta_all = init_var ./ init_mean;
k_all = init_mean ./ theta_all;

iter_weights = est_weights;
iter_mse = immse(true_weights, iter_weights);
mse_all = [iter_mse];

if(~quiet)
    fprintf('Starting traffic EM...\n');
    fprintf('Iteration 0: mse = %f\n', iter_mse);
end

for iter = 1:n_iter
        
    % estimate true aggregate time for each path
%     modify_time = [];    
%     for k = 1:length(traces_est)        
%         pth_eIdx = traces_est{k};
%         pth_time = sum(true_weights(pth_eIdx));
%         %pth_time = traces_time(k);
% 
%         %lambda = round(length(pth_eIdx)*net_avg - pth_time);
%         %modify_time = [modify_time; pth_time + sign(lambda) * poissrnd(abs(lambda))];
%         modify_time = [modify_time; pth_time];
%     end
    
    % E-step
    edge_time_pairs = [];
    nTrace = size(traces_est,1);
    for k = 1:nTrace        
        
        pth_est_time = traces_est{k,1}(3);
        pth_eIdx = traces_est{k,2};
       
        for kk = 1:n_samples
           tmps = gamrnd(k_all(pth_eIdx),theta_all(pth_eIdx)./pth_est_time);
           edge_time_samples = pth_est_time * (tmps / sum(tmps));
           edge_time_samples(find(edge_time_samples < 1e-3)) = 1e-3;
           weights = gampdf(tmps,k_all(pth_eIdx),theta_all(pth_eIdx)); 
           if(~quiet)
           if(abs(sum(edge_time_samples)-pth_est_time) >= 1e-2)
               disp('Warning: sum of sampled times is not equal to the aggregate time!');
           end
           end
           edge_time_pairs = [edge_time_pairs; [pth_eIdx edge_time_samples]];           
        end     
    end

    % M-step
    for i = 1:n_edge
        t = edge_time_pairs(find(edge_time_pairs(:,1) == i),2);
        if(var(t) > 1e-3)
            [p, ~] = gamfit(t);
            k_all(i) = p(1);
            theta_all(i) = p(2);
            if(~isfinite(k_all(i)) || ~isfinite(theta_all(i)))
               disp('Error: either k_all or theta_all contains an invalid value!');
            end
        end
    end

    
    iter_weights = k_all.*theta_all;
    iter_mse = immse(true_weights, iter_weights);
    if(~quiet)
        fprintf('Iteration %d: mse = %f\n', iter, iter_mse);
    end
    mse_all = [mse_all; iter_mse];
    
end
if(~quiet)
    fprintf('Finishing traffic EM.\n');
end
    final_weights = k_all.*theta_all;
    final_mse = immse(true_weights, final_weights);

end