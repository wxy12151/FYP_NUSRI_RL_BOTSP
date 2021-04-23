clear;clc;
city=100;
load('tour4_100.mat')
load('rl4_100.mat')
load('obj2_4_100.mat')
load('obj1_4_100.mat')
load('kroA100.mat')
load('kroB100.mat')
t=101;
w1=1-(t-1)*0.01
w2=(t-1)*0.01
for i=1:city
    rank(i)=tour(t,1,i)+1;
end
rank(city+1)=tour(t,1,1)+1;
for i=1:city+1
    x(i)=kroA100(rank(i),2);
    y(i)=kroA100(rank(i),3);
    p(i)=kroB100(rank(i),2);
    q(i)=kroB100(rank(i),3);
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

% figure(1)
% plot(x,y)
% title(['(w1,w2)=(',num2str(w1),',',num2str(w2),'),path of obj1'])
% for i=1:city
%     text(x(i),y(i),['',num2str(i)]);
% end
% 
% figure(2)
% plot(p,q)
% title(['(w1,w2)=(',num2str(w1),',',num2str(w2),'),path of obj2'])
% for i=1:city
%     text(p(i),q(i),['',num2str(i)]);
% end

figure(3)
obj1=rl(:,1);
obj2=rl(:,2);
plot(obj1,obj2,'.','MarkerSize',15)
xlabel('path length of obj1')
ylabel('path length of obj2')
title(['Pareto Front'])