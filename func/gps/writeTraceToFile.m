%# This script is write GPS traces to an external file for coordinates transform
%# input: 
%# trace - GPS trace data, the first two columns specify longtidue and latitude
%# filePath - output filepath
%# filename - output filename

function [] = writeTraceToFile(trace,filepath,filename)

    fileID = fopen(strcat(filepath,filename),'w');
    for i = 1:size(trace,1) 
        fprintf(fileID,'%f %f\n',trace(i,1),trace(i,2));
    end
    
    fclose(fileID);

end