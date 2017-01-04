%# This script is to read flow, occupancy, and speed of a loop

function result = readLoopData(loopId, dType, filepath)

    %# specify filepath according to a data type
    if(strcmp(dType,'flow'))
        filepath = strcat(filepath, 'flow/'); 
    elseif(strcmp(dType,'occupancy'))
        filepath = strcat(filepath, 'occupancy/'); 
    elseif(strcmp(dType,'speed'))
        filepath = strcat(filepath, 'speed/'); 
    end

    %# read and process a loop file. Note: 401018 is missing three fridays data.
    result = zeros(168,1);
    filename = strcat(filepath, num2str(loopId));
    fid = fopen(filename,'r'); 
    dataStr = textscan(fid,'%s','delimiter','\n','whitespace',' ','HeaderLines',1); 
    data = processLoopData(dataStr);
    
    if(length(data) == 504)
        result = (data(1:168) + data(169:336) + data(337:end))./3;
    else % address 401018
        result(1:120) = (data(1:1+119) + data(145:145+119) + data(289:289+119))./3;
        result(145:168) = (data(121:121+23) + data(265:265+23) + data(409:409+23))./3;
    end
    fclose(fid);
    assert(length(result) > 0, 'Error: reading loop data failed!');

end