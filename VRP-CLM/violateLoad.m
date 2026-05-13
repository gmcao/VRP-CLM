
% violateLoad 函数是评估车辆路径问题解决方案质量的重要部分。通过计算超载的需求量，可以对解决方案进行惩罚，从而在遗传算法的目标函数中给予这些解决方案较低的适应度值。这样，算法在迭代过程中将倾向于选择那些满足载重约束的解决方案，逐步找到满足所有约束条件的最优解或近似最优解。
%这个函数是车辆路径问题（VRP）中的一部分，用于确保解决方案满足车辆的载重约束
%% 计算当前解违反的容量约束
%输入curr_vc                  当前车辆路径(当前解）
%输入demands                  各个顾客需求量
%输入cap                      车辆最大载货量
%输出q                        各个路径违反载货量之和
function [q]=violateLoad(curr_vc,demands,cap)
NV=size(curr_vc,1);                     %获取 curr_vc 矩阵的行数 NV，这里 NV 代表所用车辆的数量
q=0;
for i=1:NV
    route=curr_vc{i};                   %获取第 i 辆车的路线
    Ld=leave_load(route,demands);       %调用 leave_load 函数计算车辆在给定路线上剩余的载重 Ld。这个函数接受车辆的路线和顾客需求量作为输入，并返回车辆在完成该路线后剩余的载重。
    if Ld>cap                           %如果剩余载重 Ld 大于车辆的载重限制 cap，则存在超载情况
        q=q+Ld-cap;                     %将超载的需求量加到 q 上
    end
end
end

