close all
X = [100; 90; 80; 70; 60; 50; 40; 30];
V = [8; 10; 10; 10; 10; 10; 10; 10];
A = [0; 0; 0; 0; 0; 0; 0; 0];

f = figure;
set(f, 'position', [200,200,800,200]);
axis([0 400  0 10])
hold on

Y = X * 0 + 5;
p = plot([0 1000], [4.5 4.5], 'LineWidth', 30, 'color', [0.5, 0.5, 0.5]);
%scatter(X, Y);


dt = 0.5;
CarData = [];
for t = 1 : 100
    pause(0.03);
    A(1) = IDM(X(1), V(1), X(1)+1000, 20);
    if (t <= 60)
        A(1)=IDM(X(1), V(1), 200, 0);
    end
    for n = 2 : 8
        A(n) = IDM(X(n), V(n), X(n - 1),V(n - 1));
    end
    for n = 1 : 8
        X(n) = X(n) + V(n) * dt + 0.5 * A(n) * dt^2;
        V(n) = V(n) + A(n) * dt;

    end
    delete(p);
    CarData(end+1,:) = [t * dt, X', V',A'];
    p = plot(X, Y, 'sr', 'MarkerSize', 10, 'MarkerFaceColor', [0.5, 0.1, 1]);

end

%% graph
f2 = figure;
plot(CarData(:, 1), CarData(:, 10:17));

f3 = figure;
plot(CarData(:, 1), CarData(:, 18:end));
