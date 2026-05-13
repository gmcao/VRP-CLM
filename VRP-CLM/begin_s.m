function [bs, back] = begin_s(route, a, s, dist, speed)
%% 计算一条路线上车辆对顾客的开始服务时间，以及车辆返回集配中心的时间
% 输入 route：一条配送路线
% 输入 a：    最早开始服务的时间窗
% 输入 s：    对每个点的服务时间
% 输入 dist： 距离矩阵
% 输入 speed：行驶速度
% 输出 bs：   车辆对顾客的开始服务时间
% 输出 back： 车辆返回集配中心的时间

n = length(route);

% 空路线处理
if n == 0
    bs = [];
    back = 0;
    return;
end

bs = zeros(1, n);

% 计算第一个顾客的开始服务时间
travel_time_to_first = dist(1, route(1) + 1) / speed;
bs(1) = max(a(route(1)), travel_time_to_first);

% 计算每个后续顾客的开始服务时间
for i = 2:n
    travel_time = dist(route(i - 1) + 1, route(i) + 1) / speed;
    bs(i) = max(a(route(i)), bs(i - 1) + s(route(i - 1)) + travel_time);
end

% 计算返回集配中心的时间（只算一次，放在循环外面）
back = bs(n) + s(route(end)) + dist(route(end) + 1, 1) / speed;

end