statics=[3,4];
D=200;
ls_list=[100,200,300];
light_blue = [0.5843,0.8157,0.9882];
blue = [0,0.4470,0.7410];
orange = [ 0.91,0.41,0.17];
gray = [211,211,211]/255;
color = [55,126,184]/255;
light_red =  [255,204,204]/255;
light_red2 =  [255,153,153]/255;
black = [0,0,0];
for i= 1:2
    static=statics(i);
    ls_count = 100;
    load(['rl_ori' int2str(static) '_' int2str(D) '_' int2str(ls_count) '.mat'])
    rl_ori=nondominate(rl_ori);
    figure
    set(0,'defaultLineLineWidth',1.2);
    plot(rl_ori(:,1),rl_ori(:,2),'r.', 'Marker'          , 'o'  , ...
      'MarkerSize'      , 5.5           , ...
      'MarkerEdgeColor' , orange      , ...
      'MarkerFaceColor' , light_red);


    hold on
    
        
       load(['ls' int2str(static) '_' int2str(D) '_100.mat'])
        ls=nondominate(ls);
        plot(ls(:,1),ls(:,2),'r.', 'Marker'          , 's'  , ...
      'MarkerSize'      , 4           , ...
      'MarkerEdgeColor' , black      , ...
      'MarkerFaceColor' , gray);
  
       load(['ls' int2str(static) '_' int2str(D) '_200.mat'])
        ls=nondominate(ls);
        plot(ls(:,1),ls(:,2),'r.', 'Marker'          , '*'  , ...
      'MarkerSize'      , 4           , ...
  'MarkerEdgeColor' , blue      , ...
  'MarkerFaceColor' , black );
  
%        load(['ls' int2str(static) '_' int2str(D) '_300.mat'])
%         ls=nondominate(ls);
%         plot(ls(:,1),ls(:,2),'r.', 'Marker'          , 'o'  , ...
%       'MarkerSize'      , 4           , ...
%       'MarkerEdgeColor' , 'b'      , ...
%       'MarkerFaceColor' , 'b');
        

    
    hold off
    xlabel('\itf\rm_1'); ylabel('\itf\rm_2');
    set(gca,'FontSize',12.5);
    set(get(gca,'XLabel'),'FontSize',14)
    set(get(gca,'YLabel'),'FontSize',14)
    legend('RL','MOGLS-100','MOGLS-200','MOGLS-300')
    set(get(gca,'legend'),'FontSize',13.0,'FontName','Times New Roman');
    x0=100;
    y0=100;
    width = 465;
    height = 450;
    set(gcf,'position',[x0,y0,width,height])
    set(gca,'linewidth',1.2)

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
    savepath = ['PIC/ls_' int2str(static) '.pdf']
     print(fig,savepath,'-dpdf','-r600')
end
% % % % % % % % % % % % % % % % This is used to show every figure
% HVs=zeros(3,4);
% statics=[4,3];
% Dlist=[100,200];
% ls_list=[100,200,300];
% hvs = table({'LS';'RL';'RL+LS'});
% light_blue = [0.5843,0.8157,0.9882];
% blue = [0,0.4470,0.7410];
% orange = [ 0.91,0.41,0.17];
% gray = [211,211,211]/255;
% color = [55,126,184]/255;
% light_red =  [255,204,204]/255;
% light_red2 =  [255,153,153]/255;
% black = [0,0,0];
% s=1;
% for k=1:2
%     static=statics(k);
% for i= 1:2
%     D = Dlist(i);
%     load(['rl_ori' int2str(static) '_' int2str(D) '_' int2str(100) '.mat'])
%     rl_ori=nondominate(rl_ori);
%     PF = [max(rl_ori(:,1))*1.2, max(rl_ori(:,2))*1.2];
%     HVs(7,s) = HV(rl_ori,PF);
%     
%     for j = 1:3
%         ls_count = ls_list(j);
%         load(['ls' int2str(static) '_' int2str(D) '_' int2str(ls_count) '.mat'])
%         load(['rl_ls' int2str(static) '_' int2str(D) '_' int2str(ls_count) '.mat'])
%         ls=nondominate(ls);
%         rl_ls=nondominate(rl_ls);
%         
%         HVs(j,s) = HV(ls,PF);
%         HVs(j+3,s) = HV(rl_ls,PF);
%         
%         
%         v=[HV(ls,PF);HV(rl_ori,PF);HV(rl_ls,PF)];
%         eval(['hvs.city' int2str(D) '_' int2str(ls_count) '= v;'])
% %         figure
% %         plot(ls(:,1),ls(:,2),'r.', 'Marker'          , 'o'  , ...
% %   'MarkerSize'      , 3           , ...
% %   'MarkerEdgeColor' , 'blue'      , ...
% %   'MarkerFaceColor' , 'blue');
% %         hold on
% %         plot(rl_ori(:,1),rl_ori(:,2),'r.', 'Marker'          , 'o'  , ...
% %   'MarkerSize'      , 4           , ...
% %   'MarkerEdgeColor' , orange      , ...
% %   'MarkerFaceColor' , light_red);
% %         hold on
% %         plot(rl_ls(:,1),rl_ls(:,2),'r.', 'Marker'          , 'o'  , ...
% %   'MarkerSize'      , 4           , ...
% %   'MarkerEdgeColor' , black      , ...
% %   'MarkerFaceColor' , gray);
% %         hold off
% %         legend('LS','RL','RL+LS')
% %         title([int2str(D) ' city ' int2str(ls_count)])
% %         
% %         xlabel('\itf\rm_1'); ylabel('\itf\rm_2');
% %         set(gca,'FontSize',12.5);
% %         set(get(gca,'XLabel'),'FontSize',14)
% %         set(get(gca,'YLabel'),'FontSize',14) 
%     end 
%     s=s+1;
% end
% 
% end
%         

