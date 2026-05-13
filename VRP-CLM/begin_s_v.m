
%% 计算每辆车配送路线上在各个点开始服务的时间，还计算返回集配中心时间
%输入vehicles_customer：       每辆车所经过的顾客（车辆-顾客矩阵）
%输入a：                       最早开始服务的时间窗
%输入s：                       对每个点的服务时间
%输入dist：                    距离矩阵
%输出bsv：                     每辆车配送路线上在各个点开始服务的时间，还计算返回集配中心时间
%输出total_runtime：           每辆车配送总时间

function [bsv,total_runtime]= begin_s_v( vehicles_customer,a,s,dist,speed )
n=size(vehicles_customer,1);   %获取 vehicles_customer 矩阵的行数 n，代表车辆的数量
bsv=cell(n,1);                 %创建一个单元数组 bsv（n×1），用于存储每辆车的开始服务时间和返回配送中心的时间
total_runtime = zeros(n, 1);      % 初始化一个数组来存储每辆车的总运行时间
for i=1:n
    route=vehicles_customer{i};             %获取第 i 辆车的路线
    [bs,back]= begin_s( route,a,s,dist ,speed);   %调用 begin_s 函数计算车辆的配送路线 route 上各个点的开始服务时间和返回配送中心的时间
    bsv{i}=[bs,back];                       %将计算得到的开始服务时间和返回时间存储到 bsv 的第 i 个单元中

     % 计算并存储每辆车的总运行时间
        if isempty(bs) || numel(bs) == 0
            total_runtime(i) = back;  % 如果路线为空，总运行时间即为返回时间
        else
            total_runtime(i) = back - max(bs(1), 0);  % 总运行时间 = 返回时间 - 出发时间
end
end

%函数返回 bsv，一个包含了每辆车的开始服务时间和返回配送中心时间的单元数组