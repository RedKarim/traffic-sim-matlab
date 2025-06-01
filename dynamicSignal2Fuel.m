close all

% Simulation timing parameters
simulation_duration = 600;  % Total simulation time in seconds
car_spawn_interval = 10;    % Time between car spawns in seconds
dt = 0.5;                  % Time step for simulation

% Calculate maximum number of cars based on simulation parameters
max_cars = ceil(simulation_duration / car_spawn_interval);  % Maximum number of cars that can spawn in the simulation

% Initialize car tracking
cars = struct('X', {}, 'V', {}, 'A', {}, 'active', {}, 'id', {});
next_car_id = 1;

% Visualizations
f = figure;
set(f, 'position', [400,400,800,400]);
axis([0 700  0 10])
hold on
Y = zeros(max_cars, 1) + 5;  % Initialize Y positions for all possible cars

% Road
p_road = plot([0 1000], [4.5 4.5], 'LineWidth', 30, 'color', [0.5, 0.5, 0.5]);

% Traffic signals
p_signal1 = plot(300, 8, 'sr', 'MarkerSize', 15, 'MarkerFaceColor', 'r');  % Red signal at x=300
p_signal2 = plot(600, 8, 'sr', 'MarkerSize', 15, 'MarkerFaceColor', 'r');  % Red signal at x=600
text(300, 9, 'Signal 1', 'HorizontalAlignment', 'center');
text(600, 9, 'Signal 2', 'HorizontalAlignment', 'center');

% Initialize plot for cars
p = plot(zeros(max_cars, 1), Y, 'sr', 'MarkerSize', 10, 'MarkerFaceColor', [0.5, 0.1, 1]);

CarData = {};
GreenTimes1 = [];
GreenTimes2 = [];
last_signal1_state = "";
last_signal2_state = "";

% Convert simulation time to steps
total_steps = ceil(simulation_duration / dt);

% Prepare car history for unique car tracking
CarHistory = struct();

for t = 1:total_steps
    current_time = t * dt;
    pause(0.01);

    % Spawn new car if it's time
    if mod(current_time, car_spawn_interval) < dt && length(cars) < max_cars
        new_car = struct('X', 0, 'V', 10, 'A', 0, 'active', true, 'id', next_car_id);
        cars(next_car_id) = new_car;
        next_car_id = next_car_id + 1;
    end

    % Traffic signal logic
    cycle_length = 45; % total cycle duration in seconds
    red_duration = 20;  % red duration in seconds
    yellow_duration = 5; % yellow duration in seconds
    green_duration = 20; % green duration in seconds

    % Calculate signal states ONCE
    time_in_cycle = mod(current_time, cycle_length);
    if time_in_cycle < green_duration
        signal1_state = "green";
    elseif time_in_cycle < green_duration + yellow_duration
        signal1_state = "yellow";
    else
        signal1_state = "red";
    end
    signal2_state = signal1_state;

    % Record green transitions for plotting
    if ~strcmp(signal1_state, last_signal1_state) && strcmp(signal1_state, 'green')
        GreenTimes1(end+1) = current_time;
    end
    if ~strcmp(signal2_state, last_signal2_state) && strcmp(signal2_state, 'green')
        GreenTimes2(end+1) = current_time;
    end
    last_signal1_state = signal1_state;
    last_signal2_state = signal2_state;

    % Car logic
    active_cars = find([cars.active]);
    for n = active_cars
        stop_positions = [];
        stop_velocities = [];
        % Check signal 1
        if cars(n).X < 300 && (strcmp(signal1_state, 'red') || strcmp(signal1_state, 'yellow'))
            stop_positions(end+1) = 300;
            stop_velocities(end+1) = 0;
        end
        % Check signal 2
        if cars(n).X < 600 && (strcmp(signal2_state, 'red') || strcmp(signal2_state, 'yellow'))
            stop_positions(end+1) = 600;
            stop_velocities(end+1) = 0;
        end

        if ~isempty(stop_positions)
            % Stop for the nearest signal ahead
            [min_pos, idx] = min(stop_positions);
            cars(n).A = IDM(cars(n).X, cars(n).V, min_pos, stop_velocities(idx));
        elseif n == active_cars(1)
            % Lead car, no car in front
            cars(n).A = IDM(cars(n).X, cars(n).V, cars(n).X+1000, 20);
        else
            % Follow the car in front
            prev_car_idx = active_cars(find(active_cars == n) - 1);
            cars(n).A = IDM(cars(n).X, cars(n).V, cars(prev_car_idx).X, cars(prev_car_idx).V);
        end
        % Track car history by unique id
        car_id = cars(n).id;
        if ~isfield(CarHistory, sprintf('car%d', car_id))
            CarHistory.(sprintf('car%d', car_id)) = struct('time', [], 'v', [], 'a', [], 'fuel', []);
        end
        % Calculate fuel for this car at this time
        v = cars(n).V;
        a = cars(n).A;
        u_bar = max(a, 0);
        fc = b0 + b1*v + b2*v^2 + b3*v^3 + u_bar * (c0 + c1*v + c2*v^2);
        CarHistory.(sprintf('car%d', car_id)).time(end+1) = current_time;
        CarHistory.(sprintf('car%d', car_id)).v(end+1) = v;
        CarHistory.(sprintf('car%d', car_id)).a(end+1) = a;
        CarHistory.(sprintf('car%d', car_id)).fuel(end+1) = fc;
    end

    % Set signal colors
    state_to_color = struct('red', 'r', 'yellow', 'y', 'green', 'g');
    set(p_signal1, 'MarkerFaceColor', state_to_color.(signal1_state));
    set(p_signal2, 'MarkerFaceColor', state_to_color.(signal2_state));

    % Update positions and velocities
    X_plot = [];
    V_plot = [];
    A_plot = [];
    for n = active_cars
        if cars(n).X > 1000
            cars(n).active = false;
            continue;
        end
        cars(n).X = cars(n).X + cars(n).V * dt + 0.5 * cars(n).A * dt^2;
        cars(n).V = cars(n).V + cars(n).A * dt;
        cars(n).V = max(cars(n).V, 0);
        cars(n).A = min(max(cars(n).A, -8), 2);
        if cars(n).X >= 0 && cars(n).X <= 1000 && cars(n).active
            X_plot(end+1) = cars(n).X;
            V_plot(end+1) = cars(n).V;
            A_plot(end+1) = cars(n).A;
        end
    end
    delete(p);
    CarData{end+1} = [current_time, X_plot, V_plot, A_plot];
    p = plot(X_plot, ones(size(X_plot))*5, 'sr', 'MarkerSize', 10, 'MarkerFaceColor', [0.5, 0.1, 1]);
end

%% Align variable-length CarData into matrices for plotting
numSteps = length(CarData);
maxCars = max(cellfun(@(c) size(c,2), CarData)) - 1;
PosData = NaN(numSteps, max_cars);
VelData = NaN(numSteps, max_cars);
AccData = NaN(numSteps, max_cars);
TimeVec = zeros(numSteps,1);
for i = 1:numSteps
    entry = CarData{i};
    TimeVec(i) = entry(1);
    nCars = (size(entry,2)-1)/3;
    if nCars > 0
        PosData(i,1:nCars) = entry(2:1+nCars);
        VelData(i,1:nCars) = entry(2+nCars:1+2*nCars);
        AccData(i,1:nCars) = entry(2+2*nCars:end);
    end
end

f2 = figure;
plot(TimeVec, PosData);
title('Car Positions Over Time');
xlabel('Time'); ylabel('Position');
hold on
% Signal change (plot actual green transitions)
for k = 1:length(GreenTimes1)
    plot([GreenTimes1(k), GreenTimes1(k)], [0, 1200], '--g', 'LineWidth', 1);
end
for k = 1:length(GreenTimes2)
    plot([GreenTimes2(k), GreenTimes2(k)], [0, 1200], '--g', 'LineWidth', 1);
end
% Add vertical lines for signal positions
plot(xlim, [300, 300], ':k', 'LineWidth', 1);
plot(xlim, [600, 600], ':k', 'LineWidth', 1);
legend('Cars', 'Signal 1 → Green', 'Signal 2 → Green', 'Signal 1 Pos', 'Signal 2 Pos', 'Location', 'southeast');
ylim([0 1200]);
grid on;

f3 = figure;
plot(TimeVec, VelData);
title('Car Velocities Over Time');
xlabel('Time'); ylabel('Velocity');

f4 = figure;
plot(TimeVec, AccData);
title('Car Accelerations Over Time');
xlabel('Time'); ylabel('Acceleration');

%% Fuel consumption summary by unique car id
car_ids = fieldnames(CarHistory);
num_cars = length(car_ids);
TotalFuelPerCar = zeros(1, num_cars);
for i = 1:num_cars
    car_hist = CarHistory.(car_ids{i});
    TotalFuelPerCar(i) = sum(car_hist.fuel) * dt;
end
f5 = figure;
hold on;
for i = 1:num_cars
    plot(CarHistory.(car_ids{i}).time, CarHistory.(car_ids{i}).fuel);
end
hold off;
title('Fuel Consumption Over Time (by Car ID)');
xlabel('Time (s)');
ylabel('Fuel Consumption (mL/s)');
legend(arrayfun(@(i) sprintf('Car %d', i), 1:num_cars, 'UniformOutput', false));
grid on;

f6 = figure;
bar(1:num_cars, TotalFuelPerCar);
title('Total Fuel Consumed Per Car (by Car ID)');
xlabel('Car ID');
ylabel('Total Fuel (mL)');
grid on;
xlim([0 num_cars+1]);

% --- Aggregate by car flow (q = number of cars per minute) ---
car_entry_times = zeros(1, num_cars);
for i = 1:num_cars
    car_entry_times(i) = CarHistory.(car_ids{i}).time(1);
end
max_time = max(car_entry_times);
minute_edges = 0:60:(ceil(max_time/60)*60);
[~, bin] = histc(car_entry_times, minute_edges);
num_minutes = length(minute_edges)-1;
q = zeros(1, num_minutes); % car flow per minute
AvgVelPerMinute = zeros(1, num_minutes);
IdleTimePerMinute = zeros(1, num_minutes);
for m = 1:num_minutes
    cars_in_minute = find(bin == m);
    q(m) = length(cars_in_minute);
    if q(m) > 0
        avg_vels = zeros(1, q(m));
        idle_times = zeros(1, q(m));
        for k = 1:q(m)
            v = CarHistory.(car_ids{cars_in_minute(k)}).v;
            avg_vels(k) = sum(v) / length(v);
            idle_times(k) = sum(v < 0.1) * dt;
        end
        AvgVelPerMinute(m) = mean(avg_vels);
        IdleTimePerMinute(m) = mean(idle_times);
    else
        AvgVelPerMinute(m) = NaN;
        IdleTimePerMinute(m) = NaN;
    end
end

% Debugging for f7 and f8
disp('Debugging f7 and f8 data:');
disp(['q = ', num2str(q)]);
disp(['AvgVelPerMinute = ', num2str(AvgVelPerMinute)]);
disp(['IdleTimePerMinute = ', num2str(IdleTimePerMinute)]);

f7 = figure;
bar(1:num_minutes, AvgVelPerMinute);
title('Average Velocity vs Car Flow (per minute)');
xlabel('q (min)');
ylabel('Average Velocity (m/s)');
grid on;
xticks(1:num_minutes);
xticklabels(1:num_minutes);

f8 = figure;
bar(1:num_minutes, IdleTimePerMinute);
title('Average Idling Time vs Car Flow (per minute)');
xlabel('q (min)');
ylabel('Average Idling Time (s)');
grid on;
xticks(1:num_minutes);
xticklabels(1:num_minutes);

% Display how many cars entered the simulation
fprintf('Number of cars that entered the simulation: %d\n', next_car_id - 1);
disp('Cars with nonzero total fuel:');
disp(find(TotalFuelPerCar > 0));