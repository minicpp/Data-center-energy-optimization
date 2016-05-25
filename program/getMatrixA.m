%Get A
Air_density = 1190; %g/m^3
Flow_rate = 0.0595; % m^3/s
Air_heat = 1.005; %J/gK
Machine_N = 16;
K = (Air_density*Flow_rate*Air_heat)*eye(Machine_N);

path = 'D:\my\documents\research\sim_data\';
filename = {'ref.csv', 'C4_1.csv', 'C4_5.csv', 'C4_9.csv', 'C4_13.csv', ...,
    'C5_1.csv', 'C5_5.csv', 'C5_9.csv', 'C5_13.csv', ...,
    'D2_1.csv', 'D2_5.csv', 'D2_9.csv', 'D2_13.csv', ...,
    'D4_1.csv', 'D4_5.csv', 'D4_9.csv', 'D4_13.csv'};

Ref_file = xlsread(strcat(path,filename{1}));

coolest_array = zeros(2,Machine_N);
mean_inlet_temperature = Ref_file(:, 35);

for s=1:length(mean_inlet_temperature)
    [v,i]=min(mean_inlet_temperature);
    coolest_array(1,s)=i;
    coolest_array(2,s)=v;
    mean_inlet_temperature(i) = 65535;
end



Data_file = cell(1);

fprintf('Read file');
for i=2:length(filename)
    Data_file{i-1} = xlsread(strcat(path,filename{i}));
    fprintf(strcat('.',num2str(i-1),'/',num2str(Machine_N)));
    if mod(i-1,10) == 0
        fprintf('\n');
    end
end
fprintf('.Read finish\n');

Temperature_out_new = zeros(Machine_N);
Temperature_out_ref = zeros(Machine_N);
Power_new = zeros(Machine_N);
Power_ref = zeros(Machine_N);
for i=1:Machine_N
    Temperature_out_new(:,i)=Data_file{i}(:,38);
    Power_new(:,i) = Data_file{i}(:,21);
    Temperature_out_ref(:,i)= Ref_file(:,38);
    Power_ref(:,i) = Ref_file(:,21);
end

AT = eye(Machine_N);
AT = AT - (Power_new - Power_ref)/(Temperature_out_new - Temperature_out_ref)/(K);
A = AT';
A(find(A<0)) = 0;

dlmwrite('coeff16.txt',A,'delimiter',' ')
dlmwrite('coolingArray16.txt',coolest_array,'delimiter',' ')

ExCoeff = ones(Machine_N, 1) - sum(A,2);
Mat_ExCoeff = vec2mat(ExCoeff,4);
RcCoeff = sum(A,1)';
Mat_RcCoeff = vec2mat(RcCoeff,4);

figure;
bar3(A);
figure;
bar3(Mat_ExCoeff);
figure;
bar3(Mat_RcCoeff);