%# This script is to draw networks of a city by providing spatial ranges and highway types


function [] = drawNet(wayAll, ndAll, hwyTypes, lon, lat)

    if(nargin<4)
        lon = [-1 -1];
        lat = [-1 -1];
    end
    
    ndVis = [];
    for i = 1:length(wayAll)
        wayId = wayAll{i}(1);
        wayType = wayAll{i}(end-2); % way id, valid node ids, way type, fwy flag, oneway flag

        if(ismember(wayType,hwyTypes))
            [~,idx] = intersect(ndAll(:,1),wayAll{i}(2:end-1));
            ndVis = [ndVis; idx];
        end    
    end
    scatter(ndAll(ndVis,2),ndAll(ndVis,3),'.')

    



end