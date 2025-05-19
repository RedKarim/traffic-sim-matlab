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

    % no signal part
    A(1) = IDM(X(1), V(1), X(1)+1000, 20);

    % First traffic signal x=300
    if (t <= 60)
        A(1) = IDM(X(1), V(1), 300, 0);
        set(p_signal1, 'MarkerFaceColor', 'r');
    else
        set(p_signal1, 'MarkerFaceColor', 'g');
    end

    % Second traffic signal x=600
    % Signal 1 cycles every 40 steps (20s red, 20s green)
    if mod(t, 80) <= 40 && mod(t, 80) ~= 0
        % Signal is red
        A(1) = IDM(X(1), V(1), 300, 0);
        set(p_signal1, 'MarkerFaceColor', 'r');
    else
        % Signal is green
        set(p_signal1, 'MarkerFaceColor', 'g');
    end

    % Signal 2 cycles every 40 steps as well (20s red, 20s green)
    if mod(t, 80) <= 40 && mod(t, 80) ~= 0 && X(1) > 320
        % Signal is red and affects lead car after it passed signal 1
        A(1) = IDM(X(1), V(1), 600, 0);
        set(p_signal2, 'MarkerFaceColor', 'r');
    else
        % Signal is green
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
