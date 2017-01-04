%# This script is to compute various errors

function [rmse,rmse_perc,mae_perc] = computeErrors(v_true,v_est)

    rmse = sqrt(immse(v_true,v_est));
    rmse_perc = rmse/mean(v_true);
    mae_perc  = sum(abs(v_est-v_true))/sum(v_true);

end