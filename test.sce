clf;

X = [100; 80; 70; 60];
V = [10; 10; 10; 10];
A = [0; 0; 0; 0];

f = figure();
f.figure_position = [200 200];
f.figure_size = [800 100];

clf;
set(gca(), "data_bounds", [0 0; 1000 10]);
xgrid();

Y = X * 0 + 5;

// Thick horizontal line
xpoly([0 1000], [2 2], "lines");
xset("thickness", 20);

// Plot black squares
plot2d(X', Y', -5);
