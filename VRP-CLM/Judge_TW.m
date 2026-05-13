
%% 判断是否违背时间窗约束，0代表不违背，1代表违背
%输入vehicles_customer：       每辆车所经过的顾客
%输入bsv：                     每辆车配送路线上在各个点开始服务的时间，还计算返回集配中心时间
%输入b：                       顾客时间窗结束时间[a[i],b[i]]
%输入L：                       集配中心时间窗结束时间
%输出violate_TW：              否违背时间窗约束的元胞数组
%输出total_time                每条线路运行时间
%输出：violating_points    违反时间窗的配送点（配送中心）
function [ violate_TW,total_time, violating_points] = Judge_TW( vehicles_customer,bsv,b,L,customer_type,speed ) %函数返回 violate_TW，一个记录了每辆车的路线上每个点是否违反了时间窗约束的矩阵
NV=size(vehicles_customer,1);               %所用车辆数量
%violate_TW=cell(NV,1);
total_time = zeros(NV, 1); % 初始化总运行时间数组
violate_TW=bsv;                            %将 bsv（每辆车的开始服务时间数组）赋值给 violate_TW
violating_points = cell(NV, 1); % 初始化违反时间窗的配送点数组
for i=1:NV
    route=vehicles_customer{i};            %获取第 i 辆车的路线
    bs=bsv{i};                             %获取第 i 辆车的开始服务时间数组
    l_bs=length(bsv{i});
    % 初始化 violate_TW 的第 i 行
     violate_TW{i} = zeros(1, l_bs);
     violating_points{i} = []; % 初始化当前车辆的违反时间窗的配送点列表
    %% 遍历路线上的顾客
    for j=1:l_bs-1                         %循环遍历路线上除了最后一个点之外的每个顾客
        if bs(j)<=b(route(j))              %检查车辆在顾客的时间窗结束时间 b 之前到达
            violate_TW{i}(j)=0;            %如果没有违反时间窗，将对应位置的 violate_TW 设置为 0
        else
            violate_TW{i}(j)=1;            %将对应位置的 violate_TW 设置为 1，表示违反了时间窗
            violating_points{i} = [violating_points{i}, route(j)]; % 记录违反时间窗的配送点
        end
    end
    %% 检查最后一个顾客或配送中心的时间窗
    if bs(end)<=L                          %检查车辆在配送中心的时间窗 L 之前返回
        violate_TW{i}(end)=0;              %如果没有违反配送中心的时间窗，将对应位置的 violate_TW 设置为 0
    else
        violate_TW{i}(end)=1;              %将对应位置的 violate_TW 设置为 1，表示违反了配送中心的时间窗
        violating_points{i} = [violating_points{i}, 'Depot']; % 记录违反时间窗的配送中心
    end
     % 计算总运行时间
        total_time(i) = bs(end) - bs(1); 
        end

end

