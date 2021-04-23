clear;clc;
city=5;
load('tour4_5.mat')
load('rl4_5.mat')
load('obj2_4_5.mat')
load('obj1_4_5.mat')
load('kroA5.mat')
load('kroB5.mat')
t=1;
w1=1-(t-1)*0.01
w2=(t-1)*0.01
for i=1:city
    rank(i)=tour(t,1,i)+1;
end
rank(city+1)=tour(t,1,1)+1;
for i=1:city+1
    x(i)=kroA5(rank(i),2);
    y(i)=kroA5(rank(i),3);
    p(i)=kroB5(rank(i),2);
    q(i)=kroB5(rank(i),3);
end

% figure(1)%kroA5个城市散点图
for i=1:city
    a(i)=kroA5(i,2);
    b(i)=kroA5(i,3);
    c(i)=kroB5(i,2);
    d(i)=kroB5(i,3);
end
% plot(a,b,'.','Color','b','MarkerSize',30);
% for i=1:city
%     text(a(i)+100,b(i),['city',num2str(i)],'FontSize',20);
% end
% 
% figure(2)%kroB5个城市散点图
% plot(c,d,'.','Color','b','MarkerSize',30);
% for i=1:city
%     text(c(i)+100,d(i),['city',num2str(i)],'FontSize',20);
% end

figure(3)
plot(x,y)
title(['(w1,w2)=(',num2str(w1),',',num2str(w2),'),path of obj1'])
hold on;
plot(a,b,'.','Color','b','MarkerSize',30);
for i=1:city
    text(a(i)+100,b(i),['city',num2str(i)],'FontSize',15);
end


figure(4)
plot(p,q)
title(['(w1,w2)=(',num2str(w1),',',num2str(w2),'),path of obj2'])
hold on;
plot(c,d,'.','Color','b','MarkerSize',30);
for i=1:city
    text(c(i)+100,d(i),['city',num2str(i)],'FontSize',15);
end

figure(5)
obj1=rl(:,1);
obj2=rl(:,2);
plot(obj1,obj2,'.','MarkerSize',20)
xlabel('path length of obj1')
ylabel('path length of obj2')
title(['Pareto Front'])
