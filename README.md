# FYP_NUSRI_RL_BOTSP
## This work is in partial fulfilment of the requirements for the Degree of Bachelor of Engineering National University of Singapore (Suzhou)
## This code is the model with four-dimension input (Euclidean-type) based on reproduction of https://github.com/kevin031060/RL_TSP_4static
### FYP_DRL is used for training and testing bi-objective TSP by DRL
#### 1. To test the model, use the load_all_rewards.py
#### 2. To train the model, run train_motsp_transfer.py
#### Tips. three constrains are added in FYP_DRL/model.py/class DRL4TSP.../def forward...
### FYP_MATLAB is used to visualize and compare with classical methods
#### 1. tour_route_line is used to draw the travel lines of both objectives in different subproblems
#### 2. compared_with_classical_methods is used to compare with evolutionary algorithms (MOEA/D & NSGAII)
(run compare.m)
#### 3. add_constrains is used to draw the travel lines after adding constrains
#### 0. MATLAB_results stores the graph results of 1.2.3.
 
