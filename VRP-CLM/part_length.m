
%% 计算一个子回路的路径长度
%% 这个函数在车辆路径问题（VRP）中非常重要，因为它帮助评估解决方案的成本，通常用于遗传算法的目标函数中，以最小化总行驶距离。
function p_l= part_length(route,dist)  %route 是一个包含顾客访问顺序的向量
n=length(route);                       %获取路线中顾客的数量
p_l=0;                                 %初始化总行驶距离 p_l 为 0
if n~=0                                %如果 n 不等于 0，表示路线中有至少一个顾客，可以计算行驶距离
    for i=1:n
        if i==1                        %对于路线中的第一个顾客，计算从起点（1）到第一个顾客的距离，并将其累加到 p_l
            p_l=p_l+dist(1,route(i)+1);
        else                           %对于路线中的其他顾客，计算相邻两个顾客之间的距离，并将其累加到 p_l 
            p_l=p_l+dist(route(i-1)+1,route(i)+1); %使用距离矩阵 dist 计算从顾客 route(i-1) 到顾客 route(i) 的距离，并将其累加到 p_l
        end
    end
    p_l=p_l+dist(route(end)+1,1);   %计算从最后一个顾客返回到起点（1）的距离，并将其累加到 p_l
end
end

