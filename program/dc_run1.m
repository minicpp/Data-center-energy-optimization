

n=0
%for i=[70, 170] 
for i=170;

[P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_cov(i, 470,'coeff25_01.txt',  20,0, 1)

fileID = fopen(strcat('res_cov1_', num2str(i),'.txt'),'w');
fprintf(fileID,'%s Total: %f , P_AC: %f , P_CMP: %f , T_sup: %f , COP: %f \n',res_cvx, P_TOTAL, P_AC, P_CMP, T_sup, COP);
fprintf(fileID,'%f\n',job_dis);
fclose(fileID);

% [P_TOTAL,P_AC,P_CMP,T_sup,COP,job_dis,res_cvx] = dc_cov(i, 470,'coeff25_01.txt',  20,0, 2)
% 
% fileID = fopen(strcat('res_cov2_', num2str(i),'.txt'),'w');
% fprintf(fileID,'%s Total: %f , P_AC: %f , P_CMP: %f , T_sup: %f , COP: %f \n',res_cvx, P_TOTAL, P_AC, P_CMP, T_sup, COP);
% fprintf(fileID,'%f\n',job_dis);
% fclose(fileID);

%end