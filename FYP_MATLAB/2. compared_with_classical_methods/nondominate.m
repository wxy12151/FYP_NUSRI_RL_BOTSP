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