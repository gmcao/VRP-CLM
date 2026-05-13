
%% 解码
%输入：chrom               个体
%输入：cusnum              顾客数目
%输入：cap                 最大载重量
%输入：demands             需求量
%输入：a                   顾客时间窗开始时间[a[i],b[i]]
%输入：b                   顾客时间窗结束时间[a[i],b[i]]
%输入：L                   配送中心时间窗结束时间
%输入：s                   客户点的服务时间
%输入：customer_type       顾客类型
%输入：dist                距离矩阵，满足三角关系，暂用距离表示花费c[i][j]=dist[i][j]
%输出：VC                  每辆车所经过的顾客，是一个cell数组
%输出：NV                  车辆使用数目
%输出：TD                  车辆行驶总距离
%输出：everyTD             每辆车所行驶的距离
%输出：violate_num         违反约束路径数目
%输出：violate_cus         违反约束顾客数目
%输出：init_v              每辆车的装载量
%输出：init_v_rate         每辆车的装载率
%输出：violate_INTW        否违背时间窗约束的元胞数组
%输出：total_time          每条线路运行时间
%输出：violating_points    违反时间窗的配送点（配送中心）
%输出：Tcost               配送总成本
%输出：violation_durations 每辆车在在其路线上的每个违背时间窗的配送点的违背时长。某辆车在第 57、58 和 61号顾客处违背了时间窗，且违背的时长分别是 10、15 和 20 分钟，[10 15 20]
function [VC,NV,TD,everyTD,Tcost,total_runtime,w,violate_num,violate_cus,violating_points,violation_durations]=decode(chrom,cusnum,cap,demands,a,b,L,s,dist,alpha,X1,X2,speed)
violate_num=0;                                      %违反约束路径数目
violate_cus=0;                                      %违反约束顾客数目
VC=cell(cusnum,1);                                  %初始化一个单元数组 VC，用于存储每辆车所经过的顾客路径
count=1;                                            %车辆计数器，表示当前车辆使用数目
location0=find(chrom>cusnum);                       %找出个体中配送中心的位置
for i=1:length(location0)                           %length 函数用于获取数组或字符串的长度
    if i==1                                         %对于第一个配送中心（i==1）
        route=chrom(1:location0(i));                %提取两个配送中心之间的路径
        route(route==chrom(location0(i)))=[];       %从 route 中删除配送中心的位置，因为配送中心不是配送路线的一部分。
    else
        route=chrom(location0(i-1):location0(i));   %提取从前一个配送中心到当前配送中心之间的染色体序列，这代表了车辆的配送路线
        route(route==chrom(location0(i-1)))=[];     %从 route 中删除前一个配送中心的位置
        route(route==chrom(location0(i)))=[];       %从 route 中删除当前配送中心的位置
    end
    VC{count}=route;                                %更新配送方案
    count=count+1;                                  %车辆使用数目
end
route=chrom(location0(end):end);                    %提取染色体中从最后一个配送中心位置 location0(end) 到最后一个元素的部分，这部分代表最后一条配送路线。这是染色体中的最后一段，可能包含一个或多个顾客的索引       
route(route==chrom(location0(end)))=[];             %删除路径中配送中心序号
VC{count}=route;                                    %将解码后的路线 route 存储到 VC 单元数组中
[VC,NV]=deal_vehicles_customer(VC);                 %将VC中空的数组移除
% VC(cellfun(@isempty,VC))=[];                       %可以用Matleb以下自带的函数替代[VC,NV]=deal_vehicles_customer(VC);
% NV=length(VC);
for j=1:NV
    route=cell(1,1);                                %开辟临时元胞数组变量route，用于存储当前车辆的路径preroute
    route{1}=VC{j};                                 %将 VC 中第 j 辆车的路径赋值给 route 的第一个元素
    [flag,init_v,init_v_rate,violate_INTW]=Judge(route,cap,demands,a,b,L,s,dist,speed);     %判断当前方案是否满足时间窗约束和载重量约束，0表示违反约束，1表示满足全部约束
    if flag==0
        violate_cus=violate_cus+length(route{1});   %如果这条路径不满足约束，则违反约束顾客数目加该条路径顾客数目；length(route{1}) 用于计算当前路径中的顾客数量
        violate_num=violate_num+1;                  %如果这条路径不满足约束，则违反约束路径数目加1
    end
end
[TD,everyTD]=travel_distance(VC,dist);                        %该方案车辆行驶总距离
[Tcost,bsv,total_runtime,w,violating_points,violation_durations]=costFuction(VC,a,b,s,L,dist,demands,cap,alpha,X1,X2,speed);


end
