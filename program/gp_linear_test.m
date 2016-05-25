%cvx_solver SeDuMi

cvx_solver

jobs = 15;
    %% Task Predefined
    task=randint(10*jobs,1,[100,100]);
    
    n=size(task,1); %job size
    
    %% Interference Matrix
    A=dlmread('coeff10.txt'); % Read matrix from plain file
    recCoeff = sum(A)';
    m=size(A,1); % machine sizes
    AT=A';
    revEAT = inv(eye(m)-AT); % (E-A')^(-1)
    
    
    %% for each cooler fana
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
    T_red = 35; %the maximum temperature that is allowd for input after mixed
    c_base = 83;
    c_0 = c_base^(0.5); %c_0 is the square root consumption of an idle machine
    %P_red = T_red*c_p*(M_sup_array + AT*M_out); %the maximum input air mixed power for each machine
    %P_red = T_red*c_p*(M_sup_array); %the maximum input air mixed power for each machine
    P_red = T_red*c_p*M_sup.*ones(m,1);
    
    X_max = ((0.002*2000)^1.5 + c_0);
    %X_max = (0.00099*2000)^3+c_0;
    P_e_max = X_max^2
    P_out_red = T_red*c_p*M_sup+P_e_max;
    
    c_cpu = 0.896;
    M_cpu = 30;
    T_cpu_red = T_red+P_e_max/(c_cpu*M_cpu);
    

        shadow = zeros(m,n);
    rest_calc = size(shadow,2)+1;
    
        while rest_calc > 0
            %% Optimization variables (m is machine size, n is job size)
            cvx_begin quiet
            %cvx_begin
            variables P_e(m) % x(m)^2 == P, they are power of machines
            %variable xt(m) % temperatory variable to get power of machines
            variables  P_sup(m) T_sup % supplied power and temperature
            variable f(m) % frequence of machines
            %variable y(m,n) binary %jobs arrangment
            variable y(m,n)
            variable P_out(m) % output air power of machines
            
            %% objective function
           
            maximize (T_sup)
  
            P_e == c_base +  (P_e_max - c_base) * f/2000
            f == y*task % job assignment
            0 <= f <= 2000
            %% support temperature
            T_sup * alpha == P_sup
            %T_sup >= -1.6789
            T_sup >= 1    
            P_sup >= 0

            %% model about power equation
            P_out >= 0
            revEAT*(P_sup + P_e)  == P_out
            P_sup + AT*P_out <= P_red
    
            sum(y) == 1
          
            y>=0
            y<=1
           
            y>=shadow
            
            cvx_end
            
            if rest_calc ~= 1
                shadow(shadow==1) = -2;
                y2 = y+shadow;
                [v,i] = max(y2(:));
                [i,j]=ind2sub(size(y2),i);
                shadow(i,j) = -2;
                shadow(shadow==-2)=1;
            end
            rest_calc = rest_calc -1
            cvx_status
            %
        end
        
        
        %% other result output
        
        disp('Final Y');
        y
        p_vector = P_e
        
        COP = 0.2728.*T_sup+0.4580
        p_out = revEAT*(P_sup + p_vector)
        
        T_out = p_out./(c_p*M_out)
        T_in = (P_sup + AT*p_out)./(c_p*(M_sup_array + AT*M_out))
        T_cpu = T_in + p_vector./(c_cpu*M_cpu)
        P_AC = sum(p_vector)/COP
        P_CMP =  sum(p_vector)
        P_TOTAL = P_AC+P_CMP
        T_sup
        sum(y,2)
        
  

%y=[0, 1, 0];
%pp = sum( 1/40000000.*(200+1000.*y).^3) +  sum( 1/40000000.*(200+1000.*y).^3)  / ( beta*P_sup^2.01 )
