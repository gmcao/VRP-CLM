
%% 判断当前方案是否满足时间窗约束和载重量约束，0表示违反约束，1表示满足全部约束
%输入：chrom               个体
%输入：cap                 最大载重量
%输入：demands             需求量
%输入：a                   顾客时间窗开始时间[a[i],b[i]]
%输入：b                   顾客时间窗结束时间[a[i],b[i]]
%输入：L                   配送中心时间窗结束时间
%输入：s                   客户点的服务时间
%输入：customer_type       顾客类型
%输入：dist                距离矩阵，满足三角关系，暂用距离表示花费c[i][j]=dist[i][j]
%输出：flag                0表示违反约束，1表示满足全部约束
%输出：init_v              每辆车的装载量
%输出：init_v_rate         每辆车的装载率
%输出：violate_INTW        否违背时间窗约束的元胞数组
%输出：total_time          每条线路运行时间
%输出：violating_points    违反时间窗的配送点（配送中心）
%输出：bsv                 每辆车配送总时间
function [flag,init_v,init_v_rate,violate_INTW]=Judge(VC,cap,demands,a,b,L,s,dist,speed)
flag=1;                         %假设满足约束
NV=size(VC,1);                  %车辆使用数目
%% 计算每辆车的装载量
init_v=vehicle_load(VC,demands);
init_v_rate=init_v/cap;
%% 计算每辆车配送路线上在各个点开始服务的时间，还计算返回集配中心时间
bsv=begin_s_v(VC,a,s,dist,speed);
%% 判断是否违背时间窗约束，0代表不违背，1代表违背;返回单条路径运行时间
 [violate_INTW, violating_points]  =Judge_TW(VC,bsv,b,L);
%% 遍历每条路径，一旦有一条路径不满足约束，flag=0
for i=1:NV
    find1=find(violate_INTW{i}==1,1,'first');      %对于每条路径 i，使用 find 函数在 violate_INTW{i} 中搜索第一个违反时间窗约束的顾客的位置。violate_INTW{i} 可能是一个逻辑数组，其中 1 表示违反时间窗约束的顾客，0 表示满足时间窗约束的顾客。'first' 选项确保只找到第一个匹配项的位置。
    if init_v(i)>cap || ~isempty(find1)            %“||”为逻辑或，~isempty(find1)：检查是否找到了违反时间窗约束的顾客（即 find1 不是空数组）
        flag=0;                                    %如果发现违反约束的情况，将 flag 设置为 0，表示当前路径不满足约束条件
        break
    end
end
end

