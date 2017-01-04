%# This script is to get in-bounds and specific highway edges providing all edges and a spatial range

function [egs, xy_bounds] = getInBoundHwyEdges(egAll,ndAll,lon,lat,hwyTypes)

%# Coordinates used in original ITS submission (not the later ITS submission) downtown SF
% lon = [-122.4467 -122.3782];
% lat = [37.7711 37.8118];

sll = ndAll(egAll(:,1),4:5); % link starting node lon and lat
ell = ndAll(egAll(:,2),4:5); % link ending node lon and lat
egLonLat = [egAll sll ell];
sidx = find(egLonLat(:,11) >= lon(1) & egLonLat(:,11) <= lon(2) & egLonLat(:,12) >= lat(1) & egLonLat(:,12) <= lat(2)); % find in-bounds starting nodes
eidx = find(egLonLat(:,13) >= lon(1) & egLonLat(:,13) <= lon(2) & egLonLat(:,14) >= lat(1) & egLonLat(:,14) <= lat(2)); % find in-bounds starting nodes
fidx = intersect(sidx,eidx); % final valid link indices within egAll

egs = egAll(fidx,:);

if(nargin > 4)
    %# extract edges that belong to specified highway types
    [~,idx1] = ismember(egs(:,8),hwyTypes);
    idx2 = find(idx1 > 0);
    egs = egs(idx2,:);
    
end


%# get XY bounds of egs
minx = min(min([egs(:,3),egs(:,5)])); maxx = max(max([egs(:,3),egs(:,5)]));
miny = min(min([egs(:,4),egs(:,6)])); maxy = max(max([egs(:,4),egs(:,6)]));
xy_bounds = [minx,maxx,miny,maxy];

end