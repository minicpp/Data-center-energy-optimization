%cvx_solver SeDuMi

%cvx_solver Mosek
%cvx_solver_settings('MSK_IPAR_NUM_THREADS', 4)

A=dlmread('coeff.txt');
m=size(A,1);

%task=[100;200;300;400;500;600;700;800;900;1000; 1100; 1200; 1300; 1400; 1500;100;200;300;400;500;600;700;800;900;1000; 1100; 1200; 1300; 1400; 1500];
task=[1000;100;200;300;400;500;600;700;800;900;1000];
n=size(task,1);
AT=A';

%E_one=ones(3,1)

revEAT = inv(eye(m)-AT);
alpha = 21.69; %air_density*flow_speed for one node
T_red = 30;
P_red=T_red*alpha;
beta = 0.007/alpha^(2.01);

shadow = zeros(m,n);
rest_calc = numel(shadow) - n+1;
%shadow(7,1) = 2;
c_0 = 83^(0.5);

%cvx_begin quiet
cvx_begin
variables x(m) P_sup f(m) P_e(m) COP T_sup P_out(m) xt(m)
variable y(m,n) binary
%minimize ( quad_over_lin(x, COP) + sum(P_e) )
minimize ( quad_over_lin(x,COP) )
%minimize (sum(P_e))

xt >= pow_p(0.00099*f,3)+c_0
P_e >= pow_p(xt,2)
x >= xt

f == y*task

T_sup == P_sup/alpha
COP == 0.2728 * T_sup - 1.582

%P_sup <= P_red
P_sup >= 0

P_out >= 0
revEAT*(P_sup + P_e)  == P_out

P_sup + AT*P_out <= P_red

sum(y) == 1
cvx_end



disp('Final Y');
y

% cvx_begin
% variables P_sup P_out(3) COP T_sup
%
% maximize (P_sup)
%
% revEAT*(P_sup + P_e)  == P_out
% P_sup + AT*P_out <= P_red
% T_sup == P_sup/alpha
% COP == 0.2728 * T_sup - 1.582
%
% cvx_end

T_out = P_out/alpha
T_in = (P_sup + AT*P_out)/alpha
P_AC = sum(P_e)/COP
P_CMP =  sum(P_e)
P_TOTAL = P_AC+P_CMP
%y=[0, 1, 0];
%pp = sum( 1/40000000.*(200+1000.*y).^3) +  sum( 1/40000000.*(200+1000.*y).^3)  / ( beta*P_sup^2.01 )