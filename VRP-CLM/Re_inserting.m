
%% 将被移出的顾客重新插回所得到的新的车辆顾客分配方案
%%输入removed                         被移出的顾客集合
%输入rfvc                             移出removed中的顾客后的final_vehicles_customer
%输入L                                集配中心时间窗
%输入a                                顾客时间窗
%输入b                                顾客时间窗
%输入s                                服务每个顾客的时间
%输入dist                             距离矩阵
%输入demands                          需求量
%输入cap                              最大载重量
%输出ReIfvc                           将被移出的顾客重新插回所得到的新的车辆顾客分配方案
%输出RTD                              新分配方案的总距离
function [ ReIfvc,RTD ] = Re_inserting(removed,rfvc,L,a,b,s,dist,demands,cap,speed)  %返回重新插入顾客后的路径 ReIfvc 和更新后的总行驶距离 RTD
while ~isempty(removed)    %当 removed 列表中还有元素时，继续执行循环
    %% 最远插入启发式：将最小插入目标距离增量最大的元素找出来
    [fv,fviv,fvip,fvC]=farthestINS(removed,rfvc,L,a,b,s,dist,demands,cap,speed );%这个启发式基于最小化插入操作对当前路径的影响，找到被移除的顾客 fv、插入点的索引 fviv、插入点 fvip 和考虑插入的车辆 fvC
    removed(removed==fv)=[];  %删除 removed 列表中找到的顾客 fv
    %% 根据插入点将元素插回到原始解中
    [rfvc,iTD]=insert(fv,fviv,fvip,fvC,rfvc,dist); %调用 insert 函数将顾客 fv 插入到路径 fvC 的 fviv 位置，并更新路径 rfvc 和总行驶距离 iTD
end
[ rfvc,~ ] = deal_vehicles_customer( rfvc );  %调用 deal_vehicles_customer 函数移除任何空的车辆路径，确保所有路径都是有效的
ReIfvc=rfvc;                                  %将更新后的车辆路径 rfvc 赋值给 ReIfvc
[ RTD,~ ] = travel_distance( ReIfvc,dist );   %调用 travel_distance 函数计算 ReIfvc 的总行驶距离 RTD
end

