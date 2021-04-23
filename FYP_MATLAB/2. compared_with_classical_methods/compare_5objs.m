
HV_table = zeros(5,5);
Dlist = [100, 200];
algs = {'NSGAII','MOEAD'};
for a=1:2
for pp = 1:2
D=Dlist(pp);
static=6;
typem = 'rand';
alg=algs{a}

M=5;
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

rlname = ['rl' int2str(static) '_' int2str(D) '.mat']
load(rlname)


idx=[0,2];
HV_table(1,pp+idx(a)) = HV(nsga50000,PF);
HV_table(2,pp+idx(a)) = HV(nsga100000,PF);
HV_table(3,pp+idx(a)) = HV(nsga200000,PF);
HV_table(4,pp+idx(a)) = HV(nsga400000,PF);
HV_table(5,pp+idx(a)) = HV(rl,PF);
end
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
