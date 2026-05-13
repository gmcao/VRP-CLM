%% 最远插入启发式：将最小插入目标距离增量最大的元素找出来
%输入removed                          被移出的顾客集合
%输入rfvc                             当前的车辆路径方案，移出removed中的顾客后的final_vehicles_customer
%输入L                                集配中心时间窗
%输入a                                顾客时间窗
%输入b                                顾客时间窗
%输入s                                服务每个顾客的时间
%输入dist                             距离矩阵
%输入demands                          需求量
%输入cap                              最大载重量
%输出fv                               将removed中所有元素 最佳插入后距离增量最大的元素
%输出fviv                             该元素所插入的车辆
%输出fvip                             该元素所插入的车辆的坐标
%输出fvC                              该元素插入最佳位置后的距离增量
function [fv,fviv,fvip,fvC]=farthestINS(removed,rfvc,L,a,b,s,dist,demands,cap,speed )
%% 初始化结果矩阵
nr=length(removed);                   %被移出的顾客的数量
outcome=zeros(nr,3);                  %创建一个大小为 nr（被移除顾客的数量）乘以 3 的零矩阵
for i=1:nr                            %循环遍历所有的被移除顾客
    %[车辆序号 插入点序号 距离增量]
    [civ,cip,C]= cheapestIP( removed(i),rfvc,L,a,b,s,dist,demands,cap,speed);  %调用 cheapestIP 函数执行最便宜插入启发式，找到顾客 removed(i) 应该插入的最佳车辆序号 civ、插入点序号 cip 和距离增量 C
    outcome(i,1)=civ;
    outcome(i,2)=cip;
    outcome(i,3)=C;
end
[mc,mc_index]=max(outcome(:,3)); %使用 max 函数找出 outcome 矩阵第三列（距离增量）中的最大值 mc 及其索引 mc_index
temp=outcome(mc_index,:);        %获取与最大距离增量 mc 对应的最佳插入信息 temp
fviv=temp(1,1);                  %提取最佳车辆序号 fviv
fvip=temp(1,2);                  %提取最佳插入点序号 fvip
fvC=temp(1,3);                   %提取考虑插入的车辆编号 fvC
fv=removed(mc_index);            %提取最佳插入的顾客编号 fv

end

