function [P_TOTAL,P_AC,P_CMP,T_sup,COP,Job_distribute,Res_cvx] = dc_naive(job_size, job_calc_req, priority_array, Apath, red_temperature)
%cvx_solver SDPT3
%SeDuMi cannot get solution
%SDPT3 or Mosek can get solution
cvx_solver Mosek


%% Task Predefined
%jobs = 200;
jobs = job_size;
%calc_req = 470; %MHz
calc_req = job_calc_req;
%task=calc_req*ones(jobs,1);
%n=size(task,1); %job size
n = jobs;
%% Interference Matrix
%A=dlmread('coeff25.txt'); % Read matrix from plain file
A=dlmread(Apath);
recCoeff = sum(A)';
m=size(A,1); % machine sizes
AT=A';
revEAT = inv(eye(m)-AT); % (E-A')^(-1)


%% for each cooler fana
c_p = 1.005; % J/g
air_density = 1190; % g/m^3
flow_speed = 0.0595; % m^3/s
M_intlet_air = air_density*flow_speed; % mass of air for each unit time

M_sup_array = M_intlet_air .*( 1- recCoeff ); %mass of air from AC for each unit
M_out = M_intlet_air.*ones(m,1); %This one is equal to revEAT*M_sup_array
alpha = c_p*M_sup_array; %c_p*air_density*flow_speed for one fan (air of heat from AC)

%% CPU Constant
max_freq = 4700;    %max frequency of cpu AMD fx-9590 eight core
P_e_max = 316;    %the power when cpu get max frequency
P_e_min = 84;     %when cpu is idle
%formula to calculate CPU power:
%cpu_p = (c_0+ (c_1*freq)^2)^2
c_0 = P_e_min^(0.5); %c_0 is the square root consumption of an idle machine
c_1 = (P_e_max^0.5 - c_0)^0.5/max_freq; %constant of c_1
c_cpu = 0.896; % J/c.g cpu heat capacity, this value is near Aluminum(0.902), greater than Cooper(0.385)
M_cpu = 68; %68g which is 2.5ounce for fx 9590


%% Some constant value
%T_red = 27; %the maximum temperature that is allowd for input after mixed(default:35)
T_red = red_temperature;
T_cpu_red = T_red+P_e_max/(c_cpu*M_cpu); % Used for relaxed cpu temperature
P_out_red = T_red*c_p*M_intlet_air+P_e_max; %The allowed maximum outlet energy
P_red = T_red*c_p*M_intlet_air.*ones(m,1); %The power of inlet air when supply air gets red temperature
X_max = P_e_max^0.5;

task_n = n;
job_allocated = zeros(m,1);
%scheduling_priority = [21 22 23 24 25 16 11 17 12 5 4 13 18 6 3 1 14 19 7 2 15 20 8 9 10];
scheduling_priority = priority_array;
rest_size = n;
for i=1:length(scheduling_priority)
    floor_size = floor(max_freq/calc_req);
    if(rest_size < floor_size)
        job_allocated(scheduling_priority(i)) = rest_size;
    else
        job_allocated(scheduling_priority(i)) = floor_size;
    end
    rest_size = rest_size - job_allocated(scheduling_priority(i));
end

freq_allocated = calc_req*job_allocated;
%% Optimization variables (m is machine size, n is job size)
t1 = clock;
cvx_begin quiet
%cvx_begin
variables x(m) P_e(m) % x(m)^2 == P, they are power of machines
%variable xt(m) % temperatory variable to get power of machines
variable COP % AC coefficient
variables  P_sup(m) T_sup % supplied power and temperature
variable f(m) % frequence of machines
if task_n > 0
    variable y(m,task_n) % scheduling
end
variable P_out(m) % output air power of machines

%minimize ( quad_over_lin(x, COP) + sum(P_e) )
minimize ( quad_over_lin(x,COP) )
%minimize ( sum(P_e) )

%% power getting
x >= pow_p(c_1*f,2)+c_0 % root of power
x <= X_max
P_e >= pow_p(x,2) % power for each machine
P_e <= P_e_max

f == freq_allocated

%% support temperature
T_sup * alpha == P_sup
%T_sup >= -1.6789
%T_sup >= 1
 T_sup >= 5.5 % to make sure that COP >= 0.5
%COP == 0.2728.*T_sup+0.4580;        %adjust cop to 15C is 1.65
COP == 0.265 * T_sup - 1.45 
P_sup >= 0

%% model about power equation
P_out >= 0
%revEAT*(P_sup + P_e)  <= P_out_red
revEAT*(P_sup + P_e)  == P_out
P_sup + AT*P_out <= P_red


cvx_end


cvx_status

%% other result output

%fprintf('\nScheduling Y:\n');
%y

fprintf('\nAccumulated jobs:\n');
Job_distribute = job_allocated

fprintf('\nPower Allocation:\n');
p_e = (c_0+ (c_1*calc_req*job_allocated).^2).^2

fprintf('\nAC supply temperature:\n');
T_sup

p_out = revEAT*(P_sup + p_e)

fprintf('\nInlet temperature:\n');
T_in = (P_sup + AT*p_out)./(c_p*(M_sup_array + AT*M_out))

fprintf('\nCPU temperature:\n');
T_cpu = T_in + p_e./(c_cpu*M_cpu)

fprintf('\nOutlet temperature:\n');
T_out = p_out./(c_p*M_out)

fprintf('\nOutlet airflow power:\n');
p_out

fprintf('\nPower of AC:\n')

P_AC = sum(p_e)/COP

fprintf('\nPower of computational:\n')
P_CMP =  sum(p_e)

fprintf('\nTotal power (AC+CMP):\n')
P_TOTAL = P_AC+P_CMP

Res_cvx = cvx_status;