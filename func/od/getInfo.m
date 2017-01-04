%# This script is to get a subset of pre_info which only regards the od pair specified by o_id and d_id.

function info = getInfo(o_id,d_id,info_all)

    o_idx = find(info_all(:,1) == o_id);
    d_idx = find(info_all(:,2) == d_id);
    od_idx = intersect(o_idx,d_idx);
    info = info_all(od_idx,:);
    info = unique(info,'rows');

end