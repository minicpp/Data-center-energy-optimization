# Data-center-energy-optimization
In this research project, we study the problem of optimal task scheduling that minimizes the computation and AC energy consumption of a data center.
Different from existing studies that assume a linear relationship between computation power consumption and CPU frequency,
our model considers a non-linear cube-function computation power model.
Compared with the linear model, this model better describes the behavior of the DVFS technology that has been widely supported by modern CPUs
to improve their energy efficiency.
Moreover, our optimization formulation explicitly accounts for the heterogeneous thermal correlation among different servers in the data center,
so that tasks are carefully scheduled to offset the spatially-uneven temperature distribution caused by the heterogeneity of thermal correlation,
making the AC cooling efficiency better. We show that the energy-efficient task scheduling under the above settings can be formulated as a
mixed-integer convex (MIC) optimization problem. The MIC problem can be computed efficiently.
Extensive simulations are conducted to verify the energy benefit of the proposed optimization by comparing with those proposed in previous studies.