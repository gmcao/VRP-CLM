
%% 计算每辆车离开当前路径上集配中心时的载货量、每辆车离开当前路径上每一点时的载货量
%输入vehicles_customer            每辆车所经过的顾客
%输入d1                           表示由集配中心运送到顾客的配送量
%输出vd                           每辆车离开集配中心的装货量
%输出vw                           每辆车离开加工车间的装货量
%输出vl                           每辆车离开当前路径上集配中心时的载货量、每辆车离开当前路径上每一点时的载货量
function [vl]= vehicle_load( vehicles_customer,demands,customer_type) %用于计算车辆路径问题（VRP）中每辆车在离开集配中心时的初始载货量。这个函数帮助确保车辆在开始配送前不会超载，并且可以用于后续的路径评估和改进。
n=size(vehicles_customer,1);                    %车辆总数
vl=zeros(n,1);                                  %创建一个长度为 n 的零向量 vl，用于存储每辆车离开集配中心时的载货量
%% 先计算出每辆车在集配中心初始的装货总量
for i=1:n
    route=vehicles_customer{i};         %获取第 i 辆车的配送路线
    if isempty(route)                   %检查路线 route 是否为空。如果为空，表示没有顾客分配给这辆车，其载货量为 0
        vl(i)=0;
    else
        Ld= leave_load( route,demands );%调用 leave_load 函数计算车辆在给定路线上除了配送中心之外的最后一个顾客或加工车间的剩余载货量 Ld
        vl(i)=Ld;                       %将计算得到的载货量 Ld 赋值给 vl 中对应车辆的索引位置 i
    end
end
end