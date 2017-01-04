%# This script is to compute the proportional matrix P


function P = computeP(net,od_vec,ob_idx)
    
    %# setup and convert od vector form to matrix form
    n = max(max(net(:,1:2)));
    od_mat = sparse(od_vec(:,1),od_vec(:,2),od_vec(:,3),n,n);
    n_iter = 3;
    n_od = size(od_vec,1);
    
    %# assign od_mat to get link_flows 
    [link_flows,~,aux_info,log] = uefw(net, od_mat, n_iter, 'ue'); % compute the true flow

    %# collect all link flow assignments information
    aux_info_all = [];
    for i = 1:n_iter
        aux_info_all = [aux_info_all; aux_info{i}];
    end

    %# address each od pair, collect link flow assignments
    od_info_all = cell(n_od,1);
    for k = 1:n_od
        o_id = od_vec(k,1);
        d_id = od_vec(k,2);

        %# for an od pair, we find all unique links involved in flow assignments of all iterations
        od_link_all = getInfo(o_id,d_id,aux_info_all);

        %# for each iteration, we find which links got assigned the flow
        od_info = od_link_all;
        for i = 1:n_iter
            %# for an od pair, we find all links involved in flow assignments at each iteration
            od_link_iter = getInfo(o_id,d_id,aux_info{i});

            %# attach a column with zero values to the end
            od_info = [od_info zeros(size(od_info,1),1)];

            %# find which links got the flow and attach the flow value between this od pair
            [~,idx] = ismember(od_link_iter(:,3:4),od_link_all(:,3:4),'rows');
            od_info(idx,end) = od_vec(k,3);
        end

        portion = zeros(size(od_info,1),1);
        for i = 1:n_iter
            portion = portion.*(1-log(i,1)) + od_info(:,end-n_iter+i).*log(i,1); 
        end

        od_info = [od_info portion./od_info(:,5)];
        od_info_all{k} = od_info;
    end


    [l1,l2,l3] = find(link_flows{end});
    l_flow = [l1 l2 l3];

    %# Here we construct the proportional matrix P, we fill the matrix row by row
    n_link = length(l1);
    P_full = zeros(n_link,n_od);
    for i = 1:n_link

        l_sid = l_flow(i,1);
        l_eid = l_flow(i,2);

        %# fill each column value of a single row
        for j = 1:n_od
            od_info = od_info_all{j};
            [~,idx] = ismember([l_sid l_eid], od_info(:,3:4), 'rows');
            if(idx > 0)
                P_full(i,j) = od_info(idx,end);
            end
        end

    end

    assert(sum(l_flow(ob_idx,3)-P_full(ob_idx,:)*od_vec(:,end))<1e-3, 'Error: P is wrong!');
    
    P = P_full(ob_idx,:);

end