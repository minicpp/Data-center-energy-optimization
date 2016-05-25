n=0
for i=[15, 75,  135,  195, 245] 

[P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_naive(i, 470, [16 21 6 17 22 7 23 18 11 1 8 12 24 2 13 19 14 25 3 15 9 4 5 10 20],'coeff25_01.txt',  20)

fileID = fopen(strcat('res_naive_', num2str(i),'.txt'),'w');
fprintf(fileID,'%s Total: %f , P_AC: %f , P_CMP: %f , T_sup: %f , COP: %f \n',res_cvx, P_TOTAL, P_AC, P_CMP, T_sup, COP);
fprintf(fileID,'%f\n',job_dis);
fclose(fileID);

[P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_linear(i, 470,'coeff25_01.txt',  20)

fileID = fopen(strcat('res_linear_', num2str(i),'.txt'),'w');
fprintf(fileID,'%s Total: %f , P_AC: %f , P_CMP: %f , T_sup: %f , COP: %f \n',res_cvx, P_TOTAL, P_AC, P_CMP, T_sup, COP);
fprintf(fileID,'%f\n',job_dis);
fclose(fileID);

[P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_cov(i, 470,'coeff25_01.txt',  20, 0)

fileID = fopen(strcat('res_cov0_', num2str(i),'.txt'),'w');
fprintf(fileID,'%s Total: %f , P_AC: %f , P_CMP: %f , T_sup: %f , COP: %f \n',res_cvx, P_TOTAL, P_AC, P_CMP, T_sup, COP);
fprintf(fileID,'%f\n',job_dis);
fclose(fileID);

[P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_cov(i, 470,'coeff25_01.txt',  20, 1)

fileID = fopen(strcat('res_cov1_', num2str(i),'.txt'),'w');
fprintf(fileID,'%s Total: %f , P_AC: %f , P_CMP: %f , T_sup: %f , COP: %f \n',res_cvx, P_TOTAL, P_AC, P_CMP, T_sup, COP);
fprintf(fileID,'%f\n',job_dis);
fclose(fileID);

[P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_cov(i, 470,'coeff25_01.txt',  20, 2)

fileID = fopen(strcat('res_cov2_', num2str(i),'.txt'),'w');
fprintf(fileID,'%s Total: %f , P_AC: %f , P_CMP: %f , T_sup: %f , COP: %f \n',res_cvx, P_TOTAL, P_AC, P_CMP, T_sup, COP);
fprintf(fileID,'%f\n',job_dis);
fclose(fileID);
end