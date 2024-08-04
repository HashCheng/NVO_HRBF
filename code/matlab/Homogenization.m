clear;
clc

data = load('data.txt');
x = data(:, 1);
y = data(:, 2);
z = data(:, 3);
CPnum = size(x,1);
px = LU_B1(CPnum, x);
py = LU_B1(CPnum, y);
pz = LU_B1(CPnum, z);

x(CPnum+1) = x(1);
y(CPnum+1) = y(1);
z(CPnum+1) = z(1);
figure;
plot3(x,y,z,'ro-');
hold on;
for i=1:CPnum
    c=num2str(i);
    c=[' ',c];
end

for i=1:CPnum+1%用这个循环
    c=num2str(i);
    c=[' ',c];
    %     text(px(i),py(i),pz(i),c)
    %     plot3(px(i),py(i),pz(i),'*');
end
axis equal

px(CPnum+3) = px(3);
py(CPnum+3) = py(3);
pz(CPnum+3) = pz(3);
px(CPnum+4) = px(4);
py(CPnum+4) = py(4);
pz(CPnum+4) = pz(4);
nP = 4;
delta = 1.0/nP;
for j=1:CPnum
    u = 0.0;
    for i=1:nP
        p = px';
        Xi = p(j:j+3);
        xx(i+(j-1)*nP) = Cubic_Bsp(u,Xi);
        p = py';
        Yi = p(j:j+3);
        yy(i+(j-1)*nP) = Cubic_Bsp(u,Yi);

        p = pz';
        Zi = p(j:j+3);
        zz(i+(j-1)*nP) = Cubic_Bsp(u,Zi);

        u = u + delta;
    end
end
xx(end+1) = x(1);
yy(end+1) = y(1);
zz(end+1) = z(1);
h=[xx',yy',zz']
plot3(xx,yy,zz,'b.-')

xlabel('x');
ylabel('y');
zlabel('z');

function px = LU_B1(CPnum, V)
a = 1;
b = 4;
c = 1;
d = 1;
e = 1;

f = zeros(CPnum-1,1);
g = zeros(CPnum-2,1);
h = zeros(CPnum,1);
k = zeros(CPnum-1,1);

h(1) = b;
for i=1:CPnum-2
    f(i) = a/h(i);
    h(i+1) = b - f(i)*c;
end

g(1) = d/h(1);
for i=1:CPnum-3
    g(i+1) = -g(i)*c/h(i+1);
end
f(CPnum-1) = ( a-g(CPnum-2)*c )/h(CPnum-1);
k(1) = e;

for i=1:CPnum-3
    k(i+1) = -f(i)*k(i);
end

k(CPnum-1) = c - f(CPnum-2)*k(CPnum-2);

gksum = 0;
for i=1:CPnum-2
    gksum = gksum + g(i)*k(i);
end

h(CPnum) = b - gksum - f(CPnum-1)*c;
x = zeros(CPnum,1);
x(1) = 6*V(end);
for i=1:CPnum-2
    x(i+1) = 6*V(i) - f(i)*x(i);
end

gxsum = 0;
for i=1:CPnum-2
    gxsum = gxsum + g(i)*x(i);
end
x(CPnum) = 6*V(CPnum-1) - gxsum - f(CPnum-1)*x(CPnum-1);

px = zeros(CPnum+2,1);

px(CPnum) = x(CPnum)/h(CPnum);
px(CPnum-1) = ( x(CPnum-1)-k(CPnum-1)*px(CPnum) )/h(CPnum-1);

for i=CPnum-2:-1:1
    px(i) = ( x(i)-c*px(i+1)-k(i)*px(CPnum) )/h(i);
end
px(CPnum+1) = px(1);
px(CPnum+2) = px(2);
end

function p = Cubic_Bsp(u,x)
b(1) = ((1-u)^3)/6;
b(2) = (3*u^3-6*u^2+4)/6;
b(3) = (-3*u^3+3*u^2+3*u+1)/6;
b(4) = (u^3)/6;
p = x*b';
end
