%cvx_solver SeDuMi
function [P_TOTAL,P_AC,P_CMP,T_sup,COP, Job_distribute,Res_cvx] = dc_cov(job_size, job_calc_req, Apath, red_temperature, base_freq, method)
cvx_solver SeDuMi


%% Task Predefined
jobs = job_size;
calc_req = job_calc_req; %MHz
%task=calc_req*ones(jobs,1);
%n=size(task,1); %job size
n = jobs;
%% Interference Matrix
A=dlmread(Apath); % Read matrix from plain file
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
T_red = red_temperature; %the maximum temperature that is allowd for input after mixed
T_cpu_red = T_red+P_e_max/(c_cpu*M_cpu); % Used for relaxed cpu temperature
P_out_red = T_red*c_p*M_intlet_air+P_e_max; %The allowed maximum outlet energy
P_red = T_red*c_p*M_intlet_air.*ones(m,1); %The power of inlet air when supply air gets red temperature
X_max = P_e_max^0.5;

%used for matrix constraints
%shadow = zeros(m,n);
%rest_calc = size(shadow,2)+1;


task_n = n;
job_allocated = zeros(m,1);
while task_n >= 0
    task=calc_req*ones(task_n,1);
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

    if method == 1
        minimize ( quad_over_lin(x,COP) )
    elseif method == 2
        minimize ( sum(P_e) )
    else
        minimize ( quad_over_lin(x, COP) + sum(P_e) )
    end
    %% power getting
    x >= pow_p(c_1*f,2)+c_0 % root of power
    x <= X_max
    P_e >= pow_p(x,2) % power for each machine
    P_e <= P_e_max
    
    
    %f == y*task % job assignment
    %0 <= f <= max_freq
    if(task_n > 0)
        f == y*task + freq_allocated + base_freq
        f <= max_freq
    else
        f == freq_allocated
    end
    
    %% support temperature
    T_sup * alpha == P_sup
    
    %T_sup >= -1.6789
    T_sup >= 5.5 % to make sure that COP >= 0.0075
    %COP == 0.2728.*T_sup+0.4580;        %adjust cop to 15C is 1.65
    COP == 0.265 * T_sup - 1.45 
    P_sup >= 0
    %COP >= 0
    %% model about power equation
    P_out >= 0
    %revEAT*(P_sup + P_e)  <= P_out_red
    revEAT*(P_sup + P_e)  == P_out
    P_sup + AT*P_out <= P_red
    
    %T_cpu_red >= (1/(c_p*M_sup))*(P_sup + AT*P_out)+P_e/(c_cpu*M_cpu)
    
    %%
    if(task_n > 0)
        sum(y) == 1
        y>=0
        y<=1
    end
    %y>=shadow
    
    cvx_end
    
    %if rest_calc ~= 1
    %    shadow(shadow==1) = -2;
    %    y2 = y+shadow;
    %    [v,i] = max(y2(:));
    %    [i,j]=ind2sub(size(y2),i);
    %    shadow(i,j) = -2;
    %    shadow(shadow==-2)=1;
    %end
    %rest_calc = rest_calc -1
    
    if task_n>0
        y2 = y;
        [v,i] = max(y2(:));
        flag_solve = 0;
        while v ~= -100
            [i,j]=ind2sub(size(y2),i);
            job_num = job_allocated(i) + 1;
            if job_num*calc_req+base_freq > max_freq
                y2(i,j) = -100;
                [v,i] = max(y2(:));
            else
                job_allocated(i) = job_num;
                flag_solve = 1;
                break;
            end
        end
        if flag_solve == 0
            fprintf('\nError:Tasks exceed the capacity of Data Center\n');
            break;
        end
    end

    
    res_status = cvx_status
    if strcmp(res_status,'Infeasible') == 1
        break;
    end
    fprintf('\nUsed time for this iteration\n');
    t2 = clock;
    intervalTime = etime(t2,t1)
    fprintf('\nEstimated time that we need\n');
    restTime = intervalTime * (task_n)/60 %minutes estimated
    task_n = task_n - 1
    %
end


%% other result output

%fprintf('\nScheduling Y:\n');
%y

fprintf('\nAccumulated jobs:\n');
Job_distribute = job_allocated

fprintf('\nPower Allocation:\n');
p_e = (c_0+ (c_1*(calc_req*job_allocated+base_freq)).^2).^2

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