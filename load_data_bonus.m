% script that loads the initial data into the workspace


% data preluării datelor inițiale: 16 septembrie 2025

% ordinea planetelor:
% soare
% mercur
% venus
% pamant
% marte
% jupiter
% saturn
% uranus
% neptun

masses = [1988410e24; 
          3.3e23;
          48.6e23;
          5.97e24;
          6.41e23;
          18.98e26;
          5.6e26;
          86.8e24;
          102e24;
   ];

initial_position_m = [-5.7e5 -8.2e5 2.2e4;
                      -5.8e7 -1.92e6 5.25e6;
                      -2.8e7 1.03e8 3.03e6;
                      1.48e8 -1.9e7 2.17e4;
                      -1.64e8 -1.67e8 5.33e5;
                      -1.35e8 7.6e8 -1.2e5;
                      1.42e9 -5.13e7 -5.58e7;
                      1.53e9 2.48e9 -1.06e7;
                      4.46e9 2.62e7 -1.03e8;
                    ];

initial_velocity_m = [1.2e-2 -1.6e-3 -2.4e-4;
                      -9.19e0 -4.66e1 -2.96e0;
                      -3.39e1 -9.13e0 1.83e0;
                      3.15e0 2.94e1 -1.55e-3;
                      1.82e1 -1.48e1 -7.58e-1;
                      -1.3e1 -1.67e0 2.98e-1;
                      -1.85e-1 9.63e0 -1.6e-1;
                      -5.84e0 3.25e0 8.79e-2;
                      -6.7e-2 5.46e0 -1.11e-1;
                    ];

initial_position_m = 1000*initial_position_m;
initial_velocity_m = 1000*initial_velocity_m;

initial_position = reshape(initial_position_m.',1,[]);
initial_velocity = reshape(initial_velocity_m.',1,[]);