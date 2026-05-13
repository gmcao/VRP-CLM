%% 计算当前解的成本函数
%输入curr_vc                  每辆车所经过的顾客
%输入a,b                      顾客时间窗结束时间[a[i],b[i]]
%输入s                        对每个顾客的服务时间
%输入L                        仓库时间窗结束时间
%输入：w                      所有顾客解违反的时间窗约束之和
%输入dist                     距离矩阵
%输入demands                  各个顾客需求量
%输入cap                      车辆最大载货量
%输出cost                      成本函数 f=TD+alpha*q+belta*w

function [Tcost,bsv,total_runtime,w,violating_points,violation_durations]=costFuction(curr_vc,a,b,s,L,dist,demands,cap,alpha,X1,X2,speed)  %它接受当前车辆路径 curr_vc 和车辆路径问题（VRP）的相关参数作为输入，并返回成本值 cost
NV = size(curr_vc,1);
[TD] = travel_distance(curr_vc,dist);  %调用 travel_distance 函数计算当前路径 curr_vc 的总行驶距离 TD
[q]=violateLoad(curr_vc,demands,cap);  %调用 violateLoad 函数计算当前路径 curr_vc 中超出车辆载重限制的需求量 q。
[bsv,total_runtime,w,violating_points,violation_durations]=violateTW(curr_vc,a,b,s,L,dist,speed);   %调用 violateTW 函数计算当前路径 curr_vc 中违反时间窗约束的顾客数量 w
[Tcost]=X1*NV+X2*TD+alpha*q+w;      %根据行驶距离 TD、超载量 q 和违反时间窗约束的数量 w 计算总成本 cost。
end 

