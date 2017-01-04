%# This script is to read GPS and TAZ files for coordinate transformation.

clear all; close all; clc;
format long g;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%# write GPS files to external files for coordinate transformation and also write all valid GPS names into a file
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(false)
    gps_path = '../data/gps_data/cabspottingdata/'; % specify gps file path

    write_gps_trace = false; % flag for writing each gps file to external file
    output_gps_trace = '../data/temp/'; % folder for storing written external files

    get_gps_name = false; % flag for storing all gps names
    write_gps_name = false; % flag for writing gps file names to an external file
    output_gps_file_name = '../data/traceName';
    
    if(get_gps_name)
        all_valid_names = {}; % storing all valid gps names
    end

    %# get files
    listing = dir(gps_path); % get all trace names
    gpsTraceNames = { listing.name };
    [~,nFile] = size(gpsTraceNames);

    for i = 1:nFile
        traceName = char(gpsTraceNames(i)); 

        if(length(traceName) > 3 & traceName(1:3) == 'new')       
            disp(traceName);

            if(get_name)
                idx = length(all_valid_names);
                all_valid_names{idx+1} = traceName;
            end

            %# get all points in a trace
            trace = dlmread(strcat(gps_path, char(gpsTraceNames(i))),' ');  

            if(write_gps_trace)
                writeTraceToFile(trace(:,1:2), output_gps_trace, traceName);
            end

        end   
    end

    %# write all valid file names
    if(get_gps_name & write_gps_name)   
        fileID = fopen(output_gps_file_name,'w');
        for i = 1:size(all_valid_names,2)
            fprintf(fileID,'%s\n',all_valid_names{i});
        end
        fclose(fileID); 
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%# write all TAZ shapes to external files for coordinate transformation
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(false)
    load('../../data/mat/sf.mat', 'sfTAZ');
    %# write each individual file
    for i = 1:size(sfTAZ,2)
        fileID = fopen(strcat('../data/temp/taz',int2str(i)),'w');
        for j = 1:size(sfTAZ{i},1)
            fprintf(fileID,'%f %f\n',sfTAZ{i}(j,1),sfTAZ{i}(j,2));
        end
        fclose(fileID); 
    end
    
    %# write all names into a file
    if(false)
    fileID = fopen('../data/temp/tazName','w');
    for i = 1:size(sfTAZ,2)
        fprintf(fileID,'%s\n',strcat('taz',int2str(i)));
    end
    fclose(fileID);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%# read all transformed TAZ files and prepare them for store in a .mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(false)
    tracePath = '../data/new_data/taz/transform/';
    listing = dir(tracePath); % get all trace names
    tazNames = { listing.name };
    [~,nFile] = size(tazNames);
    sfTAZ_trans = {};
    idx = 0;
    for i = 1:nFile

        traceName = char(tazNames(i)); 

        if(length(traceName) > 3 & traceName(1:3) == 'taz')       
            disp(traceName);

            shape = dlmread(strcat(tracePath, char(tazNames(i))),' ');  
            idx = length(sfTAZ_trans);
            sfTAZ_trans{idx+1} = shape;
        end   
    end

    hold all;
    for i = 1:size(sfTAZ_trans,2)
        xy = sfTAZ_trans{i};
        plot(xy(:,1),xy(:,2),'.-');
    end
    hold off;
end







