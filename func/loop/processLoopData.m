%# This script is to process a loop data string from reading the raw file.

function dat_all = processLoopData(dataStr)

    dat_all = [];
    
    for i = 1:size(dataStr{1},1)
        
        line = strsplit(dataStr{1}{i});  % get a line of the data string and split it up by whitespaces     
        pre_dat = str2num(line{3}); % the third string of a line is the quantity of interest        
        assert(size(pre_dat,2) <= 2, 'Error: loop reading is wrong!');
        
        dat = pre_dat(end);
        if(size(pre_dat,2) == 2) % some data has comma in it, e.g., flow = 1,836
            dat = dat + pre_dat(1)*1000;
        end

        dat_all = [dat_all; dat]; % strong the processed data
    end
    
end