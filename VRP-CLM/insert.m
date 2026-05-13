
%% 根据插入点将元素插回到原始解中
%输入fv               插回元素（顾客编号 fv）
%输入fviv             将插回元素插回的车辆序号（插入点的索引 fviv）
%输入fvip             将插回元素插回车辆序号中插入点的位置（插入点 fvip）
%输入rfvc             移出removed中的顾客后的final_vehicles_customer（当前的车辆路径矩阵 rfvc）
%输入fvC              考虑插入的车辆编号 fvC
%输入dist             距离矩阵
%输出ifvc             车辆路径矩阵 ifvc 
%iTD                  插回元素后的rfvc的总距离
%定义了 insert 函数，它接受顾客编号 fv、插入点的索引 fviv、插入点 fvip、考虑插入的车辆编号 fvC、当前的车辆路径矩阵 rfvc 和顾客之间的距离矩阵 dist 作为输入参数，并返回更新后的车辆路径矩阵 ifvc 和更新后的总行驶距离 iTD。
function [ifvc,iTD]=insert(fv,fviv,fvip,fvC,rfvc,dist)
ifvc=rfvc;                                      %创建 rfvc 的副本，用于存储更新后的车辆路径
[ sumTD,~ ] = travel_distance( rfvc,dist );     %插回前的总距离
iTD=sumTD+fvC;                                  %插回后的总距离
%% 如果插回车辆属于rfvc中的车辆
if fviv<=size(rfvc,1)   %如果 fviv 小于或等于 rfvc 的长度，表示插入点属于 rfvc 中的一个现有车辆路径
    route=rfvc{fviv};   %将元素插回的路径(获取第 fviv 辆车的当前路径)
    len=length(route);  %获取路径中顾客的数量
    %根据 fvip 的值确定顾客 fv 的插入位置，并更新路径
    if fvip==1          %检查 fvip 的值。如果 fvip 等于 1，表示顾客 fv 需要插入到路径的开始位置
        temp=[fv route]; %创建一个新的路线，将顾客 fv 作为第一个元素，后面跟着原始的 route
    elseif fvip==len+1  %检查 fvip 是否等于 len+1。如果 fvip 等于 len+1，表示顾客 fv 需要插入到路径的结束位置
        temp=[route fv]; %创建一个新的路线，保持原始的 route 不变，将顾客 fv 作为最后一个元素。
    else                 %如果 fvip 不是 1 也不是 len+1，表示顾客 fv 需要插入到路径的中间某个位置
        temp=[route(1:fvip-1) fv route(fvip:end)]; %创建一个新的路线，将原始路径分为两部分，顾客 fv 插入到第一部分的末尾和第二部分的开头
    end
    ifvc{fviv}=temp;   %将更新后的路径赋值回 ifvc 中对应的车辆
%否则，新增加一辆车
else 
    ifvc{fviv,1}=[fv];  %在 ifvc 中为新的车辆创建一个新的路径，只包含顾客 fv
end
end

%insert 函数是车辆路径问题中路径调整的关键部分。通过将顾客插入到最合适的位置，可以改进路径的效率，减少总行驶距离，同时满足顾客的需求和车辆的载重限制。在遗传算法的局部搜索阶段，这种路径调整有助于探索解空间，并可能找到更优的解决方案。通过这种方式，算法能够在迭代过程中逐步提高解的质量，最终找到满足问题约束的最优解或近似最优解。