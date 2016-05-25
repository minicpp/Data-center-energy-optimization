%cvx_solver SeDuMi

jobs = 40
%for jobs=10:10:60
%% Task Predefined%%%%%%
%task=[100;200;300;400;500;600;700;800;900;1000; 1100; 1200; 1300; 1400; 1500;100;200;300;400;500;600;700;800;900;1000; 1100; 1200; 1300; 1400; 1500];
rng default
task=randi([100,100],jobs,1);
%task = [2000];
n=size(task,1); %job size
%% Interference Matrix %%%%%
A=dlmread('coeff.txt'); % Read matrix from plain file
%A=[0 0.1 0.0; 0.0 0.1 0.9; 0.0 0.7 0.1];
recCoeff = sum(A)';
m=size(A,1); % machine sizes
AT=A';
revEAT = inv(eye(m)-AT); % (E-A')^(-1)


%% for each cooler fan%%%%%%%%%
c_p = 1.005; % J/g
air_density = 1205; % g/m^3
flow_speed = 0.018*2; % m^3/s
M_sup = air_density*flow_speed; % mass of air for each unit time
%M_sup_array = M_sup*ones(m,1); % mass of air vector

M_sup_array = M_sup .*( 1- recCoeff );
%M_sup_array = M_sup .* rand(m,1)*2;
%M_out = revEAT*M_sup_array; % mass of air at the output side of machine
M_out = M_sup.*ones(m,1); %This one is equal to revEAT*M_sup_array
alpha = c_p*M_sup_array; %c_p*air_density*flow_speed for one fan


%% Some constant value
T_red = 30; %the maximum temperature that is allowd for input after mixed
c_0 = 83^(0.5); %c_0 is the square root consumption of an idle machine
%P_red = T_red*c_p*(M_sup_array + AT*M_out); %the maximum input air mixed power for each machine
%P_red = T_red*c_p*(M_sup_array); %the maximum input air mixed power for each machine
P_red = T_red*c_p*M_sup.*ones(m,1);

%method = 0
method = 1
%while method < 4
    
    shadow = ones(m,n);
    rest_calc = numel(shadow) - n+1;
    
    
    while rest_calc > 0
        %% Optimization variables (m is machine size, n is job size)
        %cvx_begin quiet
        cvx_begin
        variables x(m) P_e(m) % x(m)^2 == P, they are power of machines
        variable xt(m) % temperatory variable to get power of machines
        variable COP % AC coefficient
        variables  P_sup(m) T_sup % supplied power and temperature
        variable f(m) % frequence of machines
        %variable y(m,n) binary %jobs arrangment
        variable y(m,n)
        variable P_out(m) % output air power of machines
        
        %% objective function
        switch method
            case 0
                minimize (sum(P_e))
            case 1
                %maximize (sum(f))
                minimize ( quad_over_lin(x, COP) + sum(P_e) )
            case 2
                minimize ( quad_over_lin(x,COP) )
                
            case 3
                maximize ( T_sup )
        end
        %% power getting
        xt >= pow_p(0.00099*f,3)+c_0 %root of power
        P_e >= pow_p(xt,2) % power for each machine
        x == xt % root of power
        f == y*task % job assignment
        0<= f <= 2000
        xt >= 0
        P_e >= 0
        x >= 0
        
        %% support temperature
        T_sup * alpha == P_sup
        COP == 0.2728 * T_sup - 1.582
        P_sup >= 0
        T_sup >= 0
        COP >= 0
        
        %% model about power equation
        P_out >= 0
        revEAT*(P_sup + P_e)  == P_out
        P_sup + AT*P_out <= P_red
        
        %%
        sum(y) >= 1
        %y(1) == 1
        %y(2) == 0
        %0 <= y <= 1
        %if rest_calc ~=1
        %    y>=0
        %    y<= shadow
        %else
        %    y == shadow
        %end
        
        for index_m = 1:m
            for index_n=1:n
                if shadow(index_m,index_n) == 0
                    y(index_m,index_n) == 0;
                else
                    y(index_m,index_n) >= 0;
                end
            end
        end
        
        cvx_end
        
        if rest_calc ~= 1
            shadow(shadow==0)=2;
            shadow(shadow==1)=0;
            y2 = y+shadow;
            [v,i] = min(y2(:));
            [i,j]=ind2sub(size(y2),i);
            shadow(i,j) = 2;
            shadow(shadow==0)=1;
            shadow(shadow==2)=0;
        end
        rest_calc = rest_calc -1
        cvx_status
        %
    end


%% other result output

%disp('Final Y');
%y;
%P_e;


T_out = P_out./(c_p*M_out)
T_in = (P_sup + AT*P_out)./(c_p*M_out)
P_AC = sum(P_e)/COP
P_CMP =  sum(P_e)
P_TOTAL = P_AC+P_CMP
T_sup

y

method = method + 1
%end
%end
%y=[0, 1, 0];
%pp = sum( 1/40000000.*(200+1000.*y).^3) +  sum( 1/40000000.*(200+1000.*y).^3)  / ( beta*P_sup^2.01 )