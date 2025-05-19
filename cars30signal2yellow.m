close all
numCars = 30;  % Number of cars 30

X = zeros(numCars, 1);
V = zeros(numCars, 1);
A = zeros(numCars, 1);

% Positions with 10m between cars
for i = 1:numCars
    X(i) = 100 - (i-1) * 10;
end

% Initial velocities
V(1) = 8;
V(2:numCars) = 10;

% Visualizations
f = figure;
set(f, 'position', [400,400,800,400]);
axis([0 700  0 10])
hold on
Y = X * 0 + 5;

% Road
p_road = plot([0 1000], [4.5 4.5], 'LineWidth', 30, 'color', [0.5, 0.5, 0.5]);

% Traffic signals
p_signal1 = plot(300, 8, 'sr', 'MarkerSize', 15, 'MarkerFaceColor', 'r');  % Red signal at x=300
p_signal2 = plot(600, 8, 'sr', 'MarkerSize', 15, 'MarkerFaceColor', 'r');  % Red signal at x=600
text(300, 9, 'Signal 1', 'HorizontalAlignment', 'center');
text(600, 9, 'Signal 2', 'HorizontalAlignment', 'center');

p = plot(X, Y, 'sr', 'MarkerSize', 10, 'MarkerFaceColor', [0.5, 0.1, 1]);

dt = 0.5;
CarData = [];
GreenTimes1 = [];
GreenTimes2 = [];
last_signal1_state = "";
last_signal2_state = "";
for t = 1 : 400  % Simulation time
    pause(0.06);

    % Traffic signal logic for all cars with yellow light
    cycle_length = 45; % total cycle duration in seconds
    red_duration = 20;  % red duration in seconds
    yellow_duration = 5; % yellow duration in seconds
    green_duration = 20; % green duration in seconds

    % Calculate signal states ONCE
    time_in_cycle = mod(t*dt, cycle_length);
    if time_in_cycle < green_duration
        signal1_state = "green";
    elseif time_in_cycle < green_duration + yellow_duration
        signal1_state = "yellow";
    else
        signal1_state = "red";
    end
    signal2_state = signal1_state; % Both signals have the same timing for simplicity

    % Record green transitions for plotting
    if ~strcmp(signal1_state, last_signal1_state) && strcmp(signal1_state, 'green')
        GreenTimes1(end+1) = t*dt;
    end
    if ~strcmp(signal2_state, last_signal2_state) && strcmp(signal2_state, 'green')
        GreenTimes2(end+1) = t*dt;
    end
    last_signal1_state = signal1_state;
    last_signal2_state = signal2_state;

    % Car logic uses the same state variables
    for n = 1:numCars
        stop_positions = [];
        stop_velocities = [];
        % Check signal 1
        if X(n) < 300 && (strcmp(signal1_state, 'red') || strcmp(signal1_state, 'yellow'))
            stop_positions(end+1) = 300;
            stop_velocities(end+1) = 0;
        end
        % Check signal 2
        if X(n) < 600 && (strcmp(signal2_state, 'red') || strcmp(signal2_state, 'yellow'))
            stop_positions(end+1) = 600;
            stop_velocities(end+1) = 0;
        end
        if ~isempty(stop_positions)
            % Stop for the nearest signal ahead
            [min_pos, idx] = min(stop_positions);
            A(n) = IDM(X(n), V(n), min_pos, stop_velocities(idx));
        elseif n == 1
            % Lead car, no car in front
            A(n) = IDM(X(n), V(n), X(n)+1000, 20);
        else
            % Follow the car in front
            A(n) = IDM(X(n), V(n), X(n-1), V(n-1));
        end
    end

    % Set signal colors using a mapping for synchronization
    state_to_color = struct('red', 'r', 'yellow', 'y', 'green', 'g');
    set(p_signal1, 'MarkerFaceColor', state_to_color.(signal1_state));
    set(p_signal2, 'MarkerFaceColor', state_to_color.(signal2_state));

    % Positions and velocities for all cars
    for n = 1 : numCars
        X(n) = X(n) + V(n) * dt + 0.5 * A(n) * dt^2;
        V(n) = V(n) + A(n) * dt;
    end

    delete(p);
    CarData(end+1,:) = [t * dt, X', V', A'];
    p = plot(X, Y, 'sr', 'MarkerSize', 10, 'MarkerFaceColor', [0.5, 0.1, 1]);
end

%% graph
f2 = figure;
plot(CarData(:, 1), CarData(:, 2:numCars+1));  % Position data
title('Car Positions Over Time');
xlabel('Time');
ylabel('Position');
hold on
% Signal change (plot actual green transitions)
for k = 1:length(GreenTimes1)
    plot([GreenTimes1(k), GreenTimes1(k)], [0, 3000], '--g', 'LineWidth', 2);
end
for k = 1:length(GreenTimes2)
    plot([GreenTimes2(k), GreenTimes2(k)], [0, 3000], '--g', 'LineWidth', 2);
end
legend('Cars', 'Signal 1 → Green', 'Signal 2 → Green', 'Location', 'southeast');

f3 = figure;
plot(CarData(:, 1), CarData(:, numCars+2:2*numCars+1));  % Velocity data
title('Car Velocities Over Time');
xlabel('Time');
ylabel('Velocity');

f4 = figure;
plot(CarData(:, 1), CarData(:, 2*numCars+2:end));  % Acceleration data
title('Car Accelerations Over Time');
xlabel('Time');
ylabel('Acceleration');
