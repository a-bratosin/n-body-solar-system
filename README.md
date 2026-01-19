# Solar System Modeling & Simulation (MATLAB / Simulink)
## Overview

This project models and simulates the motion of bodies in the Solar System using a Newtonian gravitational N-body formulation. The system consists of the Sun and the eight planets, modeled as point masses interacting gravitationally in a three-dimensional inertial reference frame.

- The dynamics are simulated using two independent numerical approaches:

- a custom implementation of the Runge–Kutta method of order 4 (RK4) in MATLAB;

- a reference Simulink model based on cascaded position–velocity–acceleration integration.

- The results obtained with both solvers are compared to validate numerical correctness and analyze stability properties.

## Project layout

- `rk4.m` – explicit Runge–Kutta 4 integrator

- `functie_sistem.m` – gravitational acceleration computation

- `load_data_bonus.m` – initialization of masses and initial conditions (JPL Horizons data)

- `genereaza_animatii.m` – visualization and animation utilities

- `tema_bonus.slx` – Simulink reference model

- `MS.pdf` – detailed technical report (model, methodology, results)
