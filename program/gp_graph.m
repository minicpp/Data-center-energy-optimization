
job1=10*[1:17]


cpu_dvfs_total_min = [961.5,999.35,1049,1109.4,1182,1265.2,1359.7,1468.6,1588.6,1726.4,1878.4,2051.1,2239.6,2469.4,2710.7,3049.1,3981.1];
cpu_dvfs_total_min_ac = [115.12,122.62,128.71,140.73,153.42,172.11,189.29,217.44,235.21,275.24,299.48,343.23,390.33,456.35,526.49,741.08,1541.4];
cpu_dvfs_total_min_cmp = cpu_dvfs_total_min - cpu_dvfs_total_min_ac;

cpu_dvfs_ac_min = [966.16,1005,1055.6,1125.4,1211.3,1312.1,1428.2,1525.3,1675.4,1853.4,2033.3,2185.1,2314.6,2471.2,2710.7,3049.1,3981.1];
cpu_dvfs_ac_min_ac = [114.19,119.64,126.39,134.75,145.04,157.1,171,187.15,205.57,227.41,254.09,283.62,333.25,396.31,526.48,741.03,1541.4];
cpu_dvfs_ac_min_cmp = cpu_dvfs_ac_min - cpu_dvfs_ac_min_ac;

cpu_dvfs_cmp_min = [997.15,1039.3,1094.4,1161.5,1241.1,1334.2,1444.4,1577.3,1741.2,1943.1,2212.1,2633.4,3476,4941.5,5146,5515.4,5771];
cpu_dvfs_cmp_min_ac = [150.77,162.54,177.51,195.97,218.9,247.36,285.19,337.54,412.91,517.74,681.08,987.67,1706.3,2854.8,2972.7,3186.6,3334.3];
cpu_dvfs_cmp_min_cmp = cpu_dvfs_cmp_min - cpu_dvfs_cmp_min_ac;

job2=10*[1:16]
inlet_dvfs_total_min = [1007.9,1050.5,1101.8,1168.4,1250.3,1338.1,1442.2,1561.6,1696.6,1849.2,2018.5,2206.8,2435.2,2656.6,2944.2,3502.4];
inlet_dvfs_total_min_ac = [161.54,170.82,181.56,196.38,219.42,240.3,258.98,297.47,323.19,365.6,413.13,451.7,521.35,593.33,731.58,1175.7];
inlet_dvfs_total_min_cmp = inlet_dvfs_total_min - inlet_dvfs_total_min_ac;

inlet_dvfs_ac_min = [1011.8,1053,1111.3,1179.7,1269.8,1375.4,1497.1,1638.1,1775.2,1929.6,2123,2339.5,2465.2,2676.7,2944.1,3502.5];
inlet_dvfs_ac_min_ac = [159.79,167.58,178.11,189.07,203.51,220.43,239.93,262.53,288.67,317.96,356.81,400.39,456.47,573.03,731.39,1175.8];
inlet_dvfs_ac_min_cmp = inlet_dvfs_ac_min - inlet_dvfs_ac_min_ac;

inlet_dvfs_cmp_min = [1048.5,1093.9,1154.1,1229.4,1321.6,1434.1,1571.4,1744.4,1971,2295.5,2838.9,3890.7,4192.5,4526.6,4906.1,5331.8,5696.4];
inlet_dvfs_cmp_min_ac = [202.08,217.22,237.23,263.88,299.39,347.27,412.09,504.7,642.65,870.18,1307.9,2245,2419,2609.5,2828.6,3073.9,3295.6];
inlet_dvfs_cmp_min_cmp = inlet_dvfs_cmp_min - inlet_dvfs_cmp_min_ac;

job3=10*[1:15]
inlet_linear_ac_min = [1110.2,1234.8,1359.3,1483.9,1608.4,1733,1857.6,1982.1,2106.7,2233.1,2431.5,2632.6,2878.2,3264.7,5114.9];
inlet_linear_ac_min_ac = [175.34,195.01,214.68,234.36,254.03,273.7,293.37,313.04,332.71,354.27,447.77,543.97,684.73,966.32,2711.6];
inlet_linear_ac_min_cmp = inlet_linear_ac_min - inlet_linear_ac_min_ac;
% The reason that the opt_cpu_ac cannot be optimal is that using DVFS, the power consumption
% is not linear to the size of jobs, therefore the total energy for the same scale of jobs
% might be different, if jobs are scheduled to different machines.
% While in linear model, no matther how we schedule the jobs, the total computational
% energy consumption is the same.

plot(job1,cpu_dvfs_total_min,'-o',job1,cpu_dvfs_ac_min,'-+',job1,cpu_dvfs_cmp_min, '-x', ...,
    job2,inlet_dvfs_total_min,'-.*',job2,inlet_dvfs_ac_min, '--s',job1, inlet_dvfs_cmp_min,'--d', ...,
job3, inlet_linear_ac_min,'-p')
xlabel('Jobs')
ylabel('Total energy consumption (E^{AC}+E^{cmp})')
legend('CPU\_DVFS\_TOTAL\_MIN','CPU\_DVFS\_AC\_MIN','CPU\_DVFS\_CMP\_MIN','Inlet\_DVFS\_TOTAL\_MIN', ...,
    'Inlet\_DVFS\_AC\_MIN', 'Inlet\_DVFS\_CMP\_MIN', 'Inlet\_Linear\_AC\_MIN[Tang2007]')

%only ac
figure
plot(job1,cpu_dvfs_total_min_ac,'-o',job1,cpu_dvfs_ac_min_ac,'-+',job1,cpu_dvfs_cmp_min_ac, '-x', ...,
    job2,inlet_dvfs_total_min_ac,'-.*',job2,inlet_dvfs_ac_min_ac, '--s',job1, inlet_dvfs_cmp_min_ac,'--d', ...,
job3, inlet_linear_ac_min_ac,'-p')
xlabel('Jobs')
ylabel('AC energy consumption (E^{AC})')
legend('CPU\_DVFS\_TOTAL\_MIN','CPU\_DVFS\_AC\_MIN','CPU\_DVFS\_CMP\_MIN','Inlet\_DVFS\_TOTAL\_MIN', ...,
    'Inlet\_DVFS\_AC\_MIN', 'Inlet\_DVFS\_CMP\_MIN', 'Inlet\_Linear\_AC\_MIN[Tang2007]')

%only cmp
figure
plot(job1,cpu_dvfs_total_min_cmp,'-o',job1,cpu_dvfs_ac_min_cmp,'-+',job1,cpu_dvfs_cmp_min_cmp, '-x', ...,
    job2,inlet_dvfs_total_min_cmp,'-.*',job2,inlet_dvfs_ac_min_cmp, '--s',job1, inlet_dvfs_cmp_min_cmp,'--d', ...,
job3, inlet_linear_ac_min_cmp,'-p')
xlabel('Jobs')
ylabel('Computational energy consumption (E^{cmp})')
legend('CPU\_DVFS\_TOTAL\_MIN','CPU\_DVFS\_AC\_MIN','CPU\_DVFS\_CMP\_MIN','Inlet\_DVFS\_TOTAL\_MIN', ...,
    'Inlet\_DVFS\_AC\_MIN', 'Inlet\_DVFS\_CMP\_MIN', 'Inlet\_Linear\_AC\_MIN[Tang2007]')