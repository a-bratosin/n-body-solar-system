%% încarc datele în workspace
clear,clc;
run load_data_bonus.m


% inițializez parametrii simulării
t_start = 0;          
t_end   = 3600*24*7;         % simulez pentru o săptămână
h       = 600;        % pasul de simulare recomandat

% starea are forma [x', x]
x0 = [initial_velocity';initial_position'];
state_length = size(x0, 1);
position_length = size(initial_velocity,2);



% definesc funcția
% ca să simplific implementarea, folosesc o funcție anonimă de tip matrice
% care apelează funcția sistemului pe care am apelat-o în Simulink
f = @(t, y) [
    functie_sistem(y(position_length+1:end), masses)'; % Accel (must be column)
    y(1:position_length)                                % Velocity (must be column)
];

% declar matricile de timp și stare
t = t_start:h:t_end;
x = zeros(size(t,2),state_length);
x(1,:) = x0;

% bucla algoritmului RK4
for i = 1:(length(t) - 1)
    ti = t(i);
    xi = x(i,:)';
    
    k1 = f(ti, xi);
    k2 = f(ti + h/2, xi + (h/2)*k1);
    k3 = f(ti + h/2, xi + (h/2)*k2);
    k4 = f(ti + h,   xi + h*k3);
    
    x(i+1, :) = xi + (h/6) * (k1 + 2*k2 + 2*k3 + k4);
end

%% Vizualizarea rezultatelor (Simplified)

% --- 1. Reshape RK4 Data ---
rk_positions = x(:, position_length+1:end); 
% Reshape to [9 Planets x 3 Coords x N Steps]
rk_reshaped = permute(reshape(rk_positions', [3, 9, length(t)]), [2, 1, 3]);

% --- 2. Fetch Simulink Data ---
fprintf('Running Simulink model for comparison...\n');
% Run simulation to t_end (ensure model name is correct)
out = sim('tema_bonus', 'StopTime', num2str(t_end)); 

sim_time = out.simout.Time;
sim_data_raw = out.simout.Data;

% Reshape Simulink Data (Robust Handling for 1x27xN or Nx27)
[d1, d2, d3] = size(sim_data_raw);
if d1 == 1 && d2 == 27
    % Format: 1 x 27 x Time
    sim_data = permute(reshape(sim_data_raw, [3, 9, d3]), [2, 1, 3]);
elseif d2 == 27
    % Format: Time x 27
    sim_data = permute(reshape(sim_data_raw', [3, 9, d1]), [2, 1, 3]);
else
    % Format: 9 x 3 x Time (Already correct)
    sim_data = sim_data_raw;
end

% --- 3. Calculate Errors (Final State Only) ---
% Since step counts differ, we compare the position at the very last second.
planetNames = {'Sun', 'Mercury', 'Venus', 'Earth', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune'};
abs_errors = zeros(9, 1);
rel_errors = zeros(9, 1);

fprintf('\nFinal State Errors (t = %d s):\n', t_end);
fprintf('-----------------------------------------------------------------\n');
fprintf('%-10s | %-15s | %-15s\n', 'Planet', 'Abs Error (m)', 'Rel Error (%)');
fprintf('-----------------------------------------------------------------\n');

for i = 1:9
    % Compare the LAST available point from both simulations
    pos_rk_final = rk_reshaped(i, :, end)';
    pos_sim_final = sim_data(i, :, end)';
    
    % 1. Absolute Error (Euclidean Distance)
    abs_err = norm(pos_rk_final - pos_sim_final);
    abs_errors(i) = abs_err;
    
    % 2. Relative Error (vs Simulink Position Magnitude)
    ref_norm = norm(pos_sim_final);
    if ref_norm < 1e-9
        rel_err = 0; % Sun is at origin
    else
        rel_err = abs_err / ref_norm;
    end
    rel_errors(i) = rel_err;
    
    fprintf('%-10s | %.4e      | %.4f%%\n', planetNames{i}, abs_err, rel_err*100);
end

% --- 4. Plot Comparison (Mercur) ---
% We plot Earth (Planet 4) because plotting the whole solar system at once 
% makes the inner planets invisible due to scale.
figure('Color', 'white', 'Name', 'Trajectory Comparison');
planetIdx = 2; 

subplot(1, 2, 1);
hold on; grid on; axis equal; view(3);

% Plot Simulink (Blue Line)
% We use all available points for Simulink
plot3(squeeze(sim_data(planetIdx,1,:)), ...
      squeeze(sim_data(planetIdx,2,:)), ...
      squeeze(sim_data(planetIdx,3,:)), 'b-', 'LineWidth', 2, 'DisplayName', 'Simulink');

% Plot RK4 (Red Dashed)
% We use all available points for RK4
plot3(squeeze(rk_reshaped(planetIdx,1,:)), ...
      squeeze(rk_reshaped(planetIdx,2,:)), ...
      squeeze(rk_reshaped(planetIdx,3,:)), 'r--', 'LineWidth', 1.5, 'DisplayName', 'RK4');

title(['Trajectory Comparison: ' planetNames{planetIdx}]);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
legend('Location', 'best');

% --- 5. Error Bar Chart ---
subplot(1, 2, 2);
bar(categorical(planetNames), rel_errors * 100);
ylabel('Relative Error (%)');
title('Relative Error vs Simulink');
grid on;