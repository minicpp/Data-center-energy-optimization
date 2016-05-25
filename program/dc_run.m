function dc_run(policy_select, filename)

red_temperature = 18;
coeff_file = 'coeff25_07.txt';
priority_array = [15 14 5 13 10 9 12 4 8 11 7 3 1 6 2 21 22 23 20 24 25 19 18 16 17];
job_dis_write_file = [];
consumption= [];
str_solve_res = '';
for i=0:25:250
    if i==0 || i==250
        [P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_naive(i, 470, priority_array,coeff_file, red_temperature)
    else
        switch  policy_select
            case 'naive'
                [P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_naive(i, 470, priority_array,coeff_file, red_temperature)
            case 'linear'
                [P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_linear(i, 470,coeff_file, red_temperature)
            case 'dvf_total'
                [P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_cov(i, 470,coeff_file,red_temperature, 0, 0)
            case 'dvf_ac'
                [P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_cov(i, 470,coeff_file,red_temperature, 0, 1)
            case 'dvf_cpu'
                [P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_schedule(i, 470, (i/25)*ones(1,25), coeff_file, red_temperature)
        end
    end
    
    %write file here
    consumption = [consumption, [i; P_TOTAL; P_AC; P_CMP;T_sup;COP]];
    job_dis_write_file = [job_dis_write_file, job_dis];
    str_solve_res = sprintf('%s%d:%s\n',str_solve_res,i,res_cvx);
    dlmwrite(filename,consumption);
    fileID = fopen(filename,'a+');
    fprintf(fileID,'%s\n', str_solve_res);
    fclose(fileID);
    dlmwrite(filename,job_dis_write_file,'-append');
end
