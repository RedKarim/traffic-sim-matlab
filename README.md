# Traffic Simulation in MATLAB

This project simulates traffic flow with 30 cars and two traffic signals using MATLAB. The simulation visualizes car positions, velocities, and accelerations as they interact with timed traffic lights, providing insight into traffic dynamics and signal control.

## Features

- Simulates 30 cars moving along a single-lane road.
- Two traffic signals (at positions 300m and 600m) with configurable red, yellow, and green cycles.
- Cars stop for red and yellow lights and proceed on green.
- Realistic car-following behavior using the Intelligent Driver Model (IDM).
- Visualizations for car positions, velocities, and accelerations over time.
- Plots show actual signal state transitions and car responses.
- Handles edge cases (e.g., prevents negative velocities, clamps acceleration, removes cars that leave the road).

## Requirements

- MATLAB (R2018b or newer recommended)
- No additional toolboxes required

## How to Run

1. Clone or download this repository.
2. Open `cars30signal2yellow.m` in MATLAB.
3. Run the script:
   ```matlab
   cars30signal2yellow
   ```

## Simulation Details

- **Number of Cars:** 30
- **Road Length:** 1000 meters (cars are removed from the simulation after passing this point)
- **Traffic Signals:**
  - Signal 1 at 300m
  - Signal 2 at 600m
  - Both signals have configurable cycles (default: 20s red, 5s yellow, 20s green)
- **Car Behavior:**
  - Cars stop for red/yellow lights if before the signal.
  - Cars follow the Intelligent Driver Model (IDM) for realistic acceleration and deceleration.
  - Velocities are clamped to prevent negative (reverse) motion.
  - Accelerations are clamped to realistic values ([-8, 2] m/s²).

## Output

- **Position Plot:** Shows car positions over time, with green lines indicating when signals turn green and dashed lines marking signal locations.
- **Velocity Plot:** Shows each car's velocity over time.
- **Acceleration Plot:** Shows each car's acceleration over time.

## Customization

- You can change the number of cars, signal positions, and signal timing by editing the parameters at the top of `cars30signal2yellow.m`.
- The IDM function can be adjusted for different driving behaviors.

## License

This project is provided for educational and research purposes. Feel free to use and modify it as needed.
