% N 300 1000000 ??以�??tsp60??RL?��???��?? mixed
% N 100 400000 ??以�??kroAB100??RL?��???��?? 200000 23.6s
HV_table = zeros(5,5);
IGD_table = zeros(5,5);
Dlist = [100,200, 150, 200];
for pp = 1:2
D=Dlist(pp);
static=5;
typem = 'rand';
alg = 'NSGAII';
alg = 'MOEAD';
if static==5
    M=3;
else
    M=2;
end
filename = ['Data/' alg '_' int2str(static) '/' alg '_MOTSP_M' int2str(M) '_' int2str(D) '_' int2str(400000) '.mat']
if ~exist(filename,'file')
    if strcmp(alg, 'NSGAII')
        alg = main('-algorithm',@NSGAII,'-problem',@MOTSP,'-N',100,'-S',static,'-M',M, '-D',D,'-mode', 2,'-evaluation',50000);
        alg = main('-algorithm',@NSGAII,'-problem',@MOTSP,'-N',100,'-S',static,'-M',M, '-D',D,'-mode', 2,'-evaluation',100000);
        alg = main('-algorithm',@NSGAII,'-problem',@MOTSP,'-N',100,'-S',static,'-M',M, '-D',D,'-mode', 2,'-evaluation',200000);
        alg = main('-algorithm',@NSGAII,'-problem',@MOTSP,'-N',100,'-S',static,'-M',M, '-D',D,'-mode', 2,'-evaluation',400000);
        alg = func2str(alg);
    else
        t1 = clock;
%         17.88  D=100
%         19.01 D=150
%         21.53 D=200
        alg = main('-algorithm',@MOEAD,'-problem',@MOTSP,'-N',100,'-S',static,'-M',M, '-D',D,'-mode', 2,'-evaluation',50000);
        t2 = clock;
        etime(t2,t1)
        t1 = clock;
%         35.73 D=100
%         38.20 D=150
%         42.56 D=200
        alg = main('-algorithm',@MOEAD,'-problem',@MOTSP,'-N',100,'-S',static,'-M',M, '-D',D,'-mode', 2,'-evaluation',100000);
        t2 = clock;
        etime(t2,t1)
        t1 = clock;
%         70.94 D=100
%         79.39 D=150
%         84.36 D=200
        alg = main('-algorithm',@MOEAD,'-problem',@MOTSP,'-N',100,'-S',static,'-M',M, '-D',D,'-mode', 2,'-evaluation',200000);
        t2 = clock;
        etime(t2,t1)
        t1 = clock;
%         139.13 D=100
%         154.78 D=150
%         162.73 D=200
        alg = main('-algorithm',@MOEAD,'-problem',@MOTSP,'-N',100,'-S',static,'-M',M, '-D',D,'-mode', 2,'-evaluation',400000);
        t2 = clock;
        etime(t2,t1)
        alg = func2str(alg);
    end
end

light_blue = [0.5843,0.8157,0.9882];
blue = [0,0.4470,0.7410];
orange = [ 0.91,0.41,0.17];
gray = [211,211,211]/255;
color = [55,126,184]/255;
light_red =  [255,204,204]/255;
light_red2 =  [255,153,153]/255;

alg_dir  = ['Data/' alg '_' int2str(static) '/' alg '_MOTSP_M' int2str(M) '_' int2str(D) '_' int2str(50000) '.mat'];
load(alg_dir)
nsga50000 = Population.objs;
alg_dir  = ['Data/' alg '_' int2str(static) '/' alg '_MOTSP_M' int2str(M) '_' int2str(D) '_' int2str(100000) '.mat'];
load(alg_dir)
nsga100000 = Population.objs;
alg_dir  = ['Data/' alg '_' int2str(static) '/' alg '_MOTSP_M' int2str(M) '_' int2str(D) '_' int2str(200000) '.mat'];
load(alg_dir)
nsga200000 = Population.objs;
alg_dir  = ['Data/' alg '_' int2str(static) '/' alg '_MOTSP_M' int2str(M) '_' int2str(D) '_' int2str(400000) '.mat'];
load(alg_dir)
nsga400000 = Population.objs;
% nsga = nondominate(nsga);
size = 6;
% set(0,'defaultLineLineWidth',1.2);

h1=plot3(nsga50000(:,1),nsga50000(:,2) , nsga50000(:,3), 'ro', 'Marker'          , 'o'  , ...
  'MarkerSize'      , 5           , ...
  'MarkerEdgeColor' , gray      , ...
  'MarkerFaceColor' , blue);
hold on
h2=plot3(nsga100000(:,1),nsga100000(:,2), nsga100000(:,3),'ro', 'Marker'          , 'o'  , ...
  'MarkerSize'      , 5           , ...
  'MarkerEdgeColor' , gray      , ...
  'MarkerFaceColor' , 'g');
hold on
h3=plot3(nsga200000(:,1),nsga200000(:,2),nsga200000(:,3),'ro', 'Marker'          , 'o'  , ...
  'MarkerSize'      , 5           , ...
  'MarkerEdgeColor' , gray      , ...
  'MarkerFaceColor' , 'm');
hold on
h4=plot3(nsga400000(:,1),nsga400000(:,2), nsga400000(:,3),'ro', 'Marker'          , 'o'  , ...
  'MarkerSize'      , 5           , ...
  'MarkerEdgeColor' , gray      , ...
  'MarkerFaceColor' , 'c');

grid on;
rlname = ['rl' int2str(static) '_' int2str(D) '.mat']
load(rlname)
hold on
h0=plot3(rl(:,1), rl(:,2), rl(:,3),'ro', 'Marker'          , 'o'  , ...
  'MarkerSize'      , 7           , ...
  'MarkerEdgeColor' , orange      , ...
  'MarkerFaceColor' , light_red);
xlim([min(rl(:,1))-2,max(rl(:,1))+2])
xlabel('\itf\rm_1'); ylabel('\itf\rm_2');zlabel('\itf\rm_3');
set(gca,'FontSize',12.5);
set(get(gca,'XLabel'),'FontSize',14)
set(get(gca,'YLabel'),'FontSize',14)
if strcmp(alg, 'NSGAII')
    legend([h0,h1,h2,h3,h4],"RL","NSGAII-500","NSGAII-1000","NSGAII-2000","NSGAII-4000",'location','northeast')
else
    legend([h0,h1,h2,h3,h4],"RL","MOEAD-500","MOEAD-1000","MOEAD-2000","MOEAD-4000",'location','northeast')
end
set(get(gca,'legend'),'FontSize',13.0,'FontName','Times New Roman');
view([0.3,-0.55,0.25])
x0=100;
y0=100;
width = 480;
height = 450;
set(gcf,'position',[x0,y0,width,height])
set(gca,'linewidth',1.2)
% 
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3) - 0.01;
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
savepath = ['PIC/' int2str(static) '_' typem int2str(D) '_pareto_' alg '.pdf']
% print(fig,savepath,'-dpdf','-r600')
% close


HV_table(1,pp) = HV(nsga50000,PF);
HV_table(2,pp) = HV(nsga100000,PF);
HV_table(3,pp) = HV(nsga200000,PF);
HV_table(4,pp) = HV(nsga400000,PF);
HV_table(5,pp) = HV(rl,PF);
IGD_table(1,pp) = IGD(nsga50000,PF);
IGD_table(2,pp) = IGD(nsga100000,PF);
IGD_table(3,pp) = IGD(nsga200000,PF);
IGD_table(4,pp) = IGD(nsga400000,PF);
IGD_table(5,pp) = IGD(rl,PF);
end
 if 0
load rl1.mat
hold on
h1=plot(rl(:,1), rl(:,2),'ro', 'Marker'          , 'o'  , ...
  'MarkerSize'      , 7           , ...
  'MarkerEdgeColor' , blue      , ...
  'MarkerFaceColor' , light_blue);
load rl.mat
hold on
h2=plot(rl(:,1), rl(:,2),'ro', 'Marker'          , 'o'  , ...
  'MarkerSize'      , 7           , ...
  'MarkerEdgeColor' , orange      , ...
  'MarkerFaceColor' , light_red);

legend([h1,h2],"no_transfer","transfer")
 end
 
function out = nondominate(x)
inds = [];
for i=1:length(x)
    flag = 1;
    for j=1:length(x)
        if x(i,1)>x(j,1) && x(i,2)>x(j,2)
            flag = 0;
            break
        end
    end
    if flag
      inds = [inds, i];  
    end
end
out = x(inds,:);
end
