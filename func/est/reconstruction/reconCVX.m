
%# Note: for t_idx=1:nT can be switched to parfor
function G_cvx = reconCVX(G_tmin, G_tmax, traces_true, method)

% methods:
% 1: l2
% 2: l2+nb_mat
% 3: l1
% 4: l1+nb_mat


%# init
if(method == 2 || method == 4)
    nb_mat = getNbConstraints(G_tmin);
end
offset_exp = 0; % for last cvx constraint
nT = size(traces_true,1);


%# find aggregate average travel time of this network
% disp('Recon cvx: start to find avg net time.');
G_est = G_tmin;
for t_idx=1:nT       
    source = traces_true{t_idx,1}(1);
    target = traces_true{t_idx,1}(2);
    t_true = traces_true{t_idx,1}(3);  
    while(true)       
        [pth_est,t_est] = shortestpath(G_est,source,target);
        if((t_est - t_true) >= -0.01) % ideally, t_est >= t_true
            break;
        end      
        
        update_eIdx = findedge(G_est, pth_est(1:end-1), pth_est(2:end));
        G_est.Edges.Weight(update_eIdx) = t_true / (length(pth_est)-1);        
    end
end
net_avg = mean(G_est.Edges.Weight);


%# setup optimization task
% disp('Recon cvx: setup constraints.');
constraint_all = [];
n_edges = numedges(G_tmin);
% fprintf('total trace %d\n',nT);
for t_idx=1:nT   
    
    source = traces_true{t_idx,1}(1);
    target = traces_true{t_idx,1}(2);
    t_true = traces_true{t_idx,1}(3);     
    G_tmp = G_tmin; % for every trace we reset G_tmp to generate more constraints   
    
    while(true)       
        [pth_est,t_est] = shortestpath(G_tmp,source,target);
        if((t_est - t_true) >= -0.01) % ideally, t_est >= t_true
            break;
        end          
        
        update_eIdx = findedge(G_tmp, pth_est(1:end-1), pth_est(2:end));
        G_tmp.Edges.Weight(update_eIdx) = t_true / (length(pth_est)-1);        
        
        constraint = zeros(1,n_edges+1);
        constraint(update_eIdx) = 1; % set edge variables to 1
        constraint(end) = t_true;
        constraint_all = [constraint_all; constraint];              
    end
end


% convex optimization
% disp('Recon cvx: optimization.');
constraint_all(:,end) = constraint_all(:,end)-1e-5; % to make sure that the aggregate travel times are lower bounds in each constraint
constraint_exp = ones(1,n_edges+1);
constraint_exp(end) = net_avg;

lb = G_tmin.Edges.Weight;
ub = G_tmax.Edges.Weight;
cvx_begin quiet;
    variable sol(n_edges);
    switch method
        case 1
            minimize( norm(sol,2) );
        case 2
            minimize( norm(nb_mat*sol,2) );
        case 3
            minimize( norm(sol,1) );
        case 4
            minimize( norm(nb_mat*sol,1) );
    end
    subject to
    constraint_all(:,1:n_edges)*sol >= constraint_all(:,end);
    constraint_exp(1:n_edges)*sol > n_edges*(constraint_exp(end) - offset_exp);
    constraint_exp(1:n_edges)*sol < n_edges*(constraint_exp(end) + offset_exp);
    lb <= sol <= ub;
cvx_end;

assert(~isnan(mean(sol)),'Error: cvx operation failed!');

G_cvx = G_tmin;
G_cvx.Edges.Weight = sol;

end




