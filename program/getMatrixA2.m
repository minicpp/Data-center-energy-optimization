%Get A
Air_density = 1190; %g/m^3
Flow_rate = 0.0595; % m^3/s
Air_heat = 1.005; %J/gK



path = 'D:\my\documents\research\sim_data\dc25_01.csv';


Ref_file = xlsread(path);

Machine_N = size(Ref_file,1)-1; %The first one is ref
K = (Air_density*Flow_rate*Air_heat)*eye(Machine_N);

coolest_array = zeros(2,Machine_N);
mean_inlet_temperature = Ref_file(1, 26 : (26+Machine_N-1) );

for s=1:length(mean_inlet_temperature)
    [v,i]=min(mean_inlet_temperature);
    coolest_array(1,s)=i;
    coolest_array(2,s)=v;
    mean_inlet_temperature(i) = 65535;
end

T_out = Ref_file(2:2+Machine_N-1, (26+Machine_N) : ((26+Machine_N*2-1)) )';
T_sup = (Ref_file(2:2+Machine_N-1,127)*ones(1,Machine_N))';
P = Ref_file(2:2+Machine_N-1, 1:Machine_N)';

AT = eye(Machine_N) - P/(T_out-T_sup)/K;
A = AT';
A(find(A<0)) = 0;




RcCoeff = sum(A,1)';

%Do some adjustment for element that is greater than 1
Adjust_array = find(RcCoeff>1.0);
for i=1:length(Adjust_array)
    index = Adjust_array(i);
    Adj_column_array = A(:,index)
    for j=1:length(Adj_column_array)
        
        value = RcCoeff(index);
        Adj_column_array(j) = Adj_column_array(j) - Adj_column_array(j)*(value-0.999)/value;
    end
    A(:,index) = Adj_column_array;
end

ExCoeff = ones(Machine_N, 1) - sum(A,2);
Mat_ExCoeff = vec2mat(ExCoeff,5);

RcCoeff = sum(A,1)';
Mat_RcCoeff = vec2mat(RcCoeff,5);

figure;
bar3(A);
figure;
bar3(Mat_ExCoeff);
figure;
bar3(Mat_RcCoeff);

dlmwrite('coeff25_01.txt',A,'delimiter',' ')
dlmwrite('coolingArray25_01.txt',coolest_array,'delimiter',' ')