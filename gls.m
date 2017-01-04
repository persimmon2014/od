%# This script is to test GLS estimator on OD pairs.

clear all; close all; clc;
addpath(genpath('./func/'));
addpath(genpath('../ue/func/'));
rng('default');



%# ------------------------------------
%# setup a network
%# ------------------------------------
s  = [1 1 2 2 3 3 4 4 5 5 5 5 6 6 6 7 7 7 8 8 8 9 9 9]; % starting nodes
t  = [6 7 6 8 7 9 8 9 6 7 8 9 1 2 5 1 3 5 2 4 5 3 4 5]; % ending nodes
ft = [6 8 7 8 8 6 7 7 7 6 8 6 6 7 7 8 8 6 8 7 8 6 7 6]; % link free flow travel times
cap = [1500 1500 1500 1500 1500 1500 1500 1500 2000 2000 2000 2000 1500 1500 2000 1500 1500 2000 1500 1500 2000 1500 1500 2000]; % link capacities
net = [s' t' ft' cap'];



%# ------------------------------------
%# setup an OD matrix, construct its vector form, and pertube it to get a target OD vector
%# ------------------------------------
n = max(max(net(:,1:2)));
od = sparse(n,n);
od(1,2) = 500; od(1,3) = 600; od(1,4) = 500; od(1,5) = 1000;
od(2,1) = 500; od(2,3) = 400; od(2,4) = 500; od(2,5) = 1100;
od(3,1) = 400; od(3,2) = 500; od(3,4) = 500; od(3,5) = 1100;
od(4,1) = 500; od(4,2) = 500; od(4,3) = 400; od(4,5) = 1000;
od(5,1) = 1000; od(5,2) = 1200; od(5,3) = 1200; od(5,4) = 1000;

[od_sid,od_eid,tplus] = find(od); % find elements of the true OD matrix in vector form
n_od = length(od_sid); % number of valid od pairs

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
[link_flows,~,~,~] = uefw(net, od, 3, 'ue'); % compute the true flow
cvf = 0.20; % random error between traffic counts

obs = [1 3 6 8 10 11 13 14 18 21 22 23]; % observed links
vnoise = normrnd(0,1,[length(obs),1]);

[l_sid,l_eid,l_flow] = find(link_flows{end});
ob_idx = [];
for i = 1:length(obs)
    [~,idx] = ismember([s(obs(i)) t(obs(i))], [l_sid l_eid], 'rows');
    ob_idx = [ob_idx; idx];
end
vplus = l_flow(ob_idx);         % ground truth link flows
vbar  = vplus.*(1-cvf.*vnoise); % observed link flows



%# ------------------------------------
%# step 0: init P, U, V
% U = eye(size(od_vec,1));
% V = eye(size(vbar,1));

U = diag((cvt.*tplus).^2);
V = diag((cvf.*vplus).^2);

P_update = computeP(net,od_vec,ob_idx);

gls_iter = 5;
for i = 1:gls_iter
    tupdate = inv((inv(U) + P_update'*inv(V)*P_update))*(inv(U)*tbar + P_update'*inv(V)*vbar);   
    od_vec_update = [od_sid,od_eid,tupdate];
    P_update = computeP(net,od_vec_update,ob_idx);
    [rmse,rmse_perc,mae_perc] = computeErrors(tplus,tupdate);
    fprintf('Iter %d: rmse=%f, rmse(perc)=%f, mae(perc)=%f, rmse_delta=%f\n', i, rmse, rmse_perc, mae_perc, (rmse_bar-rmse)/rmse_bar);
end
















  


