%# This script is to write a matrix to an external file.

function [] = writeMatToFile(mat, formatSpec, outfile)

    fileID = fopen(outfile,'w');
    for i = 1:size(mat,1)
        fprintf(fileID,formatSpec,mat(i,:));
    end
    
    fclose(fileID);

end