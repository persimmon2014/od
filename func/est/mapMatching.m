%# This script computes the accuracy of map-matching algorithm and collects estimated traces and their travel times.

%# Input
%# G_est: network with estimated travel times
%# G_len: network with link lengths
%# traces_true: each row represents a trace and each trace has two cells. The first one is [s t time] and the second stores edge indices of the trace. 
%# method: 1-shortest travel time using G_est; 2-shortest distance using G_len; 3-best matching time using G_est

%# Output
%# traces_est: the same as traces_true, however here we use estimated traces instead of true traces information
%# mm_info: the first is succ_rate which stores map-matching accuracy (# of successfully identified links)/(# of links in a true path)
%#          the second is time_diff which stores time difference between estimated time and true time

%# TODO: the method 2 and 3 are disabled for now, the method 2 take the shortest distance which is equivalent to shortest travel time path on G_tmin providing homogeneous speed limit
function [traces_est, mm_info] = mapMatching(G_est, G_len, traces_true, methodIdx)

if nargin > 3
    method = methodIdx;
    assert(method>0 & method<4, 'Error: error in specifying method');
else
    method = 1;
end

nTrace = size(traces_true,1);
traces_est = cell(nTrace,2); % for each trace the first stores [s t time] and the second cell stores edge indices of the trace.

mm_info = [];
for i=1:nTrace
        
    source = traces_true{i,1}(1);
    target = traces_true{i,1}(2);
    t_true = traces_true{i,1}(3);
       
    switch method
        case 1
            [pth_est,t_est] = shortestpath(G_est,source,target);
        case 2
            [pth_est,t_est] = shortestpath(G_len,source,target);
        case 3            
            e_spd_max = 27;
            [pth_est,t_est] = astar_syn_len(G_est, G_len, e_spd_max, source, target, t_true);
    end
 
    if(0)
        figure('name','est');
        h = plot(G_recon,'EdgeLabel',G_est.Edges.Weight,'LineWidth',2,'NodeLabel',{});
        highlight(h,pth_est,'NodeColor','r','MarkerSize',6);
        highlight(h,pth_est,'EdgeColor','g');
        set(gcf,'position',[1250 100 550 400]);
    end     
   
    % store results  
    eIdx_est  = getPthEdgeIdx(G_len,pth_est); %# edge indices of an estimated edge             
    traces_est{i,1} = [source, target, t_est];
    traces_est{i,2} = eIdx_est;     
    
    % compute map-matching accuracy
    eIdx_true = traces_true{i,2}; %# edge indices of a true edge 
    n_succ_edge = length(intersect(eIdx_est,eIdx_true));
    mm_info = [mm_info; [n_succ_edge/length(eIdx_true) t_est-t_true]];
end


end

