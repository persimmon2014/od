%# This script is to get zone indices of an od pair from a trace. The first and last points of a trace are treated as the O and D, respectively.

function od_pair = extractOD(trace,all_poly)

    od_pair = [];
    nPoly = size(all_poly,2);
    
    %# treat the first point of a trace as a O, and find its zone idx
    o = [];
    for k = 1:nPoly
        if(inpolygon(trace(1,1),trace(1,2),all_poly{k}(:,1),all_poly{k}(:,2)))
            o = [trace(1,:) k]; % x,y,time,zone idx
            break;
        end
    end
    
    %# if we can find the zone idx of the O, next we treat the last point of a trace as a D, and find its zone idx
    d = [];
    if(length(o) > 0)
        for k = 1:nPoly
            if(inpolygon(trace(end,1),trace(end,2),all_poly{k}(:,1),all_poly{k}(:,2)))
                d = [trace(end,:) k]; % x,y,time,zone idx
                break;
            end
        end
    end
        
    %# return od pair zone indices
    if(length(d) > 0)
        od_pair = [o d];
    end
            

end