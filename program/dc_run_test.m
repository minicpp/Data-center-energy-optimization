% n=0
% 
% 
% 
% i=100
% method = 1;
% base_freq = 3000;
% job_freq=200;
% [P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_cov(i, job_freq,'coeff25_03.txt', 20 ,base_freq,method)
% 
% fileID = fopen(strcat('res02_cov',num2str(method),'_',num2str(base_freq),'_',num2str(job_freq),'_', num2str(i),'.txt'),'w');
% fprintf(fileID,'%s Total: %f , P_AC: %f , P_CMP: %f , T_sup: %f , COP: %f \n',res_cvx, P_TOTAL, P_AC, P_CMP, T_sup, COP);
% fprintf(fileID,'%f\n',job_dis);
% fclose(fileID);
i=250
% [P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_cov(i, 470,'coeff25_01.txt',  20,0, 2)
% 
% fileID = fopen(strcat('res_cov2_', num2str(i),'.txt'),'w');
% fprintf(fileID,'%s Total: %f , P_AC: %f , P_CMP: %f , T_sup: %f , COP: %f \n',res_cvx, P_TOTAL, P_AC, P_CMP, T_sup, COP);
% fprintf(fileID,'%f\n',job_dis);
% fclose(fileID);

%[P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_schedule(i, 470, [1,1,0,0,0, 1, 1, 1, 0,1,0,0,0,1,0,1,1,1,1,1,1,1,1,0,0],'coeff25_01.txt', 20)
%[P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_schedule(i, 470, [6, 6,6,6,6,6,6,6,6,7,6,6,6,6,6,6,6,6,7,7,6,6,7,7,6],'coeff25_01.txt', 20)

i=100
[P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_cov(i, 470,'coeff25_07.txt',6 ,0, 1)