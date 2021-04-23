clear;clc;
city=20;
load('tour4_20.mat')
load('rl4_20.mat')
load('obj2_4_20.mat')
load('obj1_4_20.mat')
load('kroA20.mat')
load('kroB20.mat')
t=1;
w1=1-(t-1)*0.01
w2=(t-1)*0.01
for i=1:city
    rank(i)=tour(t,1,i)+1;
end
rank(city+1)=tour(t,1,1)+1;
for i=1:city+1
    x(i)=kroA20(rank(i),2);
    y(i)=kroA20(rank(i),3);
    p(i)=kroB20(rank(i),2);
    q(i)=kroB20(rank(i),3);
end

figure(1)
plot(x,y)
title(['(w1,w2)=(',num2str(w1),',',num2str(w2),'),path of obj1'])
for i=1:city
%     text(x(i),y(i)),['',num2str(i)]);
    text(kroA20(i,2),kroA20(i,3),['',num2str(i-1)]);
end

figure(2)
plot(p,q)
title(['(w1,w2)=(',num2str(w1),',',num2str(w2),'),path of obj2'])
for i=1:city
%     text(p(i),q(i),['',num2str(i)]);
    text(kroB20(i,2),kroB20(i,3),['',num2str(i-1)]);
end

figure(3)
obj1=rl(:,1);
obj2=rl(:,2);
plot(obj1,obj2,'.','MarkerSize',20)
xlabel('path length of obj1')
ylabel('path length of obj2')
title(['Pareto Front'])