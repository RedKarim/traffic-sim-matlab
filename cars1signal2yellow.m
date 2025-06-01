close all
clear


Car.ID = 1;
Car.V = 10;
Car.X = 100;
Car.A = 5;

% Visualizations
f = figure;
set(f, 'position', [400,400,800,400]);
axis([0 700  0 10])
hold on
x = Car.X
Y = x * 0 + 5

% Road
p_road = plot([0 1000], [4.5 4.5], 'LineWidth', 30, 'color', [0.5, 0.5, 0.5]);

% Traffic signals
p_signal1 = plot(300, 8, 'sr', 'MarkerSize', 15, 'MarkerFaceColor', 'r');  % Red signal at x=300
p_signal2 = plot(600, 8, 'sr', 'MarkerSize', 15, 'MarkerFaceColor', 'r');  % Red signal at x=600
text(300, 9, 'Signal 1', 'HorizontalAlignment', 'center');
text(600, 9, 'Signal 2', 'HorizontalAlignment', 'center');

p = plot(x, Y, 'sr', 'MarkerSize', 10, 'MarkerFaceColor', [0.5, 0.1, 1]);

for n = 1:N
   if(Car(n).X <= 300 && (strcmp(signal1_state, 'red') || strcmp(signal1_state, 'yellow'))
      a(n) = IDM(Car(n).X, Car(n).V, 300, 0);
   endif
endfor
fn = 1;
dt = 0.5;

for t = 1:700
  pause(0.006);
  M(fn) = getframe(f);
  fn = fn + 1;
  N = length(Car);
  for n = 1:N
    if (n==1)
      Car(n).A = IDM(Car(n).X, Car(n).V, Car(n).X+1000, 0);
    else
      Car(n).A = IDM(Car(n).X, Car(n).V, Car(n-1).X, Car(n-1).V);
    endif
  endfor
  for n = 1:N
    Car(n).X = Car(n).X + Car(n).V * dt + Car(n).A * dt^2;
    Car(n).V = Car(n).V + Car(n).A * dt;
  end
  X = [Car(1:end).X];
  Y = X * 0 + 5;
  delete(p);
  p = plot(X, Y, 'sr', 'MarkerSize', 10, 'MarkerFaceColor', [0.5, 0.1, 1]);
  if (Car(end).X > 50)
    Car(end + 1).ID = Car(end).ID + 1;
    Car(end).X = Car(end-1).X - (100 + 200 * rand);
    Car(end).V = 10;
  endif
  if(Car(1).X > 650)
    Car(1) = [];
  endif
endfor

