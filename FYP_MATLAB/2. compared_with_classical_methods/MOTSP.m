function varargout = MOTSP(Operation,Global,input)
% <problem> <Combinatorial MOP>
% Multi-objective traveling salesman problem
% c ---  0 --- Correlation parameter
% operator --- EApermutation

%--------------------------------------------------------------------------
% The copyright of the PlatEMO belongs to the BIMK Group. You are free to
% use the PlatEMO for research purposes. All publications which use this
% platform or any code in the platform should acknowledge the use of
% "PlatEMO" and reference "Ye Tian, Ran Cheng, Xingyi Zhang, and Yaochu
% Jin, PlatEMO: A MATLAB Platform for Evolutionary Multi-Objective
% Optimization, 2016".
%--------------------------------------------------------------------------

% Copyright (c) 2016-2017 BIMK Group

persistent C;
global obj1;
global obj2;
global obj3;
global obj4;
global obj5;
    c = Global.ParameterSet(0);
    switch Operation
        case 'init'
            Global.D        = 40;
            Global.operator = @EApermutation;
            
%             C = cell(1,Global.M);
%             C{1} = rand(Global.D);
%             for i = 2 : Global.M
%                 C{i} = c*C{i-1} + (1-c)*rand(Global.D);
%             end
%             for i = 1 : Global.M
%                 C{i} = tril(C{i},-1) + triu(C{i}',1);
%             end
%             C = Global.ParameterFile(sprintf('MOTSP-M%d-D%d-c%.4f',Global.M,Global.D,c),C);
            C = cell(1,Global.M);
            if Global.M==2
                C{1} = obj1;
                C{2} = obj2;
            elseif Global.M==3
                C{1} = obj1;
                C{2} = obj2;
                C{3} = obj3;
            elseif Global.M==5
                C{1} = obj1;
                C{2} = obj2;
                C{3} = obj3;
                C{4} = obj4;
                C{5} = obj5;
            end
            
            [~,PopDec] = sort(rand(input,Global.D),2);
            varargout  = {PopDec};
        case 'value'
            PopDec = input;
            [N,D]  = size(PopDec);
            M      = Global.M;
            
            PopObj = zeros(N,M);
            for i = 1 : M
                for j = 1 : N
                    for k = 1 : D-1
                        PopObj(j,i) = PopObj(j,i) + C{i}(PopDec(j,k),PopDec(j,k+1));
                    end
                    PopObj(j,i) = PopObj(j,i) + C{i}(PopDec(j,D),PopDec(j,1));
                end
            end
            
            PopCon = [];
            
            varargout = {input,PopObj,PopCon};
        case 'PF'
            RefPoint  = zeros(1,Global.M) + Global.D;
            varargout = {RefPoint};
    end
end