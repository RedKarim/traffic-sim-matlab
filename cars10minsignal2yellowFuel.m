close all
clear

%% Parameters
simDuration = 60;      % total simulation time (s)
dt = 0.5;              % time step (s)
spawnInterval = 5;     % time between car additions (s)
maxX = 1000;           % road length

%% Initialize storage
Cars = struct('X', {}, 'V', {}, 'A', {}, 'id', {});
CarData = {};
GreenTimes1 = [];
GreenTimes2 = [];
carCount = 0;
last_signal1_state = "";
last_signal2_state = "";

%% Visualization setup
f = figure;
set(f, 'position', [400,400,800,400]);
axis([0 700  0 10])
hold on
Y_const = 5;
plot([0 1000], [4.5 4.5], 'LineWidth', 30, 'color', [0.5, 0.5, 0.5]); % Road
p_signal1 = plot(300, 8, 'sr', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
p_signal2 = plot(600, 8, 'sr', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
text(300, 9, 'Signal 1', 'HorizontalAlignment', 'center');
text(600, 9, 'Signal 2', 'HorizontalAlignment', 'center');
p = [];

%% Simulation loop
for step = 1 : simDuration / dt
    time = step * dt;

    % Add a new car every spawnInterval
    if mod(time, spawnInterval) < dt
        canSpawn = true;
        if ~isempty(Cars)
            % Check distance from the last car
            if abs(Cars(end).X - 100) < 15  % Need 15 meters clearance to spawn
                canSpawn = false;
            end
        end

        if canSpawn
            carCount = carCount + 1;
            newCar = struct('X', 100, 'V', 10, 'A', 0, 'id', carCount);
            Cars(end+1) = newCar;
        end
    end


    % Signal state logic
    cycle_length = 45;
    red_duration = 20;
    yellow_duration = 5;
    green_duration = 20;
    time_in_cycle = mod(time, cycle_length);
    if time_in_cycle < green_duration
        signal1_state = "green";
    elseif time_in_cycle < green_duration + yellow_duration
        signal1_state = "yellow";
    else
        signal1_state = "red";
    end
    signal2_state = signal1_state;

    if ~strcmp(signal1_state, last_signal1_state) && strcmp(signal1_state, 'green')
        GreenTimes1(end+1) = time;
    end
    if ~strcmp(signal2_state, last_signal2_state) && strcmp(signal2_state, 'green')
        GreenTimes2(end+1) = time;
    end
    last_signal1_state = signal1_state;
    last_signal2_state = signal2_state;

    % Update each car's acceleration
    for n = 1:length(Cars)
        car = Cars(n);
        stop_positions = [];
        stop_velocities = [];

        % Traffic signal checks
        if car.X < 300 && (strcmp(signal1_state, 'red') || strcmp(signal1_state, 'yellow'))
            stop_positions(end+1) = 300;
            stop_velocities(end+1) = 0;
        end
        if car.X < 600 && (strcmp(signal2_state, 'red') || strcmp(signal2_state, 'yellow'))
            stop_positions(end+1) = 600;
            stop_velocities(end+1) = 0;
        end

        if ~isempty(stop_positions)
            ...
        elseif n == 1
            Cars(n).A = IDM(car.X, car.V, car.X + 1000, 20);  % simulate phantom lead car far away

        else
            Cars(n).A = IDM(car.X, car.V, Cars(n-1).X, Cars(n-1).V);
        end

    end

    % Update positions and velocities
    for n = 1:length(Cars)
        if Cars(n).X > maxX
            Cars(n).V = 0;
            Cars(n).A = 0;
            continue;
        end
        Cars(n).X = Cars(n).X + Cars(n).V * dt + 0.5 * Cars(n).A * dt^2;
        Cars(n).V = Cars(n).V + Cars(n).A * dt;
        Cars(n).V = max(Cars(n).V, 0);
        Cars(n).A = min(max(Cars(n).A, -8), 2);
    end

    % Update signal colors
    state_to_color = struct('red', 'r', 'yellow', 'y', 'green', 'g');
    set(p_signal1, 'MarkerFaceColor', state_to_color.(signal1_state));
    set(p_signal2, 'MarkerFaceColor', state_to_color.(signal2_state));

    % Visual update
    delete(p);
    Y = ones(1, length(Cars)) * Y_const;
    X_plot = arrayfun(@(c) c.X, Cars);
    p = plot(X_plot, Y, 'sr', 'MarkerSize', 10, 'MarkerFaceColor', [0.5, 0.1, 1]);

    % Store data
    CarData{end+1} = [time, [Cars.X]', [Cars.V]', [Cars.A]'];
    pause(0.01);
end

%% --- Post Processing ---

% Align variable-length data into matrices
maxCars = max(cellfun(@(c) size(c,2), CarData)) - 1; % max cars ever present
numSteps = length(CarData);
PosData = NaN(numSteps, maxCars);
VelData = NaN(numSteps, maxCars);
AccData = NaN(numSteps, maxCars);
TimeVec = zeros(numSteps,1);

for i = 1:numSteps
    entry = CarData{i};
    TimeVec(i) = entry(1);
    nCars = size(entry,2) - 1;
    PosData(i,1:nCars) = entry(2:1+nCars);
    VelData(i,1:nCars) = entry(2+nCars:1+2*nCars);
    AccData(i,1:nCars) = entry(2+2*nCars:end);
end

% --- Plots ---
figure;
plot(TimeVec, PosData);
title('Car Positions Over Time');
xlabel('Time (s)'); ylabel('Position (m)');
for k = 1:length(GreenTimes1)
    xline(GreenTimes1(k), '--g');
end
for k = 1:length(GreenTimes2)
    xline(GreenTimes2(k), '--g');
end
yline(300, ':k');
yline(600, ':k');
legend('Cars', 'Signal 1 Green', 'Signal 2 Green', 'Signal 1 Pos', 'Signal 2 Pos', 'Location', 'southeast');
ylim([0 1200]); grid on;

figure;
plot(TimeVec, VelData);
title('Car Velocities Over Time');
xlabel('Time (s)'); ylabel('Velocity (m/s)');

figure;
plot(TimeVec, AccData);
title('Car Accelerations Over Time');
xlabel('Time (s)'); ylabel('Acceleration (m/s^2)');

% --- Fuel Consumption ---
FuelData = zeros(size(VelData));
b0 = 0.156;  b1 = 2.450e-2;  b2 = -7.415e-4;  b3 = 5.975e-5;
c0 = 0.07224; c1 = 9.681e-2; c2 = 1.075e-3;

for t = 1:size(VelData,1)
    for car = 1:size(VelData,2)
        v = VelData(t, car);
        a = AccData(t, car);
        if isnan(v) || isnan(a), continue; end
        u_bar = max(a, 0);
        fc = b0 + b1*v + b2*v^2 + b3*v^3 + ...
             u_bar * (c0 + c1*v + c2*v^2);
        FuelData(t, car) = fc;
    end
end

figure;
plot(TimeVec, FuelData);
title('Fuel Consumption Over Time');
xlabel('Time (s)');
ylabel('Fuel Consumption (mL/s)');
legend(arrayfun(@(n) sprintf('Car %d', n), 1:size(FuelData,2), 'UniformOutput', false));
grid on;

TotalFuelPerCar = sum(FuelData, 1, 'omitnan') * dt;
figure;
bar(TotalFuelPerCar);
title('Total Fuel Consumed Per Car');
xlabel('Car Index');
ylabel('Total Fuel (mL)');
grid on;

