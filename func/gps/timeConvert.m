%# This script is to convert epoch time to date and get hour index of a week (for sf data only)


function hourIdx = timeConvert(et)

    time_matlab = datenum([1970,1,1,0,0,0]) + et*1000 / 8.64e7;
    s = datestr(time_matlab, 'yyyymmdd HH:MM:SS');
    
    hourIdx = -1;
    
    if(s(6) == '5') % May 10 is a Sat
        hourIdx = (mod(abs(str2num(s(7:8))-10),7)+1)*(str2num(s(10:11))+1);
    elseif(s(6) == '6') % Jun 7 is a Sat
        hourIdx = (mod(abs(str2num(s(7:8))-7),7)+1)*(str2num(s(10:11))+1);
    end

    assert(hourIdx > 0 & hourIdx < 169, 'Error: hourIdx conversion!');
end