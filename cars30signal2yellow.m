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
set(f, 'position', [200,200,800,400]);
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
for t = 1 : 200  % Simulation time
    pause(0.03);

    % Traffic signal logic for all cars with yellow light
    cycle_length = 20; % total cycle duration in seconds
    red_duration = 8;  % red duration in seconds
    yellow_duration = 2; % yellow duration in seconds
    green_duration = 10; % green duration in seconds

    % Calculate signal states
    time_in_cycle = mod(t*dt, cycle_length);
    if time_in_cycle < red_duration
        signal1_state = "red";
    elseif time_in_cycle < red_duration + yellow_duration
        signal1_state = "yellow";
    else
        signal1_state = "green";
    end
    % Both signals have the same timing for simplicity
    signal2_state = signal1_state;

    for n = 1:numCars
        % Signal 1 logic
        if X(n) < 300 && (strcmp(signal1_state, 'red') || strcmp(signal1_state, 'yellow')) && (X(n) > 300-10)
            A(n) = IDM(X(n), V(n), 300, 0);
        % Signal 2 logic (after passing first signal)
        elseif X(n) > 320 && X(n) < 600 && (strcmp(signal2_state, 'red') || strcmp(signal2_state, 'yellow')) && (X(n) > 600-10)
            A(n) = IDM(X(n), V(n), 600, 0);
        elseif n == 1
            % Lead car, no car in front
            A(n) = IDM(X(n), V(n), X(n)+1000, 20);
        else
            % Follow the car in front
            A(n) = IDM(X(n), V(n), X(n-1), V(n-1));
        end
    end

    % Set signal colors
    if strcmp(signal1_state, 'red')
        set(p_signal1, 'MarkerFaceColor', 'r');
    elseif strcmp(signal1_state, 'yellow')
        set(p_signal1, 'MarkerFaceColor', 'y');
    else
        set(p_signal1, 'MarkerFaceColor', 'g');
    end
    if strcmp(signal2_state, 'red')
        set(p_signal2, 'MarkerFaceColor', 'r');
    elseif strcmp(signal2_state, 'yellow')
        set(p_signal2, 'MarkerFaceColor', 'y');
    else
        set(p_signal2, 'MarkerFaceColor', 'g');
    end

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
% Signal change
plot([60*dt, 60*dt], [0, 700], '--g', 'LineWidth', 2);  % Signal 1 green
plot([150*dt, 150*dt], [0, 700], '--g', 'LineWidth', 2);  % Signal 2 green
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
