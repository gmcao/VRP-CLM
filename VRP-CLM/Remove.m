
%% Remove操作，先从原有顾客集合中随机选出一个顾客，然后根据相关性再依次移出需要数量的顾客
%输入cusnum               顾客数量
%输入toRemove             将要移出顾客的数量
%输入D                    随机元素
%输入dist                 距离矩阵
%final_vehicles_customer  每辆车所经过的顾客（VC）
%removed                  被移出的顾客集合
%rfvc                     移出removed中的顾客后的final_vehicles_customer
function [removed,rfvc] = Remove(cusnum,toRemove,D,dist,final_vehicles_customer)
%% Remove初始化移除的顾客集合
inplan=1:cusnum;            %创建一个包含所有顾客编号的集合 inplan
visit=ceil(rand*cusnum);    %随机选择一个顾客编号 visit 作为第一个被移除的顾客;ceil函数可以对一个矩阵中的每个元素进行向上取整操作
inplan(inplan==visit)=[];   %使用前面创建的空数组替换 inplan 中所有等于 visit 的元素，实际上是从 inplan 向量中移除了这些元素
removed=[visit];            %初始化被移除的顾客集合 removed，将 visit 添加到 removed 中
%% 移除顾客的循环
while length(removed)<toRemove      %当被移除的顾客数量少于 toRemove 时，继续循环
    nr=length(removed);             %当前被移出的顾客数量nr；lengthlength函数返回的是数组中元素的总数，而不是数组的维度
    vr=ceil(rand*nr);               %从removed集合中随机选择一个顾客vr
    nip=length(inplan);             %原来顾客集合中顾客的数量
    R=zeros(1,nip);                 %存储removed(vr)与inplan中每个元素的相关性的数组
    for i=1:nip                     %循环计算 vr 与 inplan 中每个顾客的相关性，并按相关性降序排序
        R(i)=Relatedness( removed(vr),inplan(i),dist,final_vehicles_customer);   %计算removed(vr)与inplan中每个元素的相关性
    end
    [SRV,SRI]=sort(R,'descend');    %降序排序    
    lst=inplan(SRI);                %将inplan中的数组按removed(vr)与其的相关性从高到低排序
    vc=lst(ceil(rand^D*nip));       %从排序后的顾客列表 lst 中随机选择一个顾客 vc 作为下一个被移除的顾客
    removed=[removed vc];           %将 vc 添加到被移除的顾客集合 removed 中
    inplan(inplan==vc)=[];          %从原有顾客集合 inplan 中移除 vc
end
%% 更新车辆路径方案,负责初始化更新后的车辆路径方案，并准备移除指定的顾客
rfvc=final_vehicles_customer;               %将原始的车辆路径方案 final_vehicles_customer 赋值给 rfvc
nre=length(removed);                        %计算向量 removed 中元素的数量，即要移除的顾客数量 nre
NV=size(final_vehicles_customer,1);         %使用 size 函数获取 final_vehicles_customer 矩阵的行数，即车辆的总数 NV。这个值同样用于后续的循环中，以便遍历每辆车的路径。
%% 处理空路径
for i=1:NV
    route=final_vehicles_customer{i};              %从原始车辆路径方案 final_vehicles_customer 中获取第 i 辆车的路径
    for j=1:nre                                    %循环遍历所有要移除的顾客，nre 是要移除的顾客数量
        findri=find(route==removed(j),1,'first');  %使用 find 函数查找路径 route 中第一个匹配 removed(j)（要移除的顾客编号）的位置 findri
        if ~isempty(findri)                        %检查是否找到了要移除的顾客
            route(route==removed(j))=[];           %如果找到了要移除的顾客，使用条件索引从路径 route 中移除该顾客编号
        end
    end
    %更新车辆路径方案
    rfvc{i}=route;                                %将更新后的路径 route 赋值给更新后的车辆路径方案 rfvc 中对应的车辆
end
 % 处理空路径
[ rfvc,~ ] = deal_vehicles_customer( rfvc );      %调用 deal_vehicles_customer 函数移除任何空的车辆路径，确保所有路径都是有效的

end

%% 这段代码确保了每辆车的路径都根据 removed 向量中的顾客编号进行了更新。移除顾客后，任何不再服务于这些顾客的车辆路径都会被清理，从而确保解决方案的可行性和有效性。这是车辆路径问题（VRP）中常见的操作，特别是在进行局部搜索和路径优化时，通过这种方式可以探索不同的路径配置，寻找更优的解决方案。在遗传算法中，这种路径调整有助于改进当前解，减少总行驶距离或改善其他目标函数指标。通过这种方式，算法能够在迭代过程中逐步提高解的质量，最终找到满足问题约束的最优解或近似最优解。
