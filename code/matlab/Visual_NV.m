clear;
clc
data = load('test.txt');
x = data(:, 1);
y = data(:, 2);
z = data(:, 3);
dx= data(:, 4);
dy= data(:, 5);
dz= data(:, 6);
figure;
plot3(x,y,z,'b.')
hold on
quiver3(x,y,z,dx,dy,dz, 'LineWidth', 1.5, 'Color', 'red', 'AutoScale', 'on', 'AutoScaleFactor', 0.5);
axis equal;
grid on;
xlabel('X');
ylabel('Y');
zlabel('Z');
set(gca,'color','white')
% export_fig(gca,'test.png','-transparent','-r300')
% legend('Boundary point','Normal vector')

