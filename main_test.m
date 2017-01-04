%# This script is the main interface to test the new approach.

clear all; close all; clc
addpath(genpath('./func/'));
addpath(genpath('../ue/func/'));

%# ------------------------------------
%# setup a network
%# ------------------------------------
s  = [1 1 2 2 3 3 4 4 5 5 5 5 6 6 6 7 7 7 8 8 8 9 9 9]; % starting nodes
t  = [6 7 6 8 7 9 8 9 6 7 8 9 1 2 5 1 3 5 2 4 5 3 4 5]; % ending nodes
e_tmin = [6 8 7 8 8 6 7 7 7 6 8 6 6 7 7 8 8 6 8 7 8 6 7 6]; % link free flow travel times
e_cap = [1500 1500 1500 1500 1500 1500 1500 1500 2000 2000 2000 2000 1500 1500 2000 1500 1500 2000 1500 1500 2000 1500 1500 2000]; % link capacities

% s  = [1 1 2 2 3 3 4 4 5 5 5 5]; % starting nodes
% t  = [6 7 6 8 7 9 8 9 6 7 8 9]; % ending nodes
% e_tmin = [6 8 7 8 8 6 7 7 7 6 8 6]; % link free flow travel times
% e_cap = [1500 1500 1500 1500 1500 1500 1500 1500 2000 2000 2000 2000];

e_len = e_tmin.*27; % 27m/s = 60mph
e_tmax = e_len./1;
net = [s' t' e_tmin' e_cap'];

G_tmin = digraph(s,t,e_tmin);
G_tmax = digraph(s,t,e_tmax);
G_len  = digraph(s,t,e_len);




%# ------------------------------------
%# setup an OD matrix, solve UE, get the true times of links, and build the true network
%# ------------------------------------
n = max(max(net(:,1:2)));
od = sparse(n,n);
od(1,2) = 500;  od(1,3) = 600;  od(1,4) = 500;  od(1,5) = 1000;
od(2,1) = 500;  od(2,3) = 400;  od(2,4) = 500;  od(2,5) = 1100;
od(3,1) = 400;  od(3,2) = 500;  od(3,4) = 500;  od(3,5) = 1100;
od(4,1) = 500;  od(4,2) = 500;  od(4,3) = 400;  od(4,5) = 1000;
od(5,1) = 1000; od(5,2) = 1200; od(5,3) = 1200; od(5,4) = 1000;
[lk_flows,lk_times,~,~] = uefw(net, od, 3, 'ue'); % compute the true flow and travel times
[sid,eid,ue_times] = find(lk_times{end});
G_true = G_tmin; % build G_true
for i = 1:length(sid)
    idx = findedge(G_len, sid(i), eid(i)); 
    G_true.Edges.Weight(idx) = ue_times(i);
end



%# ------------------------------------
%# get the true od pairs (tplus) and the target od pairs (tbar)
%# ------------------------------------
[od_sid,od_eid,tplus] = find(od); % find elements of the true OD matrix in vector form
cvt = 0.2; % random error between true and target OD matrices
tnoise = normrnd(0,1,[length(tplus),1]);
tbar = tplus.*(1-cvt*tnoise); % construct the target od by modifiying the true od
[rmse_bar,rmse_perc,mae_perc] = computeErrors(tplus,tbar);
fprintf('Initial estimation rmse=%f, rmse(perc)=%f, mae(perc)=%f\n', rmse_bar, rmse_perc, mae_perc);
od_vec = [od_sid,od_eid,tbar]; % store the target od pairs
assert(sum(tbar>=0) == length(tbar), 'Error: some modified od pairs are negative!');



%# ------------------------------------
%# compute the true link flow, pertube it to get observed flows
%# ------------------------------------
obs = [1 3 6 8 10 11 13 14 18 21 22 23]; % observed links
[l_sid,l_eid,l_flow] = find(lk_flows{end});
ob_idx = [];
for i = 1:length(obs)
    [~,idx] = ismember([s(obs(i)) t(obs(i))], [l_sid l_eid], 'rows');
    ob_idx = [ob_idx; idx];
end
vplus = l_flow(ob_idx); % ground truth link flows



%# ------------------------------------
%# generate synthetic traces and use them to reconstruct the travel times
%# ------------------------------------
traces_true = genTrace(G_true, 20);    
[traces_sd, mm_info_sd] = mapMatching(G_tmin, G_len, traces_true);

p = plot(G_true,'EdgeLabel',G_true.Edges.Weight);

%# Get weights and error rates
[weights_my, mse_my, ~] = trafficMY(G_tmin, G_tmax, G_len, G_true, traces_true, 1, 1, 10, 1, 10); % cvx_method, mm_method, my_iter, em_iter, em_samples
[weights_em, mse_em]    = trafficEM(G_tmin, G_true, traces_sd, 1, 10); %  em_iter, em_samples
[weights_kl, mse_kl]    = kernelEst(G_tmin, G_true, G_tmin, traces_sd);

% [G_true.Edges.Weight weights_my weights_em weights_kl]



vbar_my = invbpr(weights_my,e_tmin,e_cap);
vbar_em = invbpr(weights_em,e_tmin,e_cap);
vbar_kl = invbpr(weights_kl,e_tmin,e_cap);

vbar_my = vbar_my(obs);
vbar_em = vbar_em(obs);
vbar_kl = vbar_kl(obs);


%# ------------------------------------
%# step 0: init P, U, V
% U = eye(size(od_vec,1));
% V = eye(size(vbar_my,1));
% 
% % U = diag((cvt.*tplus).^2);
% % V = diag((cvf.*vplus).^2);
% 
% P_update = computeP(net,od_vec,ob_idx);
% 
% vbar = vbar_kl;
% gls_iter = 5;
% for i = 1:gls_iter
%     tupdate = inv((inv(U) + P_update'*inv(V)*P_update))*(inv(U)*tbar + P_update'*inv(V)*vbar);   
%     od_vec_update = [od_sid,od_eid,tupdate];
%     P_update = computeP(net,od_vec_update,ob_idx);
%     [rmse,rmse_perc,mae_perc] = computeErrors(tplus,tupdate);
%     fprintf('Iter %d: rmse=%f, rmse(perc)=%f, mae(perc)=%f, rmse_delta=%f\n', i, rmse, rmse_perc, mae_perc, (rmse_bar-rmse)/rmse_bar);
% end




