%# This script is to divide travel times of a month into individual days (NY data).
%# for 2012: Feb days should be 29
%# for 2010: Aug and Sep data are missing

clear all; close all; clc;

%%%%%%% need change!
folder = '/playpen/traffic_dynamics/data/map_data/ny/travel_times/travel_times_2012/';

for month = 1:12 %%%%%%% need change!
    fprintf('Start to process month %d...\n',month);
    switch month
        case 1
            dayInMonth = 31;
            infile = strcat(folder,'Jan');
            outpath = strcat(folder,'1/');
        case 2
            dayInMonth = 29; % for 2012: it's 29 %%%%%%% need change!
            infile = strcat(folder,'Feb');
            outpath = strcat(folder,'2/');
        case 3
            dayInMonth = 31;
            infile = strcat(folder,'Mar');
            outpath = strcat(folder,'3/');
        case 4
            dayInMonth = 30;
            infile = strcat(folder,'Apr');
            outpath = strcat(folder,'4/');
        case 5
            dayInMonth = 31;
            infile = strcat(folder,'May');
            outpath = strcat(folder,'5/');
        case 6
            dayInMonth = 30;
            infile = strcat(folder,'Jun');
            outpath = strcat(folder,'6/');
        case 7
            dayInMonth = 31;
            infile = strcat(folder,'Jul');
            outpath = strcat(folder,'7/');
        case 8
            dayInMonth = 31;
            infile = strcat(folder,'Aug');
            outpath = strcat(folder,'8/');
        case 9
            dayInMonth = 30;
            infile = strcat(folder,'Sep');
            outpath = strcat(folder,'9/');
        case 10
            dayInMonth = 31;
            infile = strcat(folder,'Oct');
            outpath = strcat(folder,'10/');
        case 11
            dayInMonth = 30;
            infile = strcat(folder,'Nov');
            outpath = strcat(folder,'11/');
        case 12
            dayInMonth = 31;
            infile = strcat(folder,'Dec');
            outpath = strcat(folder,'12/');
    end


    month_data = dlmread(infile);


    % processing
    for i = 1:dayInMonth % number of days for the specified month

        idx = find(month_data(:,end) >= (i-1)*24+1 & month_data(:,end) <= i*24);
        D = month_data(idx,:);
        D = sortrows(D,size(D,2));

        outfile = strcat(outpath,num2str(i));
        formatSpec = '%d %d %f %d %d\n';
        writeMatToFile(D,formatSpec,outfile);
    end
    
    fprintf('Finished processing month %d.\n',month);
end
