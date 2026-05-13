%% 这段代码是 init3 函数的实现，它用于生成车辆路径问题的初始解。这个函数采用了一种基于时间成本的最近邻策略（Nearest Neighbor Clustering, NNC），并考虑了时间窗约束
%输入：t1, t2, t3 时间成本参数，用于计算时间相关的成本
%输入：a、b、s    开始、结束时间与服务时间
%输入：dist       距离矩阵
%输入：cap        载重量
%输入：demands    配送点需求量 
%输入：
%输出：init_vc     初始化的车辆路径集合
function init_vc = init3(t1, t2, t3, a, b, s, dist, cap, demands,speed)
init_vc = cell(1, 1);  % 初始化为单元数组
NV = 1;                % 车辆数量
i = 1;                 % 顾客索引
remain = (1:1:size(a, 1));  %存储所有未访问的顾客的索引
[~, plot, time, ind] = deal0(t1, t2, t3, a, b, dist, remain,speed); %调用 deal0 函数选择第一个顾客作为起点，并计算时间成本
%plot是选中的顾客索引，time 是到达该顾客的时间，ind 是选中的顾客在 remain 中的位置
route = plot; 
remain(ind) = [];
load = demands(plot);
%循环直到所有顾客都被访问
%调用 deal1 函数选择下一个顾客，考虑时间成本和车辆容量限制。
%如果加入新顾客后不超过车辆容量，将其添加到当前路径。
%如果超过容量，将当前路径存入 init_vc 并开始新的路径。
%load 跟踪当前路径的总需求量。
while i < size(a, 1)  
    [~, plot, time, ind] = deal1(t1, t2, t3, a, b, s, dist, remain, route, time,speed);%调用 deal1 函数选择下一个顾客，考虑时间成本和车辆容量限制
    if load + demands(plot) < cap
        load = load + demands(plot);
        remain(ind) = [];
        route = [route, plot];
        i = i + 1;
        if i == size(a, 1)
            init_vc{NV, 1} = route;
        end
    else
        init_vc{NV, 1} = route;
        NV = NV + 1;
        [~, plot, time, ind] = deal0(t1, t2, t3, a, b, dist, remain,speed);
        route = plot;
        remain(ind) = [];
        load = demands(plot);
        i = i + 1;
    end
end
 
%%  这个函数通过迭代的方式构建初始的车辆路径，每次迭代选择下一个时间成本最低且符合时间窗和容量限制的顾客，直到所有顾客都被访问。最终，init_vc 包含了每个车辆的路径，这些路径可以作为遗传算法的初始种群。
    