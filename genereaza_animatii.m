
% mai întâi încarc datele și modelul în workspace
%clear; clc;
run load_data_bonus.m

%% load output data from simulink model

ysim = out.simout;

% First reshape to 3 rows (x,y,z) and 9 columns (points)
tempData = reshape(ysim.Data, [3, 9, 762]);

% Permute (transpose) the first two dimensions to get 9x3
reshapedData = permute(tempData, [2, 1, 3]);

% --- Setup ---
[numPlanets, ~, numSteps] = size(reshapedData);
planetNames = {'Sun', 'Mercury', 'Venus', 'Earth', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune'};
colors = lines(numPlanets); 

figure('Color', 'white');
hold on; grid on; axis equal; view(3);
xlabel('X (AU)'); ylabel('Y (AU)'); zlabel('Z (AU)');
title('Solar System Animation');

% 1. initialize Plot Objects
% We create empty plot objects first and store their "handles"
% This allows us to modify them inside the loop without recreating them.
heads = gobjects(numPlanets, 1); % The moving dots
trails = gobjects(numPlanets, 1); % The lines behind them

for i = 1:numPlanets
    % Initialize Trail (Line)
    trails(i) = plot3(NaN, NaN, NaN, 'Color', colors(i,:), 'LineWidth', 1);
    
    % Initialize Head (Dot)
    heads(i) = plot3(NaN, NaN, NaN, 'o', ...
        'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'none', 'MarkerSize', 6);
end

% 2. Fix the Camera (Crucial!)
% If you don't do this, the camera will zoom in and out wildly.
% We find the maximum coordinate value to keep the view static.
maxVal = max(abs(reshapedData(:))) * 1.1; % Add 10% padding
xlim([-maxVal, maxVal]);
ylim([-maxVal, maxVal]);
zlim([-maxVal, maxVal]);

% --- Animation Loop ---
disp('Starting animation...');
for t = 1:numSteps
    
    for i = 1:numPlanets
        % Extract data for planet i
        % reshapedData is 9x3x718
        
        % Current Position (Head)
        currentX = reshapedData(i, 1, t);
        currentY = reshapedData(i, 2, t);
        currentZ = reshapedData(i, 3, t);
        
        % Trajectory up to now (Trail)
        % We flatten 1x1xT to Tx1 using (:)'
        trailX = reshapedData(i, 1, 1:t);
        trailY = reshapedData(i, 2, 1:t);
        trailZ = reshapedData(i, 3, 1:t);
        
        % Update the plot objects
        set(heads(i), 'XData', currentX, 'YData', currentY, 'ZData', currentZ);
        set(trails(i), 'XData', trailX, 'YData', trailY, 'ZData', trailZ);
    end
    
    % Force MATLAB to draw this frame
   
    drawnow limitrate; 
    
    % Optional: Add a pause if it's too fast
    %pause(0.01); 
end
disp('Animation complete.');


%% --- CALCUL MATEMATIC PENTRU PUNCTUL 4 (Mișcarea Retrogradă) ---

% 1. Extragem datele pentru Mercur (Planeta 2) și Pământ (Planeta 4)
% reshapedData are dimensiunile: [PlanetIndex, Coordinate(x,y,z), TimeStep]

% Poziția lui Mercur (r_Mercur)
r_Mercur_x = squeeze(reshapedData(2, 1, :));
r_Mercur_y = squeeze(reshapedData(2, 2, :));
r_Mercur_z = squeeze(reshapedData(2, 3, :));

% Poziția Pământului (r_Pamant)
r_Earth_x = squeeze(reshapedData(4, 1, :));
r_Earth_y = squeeze(reshapedData(4, 2, :));
r_Earth_z = squeeze(reshapedData(4, 3, :));

% 2. Calculăm Vectorul de Poziție Relativă (Ecuația 2 din cerință)
% r_Mercur/Pamant = r_Mercur - r_Pamant
x_rel = r_Mercur_x - r_Earth_x;
y_rel = r_Mercur_y - r_Earth_y;
z_rel = r_Mercur_z - r_Earth_z;

% Calculăm magnitudinea vectorului relativ 'r' (Ecuația 3b - partea a doua)
r_rel_mag = sqrt(x_rel.^2 + y_rel.^2 + z_rel.^2);

% 3. Convertim în Coordonate Ecliptice Sferice (Ecuațiile 3a și 3b)

% Lambda (Longitudinea Ecliptică) - folosim atan2 pentru a gestiona cadranele
lambda_rad = atan2(y_rel, x_rel); 

% Beta (Latitudinea Ecliptică)
beta_rad = asin(z_rel ./ r_rel_mag);

% 4. Convertim din radiani în grade pentru grafic
lambda_deg = rad2deg(lambda_rad);
beta_deg = rad2deg(beta_rad);

% Acum variabilele 'lambda_deg' și 'beta_deg' există și pot fi folosite în animația de mai jos

%% 
% --- 1. Fix the "Wrap-Around" Line Artifact ---
% We create a copy of the data for the "Trail"
trail_lambda = lambda_deg;
trail_beta = beta_deg;

% Find where the longitude jumps from +180 to -180 (or vice versa)
% If the jump is bigger than 300 degrees, we know it wrapped around.
jumpIdx = find(abs(diff(trail_lambda)) > 300); 

% Insert NaNs at those jumps. This tells MATLAB "don't draw a line here"
trail_lambda(jumpIdx) = NaN;
trail_beta(jumpIdx) = NaN; 

% --- 2. Setup the Animation Figure ---
figure('Color', 'white');
hold on; grid on;

% Initialize the plot objects (Trail and Head)
% We use 'trail_lambda' (with NaNs) for the line, but original 'lambda_deg' for the dot
hTrail = plot(NaN, NaN, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Path'); 
hHead = plot(NaN, NaN, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'DisplayName', 'Mercury');

% Set fixed axes so the graph doesn't jump around
xlim([-180 180]);
ylim([min(beta_deg)-1, max(beta_deg)+1]);
xlabel('Ecliptic Longitude (\lambda) [Degrees]');
ylabel('Ecliptic Latitude (\beta) [Degrees]');
title('Animation: Apparent Retrograde Motion');
legend('Location', 'northeast');

% --- 3. Run Animation ---
numSteps = length(lambda_deg);
disp('Starting 2D Animation...');

for t = 1:numSteps
    % Update the Dot (Current Position) - Use original data
    set(hHead, 'XData', lambda_deg(t), 'YData', beta_deg(t));
    
    % Update the Trail (History) - Use the NaN-fixed data
    set(hTrail, 'XData', trail_lambda(1:t), 'YData', trail_beta(1:t));
    
    drawnow limitrate; 
    
    % Optional: Add a small pause if it flies by too fast
    % pause(0.005);
end