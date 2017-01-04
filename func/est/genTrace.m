%# This script is to generate a certain number of synthetic traces. The number is specified by nTrace.

%# Input
%# G - the true network
%# nTrace - the total number of synthetic traces that will be generated

%# Output
%# traces_true - each row stores a trace, in each row the first cell stores [source target travelTime] and the second cell stores edge indcies of the trace (not the node indices).

function traces_true = genTrace(G, nTrace)

    %# for each trace the first cell stores [source target travelTime] and the second cell stores edge indcies of the trace.
    traces_true = cell(nTrace,2); 
    
    %# generate traces
    nNd = numnodes(G);
    count = 1;
    while(count <= nTrace) 
        source = randi([1 nNd],1,1);
        target = randi([1 nNd],1,1);
        if(source ~= target)
            [pth,cost] = shortestpath(G, source, target);        
            traces_true{count,1} = [source, target, cost];
            traces_true{count,2} = getPthEdgeIdx(G,pth);        
            count = count + 1;
        end
    end
       
    %# (not using, this is old code in which traces_true{x,2} stores the trace nodes instead of edge indices) decompose all traces into shorter ones according to a time threshould
    t_thres = -1;
    if(t_thres > 0)
        sum_info = [];
        pth_info = {};

        for i = 1:size(traces_true,1)
            t_time = traces_true{i,1};

            if(t_time(3) > t_thres)
                
                tmp = traces_true{i,2};
                s = tmp(1);
                p_t = tmp(2);
                
                for j = 2:length(tmp)
                    [pth,cost] = shortestpath(G, s, tmp(j));
                    if(cost <= t_thres)
                       p_t = tmp(j);
                    else % store info and update s
                        [pth,cost] = shortestpath(G, s, p_t);
                        sum_info = [sum_info; [s p_t cost]];
                        len = length(pth_info);
                        pth_info{len+1} = pth;
                        s = tmp(j);
                    end

                    if(j == length(tmp) & s ~= tmp(end))
                        [pth,cost] = shortestpath(G, s, tmp(end));
                        sum_info = [sum_info; [s p_t cost]];
                        len = length(pth_info);
                        pth_info{len+1} = pth;
                    end
                end
            else
                sum_info = [sum_info; traces_true{i,1}];
                len = length(pth_info);
                pth_info{len+1} = traces_true{i,2};

            end  
        end
        
        nNewTrace = size(sum_info,1);
        newST = [];
        for k = 1:nNewTrace
            newST = [newST; [pth_info{k}(1) pth_info{k}(end)]];
        end
               
        traces_true = cell(nNewTrace,2);
        for k = 1:nNewTrace
            [pth,cost] = shortestpath(G, newST(k,1), newST(k,2));
            assert(cost <= t_thres | length(pth) == 2, 'Error in t_thres');
            traces_true{k,1} = [newST(k,1), newST(k,2), cost];
            traces_true{k,2} = pth;      
        end
                
        check_traces(G_true,traces_true,t_thres);        
    end

end