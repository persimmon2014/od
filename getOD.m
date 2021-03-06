%# This script is get spreaded nodes in a spatial region as origins and destinations according to TAZs

%# Output
%# nd_retain - nearest nodes to spreaded TAZs, [node id, node xy, node origin id, matched TAZ origin id]

function nd_retain = getOD(xy_bounds, tazAll, egs, thres)

    % get all TAZ centers within a spatial region, however the TAZs may be
    % too dense to be useful
    taz_ctrs = []; 
    for i = 1:size(tazAll,2)
        taz_xy = mean(tazAll{i});
        if(taz_xy(1) >= xy_bounds(1) & taz_xy(1) <= xy_bounds(2) & taz_xy(2) >= xy_bounds(3) & taz_xy(2) <= xy_bounds(4))
            taz_ctrs = [taz_ctrs; [i taz_xy]];
        end
    end

    
    % retain certain TAZ ctrs and exlude others to make sure these ctrs are
    % well spreaded according to a pre-specified distance threshold.
    nc = size(taz_ctrs,1);
    taz_retain = [];
    taz_exclude = [];
    for i = 1:nc

        taz_id = taz_ctrs(i,1);
        taz_xy = taz_ctrs(i,2:3);
        dis = distance(taz_xy, taz_ctrs(:,2:3));
        near_idx = find(dis <= thres);

        if(length(near_idx) == 1) % if only itself is the near nodes, retain this taz
            taz_retain = [taz_retain; taz_ctrs(i,:)];
        else % if there are other taz ctrs nearby
            diff_taz_idx = setdiff(taz_ctrs(near_idx,1),taz_id);
            taz_exclude = [taz_exclude; diff_taz_idx]; % put other ctrs in an exclusion list
            if(~ismember(taz_id,taz_exclude)) % if the current ctr is the first one we found in a dense ctr area, retain it
                taz_retain = [taz_retain; taz_ctrs(i,:)];
            end
        end
    end
    
    
    %# for each retained taz find its nearest node
    taz_nd = [];
    nd_region = [egs(:,[1 3 4 11]); egs(:,[2 5 6 12])];
    nd_region = unique(nd_region,'rows');
    for i = 1:size(taz_retain,1)
       [~,n] = min(distance(taz_retain(i,2:3), nd_region(:,2:3)));
       
       nd_xy = nd_region(n,2:3);
       if(nd_xy(1) >= xy_bounds(1) & nd_xy(1) <= xy_bounds(2) & nd_xy(2) >= xy_bounds(3) & nd_xy(2) <= xy_bounds(4))
          taz_nd = [taz_nd; [nd_region(n,:) taz_retain(i,1)]];
       end
    end
    
    
    %# make sure the matched nodes are spreaded again
    nd = size(taz_nd,1);
    nd_retain = [];
    nd_exclude = [];
    for i = 1:nd

        nd_id = taz_nd(i,1);
        nd_xy = taz_nd(i,2:3);
        dis = distance(nd_xy, taz_nd(:,2:3));
        near_idx = find(dis <= thres);

        if(length(near_idx) == 1)
            nd_retain = [nd_retain; taz_nd(i,:)];
        else 
            diff_nd_idx = setdiff(taz_nd(near_idx,1),nd_id);
            nd_exclude = [nd_exclude; diff_nd_idx];
            if(~ismember(nd_id,nd_exclude)) 
                nd_retain = [nd_retain; taz_nd(i,:)];
            end
        end
    end

end

