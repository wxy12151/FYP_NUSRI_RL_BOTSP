clear;clc;
city=40;
load('tour4_40.mat')
load('rl4_40.mat')
load('obj2_4_40.mat')
load('obj1_4_40.mat')
load('kroA40.mat')
load('kroB40.mat')
t=101;
w1=1-(t-1)*0.01
w2=(t-1)*0.01
for i=1:city
    rank(i)=tour(t,1,i)+1;
end
rank(city+1)=tour(t,1,1)+1;
for i=1:city+1
    x(i)=kroA40(rank(i),2);
    y(i)=kroA40(rank(i),3);
    p(i)=kroB40(rank(i),2);
    q(i)=kroB40(rank(i),3);
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
plot(obj1,obj2,'.','MarkerSize',15)
xlabel('path length of obj1')
ylabel('path length of obj2')
title(['Pareto Front'])

% figure(4)%kroA40个城市散点图
% for i=1:city
%     a(i)=kroA40(i,2);
%     b(i)=kroA40(i,3);
%     c(i)=kroB40(i,2);
%     d(i)=kroB40(i,3);
% end
% plot(a,b,'.','Color','b','MarkerSize',20);
% title('objective 1')
% for i=1:city
%     text(a(i)+100,b(i),['city',num2str(i)],'FontSize',10);
% end
% 
% figure(5)%kroB5个城市散点图
% plot(c,d,'.','Color','b','MarkerSize',20);
% title('objective 2')
% for i=1:city
%     text(c(i)+100,d(i),['city',num2str(i)],'FontSize',10);
% end