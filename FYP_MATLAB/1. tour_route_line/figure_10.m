clear;clc;
city=10;
load('tour4_10.mat')
load('rl4_10.mat')
load('obj2_4_10.mat')
load('obj1_4_10.mat')
load('kroA10.mat')
load('kroB10.mat')
t=1;
w1=1-(t-1)*0.01
w2=(t-1)*0.01
for i=1:city
    rank(i)=tour(t,1,i)+1;
end
rank(city+1)=tour(t,1,1)+1;
for i=1:city+1
    x(i)=kroA10(rank(i),2);
    y(i)=kroA10(rank(i),3);
    p(i)=kroB10(rank(i),2);
    q(i)=kroB10(rank(i),3);
end

figure(1)
plot(x,y,'.','MarkerSize',15)
hold on;
plot(x,y)
title(['(w1,w2)=(',num2str(w1),',',num2str(w2),'),path of obj1'])

figure(2)
plot(p,q,'.','MarkerSize',15)
hold on;
plot(p,q)
title(['(w1,w2)=(',num2str(w1),',',num2str(w2),'),path of obj2'])

figure(3)
obj1=rl(:,1);
obj2=rl(:,2);
plot(obj1,obj2,'.','MarkerSize',20)
xlabel('path length of obj1')
ylabel('path length of obj2')
title(['Pareto Front'])