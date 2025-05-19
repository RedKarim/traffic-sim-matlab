close all
numCars = 30;  % Increased number of cars to 30

% Initialize arrays with the new size
X = zeros(numCars, 1);
V = zeros(numCars, 1);
A = zeros(numCars, 1);

% Assign positions with 10m spacing between cars
for i = 1:numCars
    X(i) = 100 - (i-1) * 10;  % First car at 100, each subsequent car 10m behind
end

% Set initial velocities (first car at 8, others at 10)
V(1) = 8;
V(2:numCars) = 10;

% Create figure for visualization
f = figure;
set(f, 'position', [200,200,800,200]);
axis([0 400  0 10])
hold on
Y = X * 0 + 5;  % All cars at y-position = 5
p = plot([0 1000], [4.5 4.5], 'LineWidth', 30, 'color', [0.5, 0.5, 0.5]);
%scatter(X, Y);

dt = 0.5;
CarData = [];
for t = 1 : 100
    pause(0.03);
    A(1) = IDM(X(1), V(1), X(1)+1000, 20);
    if (t <= 60)
        A(1) = IDM(X(1), V(1), 200, 0);
    end

    % Calculate acceleration for all following cars
    for n = 2 : numCars
        A(n) = IDM(X(n), V(n), X(n - 1), V(n - 1));
    end

    % Update positions and velocities for all cars
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
