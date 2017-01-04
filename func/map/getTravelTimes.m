%# This script is to get specified edges' travel times and trips by providing the date


function [timesDay, tripsDay] = getTravelTimes(nodes,path,year,month,day)

    %# check variables
    assert(size(nodes,2) == 2, 'Error in xy');
    assert(year>=2010 & year<=2013, 'Error in year');
    assert(month>=1 & month<=12, 'Error in month');

    if(year == 2010)
        if(month == 8 | month == 9)
            disp('Aug and Sep data of 2010 are missing!')
            return;
        end
    end
    
    %# specify the file name
    file = strcat(path,'travel_times_',num2str(year),'/',num2str(month),'/',num2str(day));  
    M = dlmread(file);
    
    timesDay = cell(24,1);
    tripsDay = cell(24,1);
    for i = 1:24
       Mh = M(find(M(:,end) == i),:);
       
       [~,idx] = ismember(nodes, Mh(:,1:2), 'rows');
       nullEdgeIdx = find(idx == 0);
       
       idx(nullEdgeIdx) = 1; % give edges which have no travel times the save time which is the time for the first entry of an hour
       timesHour = Mh(idx,3);
       tripsHour = Mh(idx,4);
       
       timesHour(nullEdgeIdx) = 0; % resign these edges' travel times to 0
       tripsHour(nullEdgeIdx) = 0; 
       
       timesDay{i} = timesHour;
       tripsDay{i} = tripsHour;
    end
    
    

end