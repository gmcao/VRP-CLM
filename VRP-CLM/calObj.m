%% 计算种群的目标函数值
%输入：Chrom               种群
%输入：X1=100              调车费用
%输入：cusnum              顾客数目
%输入：cap                 最大载重量
%输入：demands             需求量
%输入：a                   顾客时间窗开始时间[a[i],b[i]]
%输入：b                   顾客时间窗结束时间[a[i],b[i]]
%输入：L                   配送中心时间窗结束时间
%输入：s                   客户点的服务时间
%输入：dist                距离矩阵，满足三角关系，暂用距离表示花费c[i][j]=dist[i][j]
%输入：VC                  每辆车所经过的顾客，是一个cell数组
%输入：NV                  车辆使用数目
%输入：violate_num         违反约束路径数目
%输入：violate_cus         违反约束顾客数目
%输入：violate_cus         违反约束顾客数目
%输入：violating_points    违反时间窗的配送点（配送中心）
%输入：violation_durations 每辆车在其路线上的每个违背时间窗的配送点的违背时长
%输出：ObjV                每个个体的目标函数值，定义为车辆使用数目*10000+车辆行驶总距离
function ObjV=calObj(Chrom,cusnum,cap,demands,a,b,L,s,dist,alpha,X1,X2,speed)
% route=1:cusnum;
% G= part_length(route,dist);               %G为对每条不可行路径的惩罚权重
NIND=size(Chrom,1);                         %种群数目
ObjV=zeros(NIND,1);                         %储存每个个体函数值
%G=10;                                       %G为对每条不可行路径的惩罚权重
for i=1:NIND
    [VC,NV,TD,everyTD,Tcost,total_runtime,w,violate_num,violate_cus,violating_points,violation_durations]=decode(Chrom(i,:),cusnum,cap,demands,a,b,L,s,dist,alpha,X1,X2,speed); %调用 decode 函数将个体的染色体解码为车辆路径 VC、车辆使用数目 NV、车辆行驶总距离 TD、违反路径约束的数目 violate_num 和违反顾客时间窗约束的数目 violate_cus
    [Tcost]=costFuction(VC,a,b,s,L,dist,demands,cap,alpha,X1,X2,speed);
    ObjV(i)=Tcost;  %将计算出的成本函数值 costF 存储在 ObjV 向量的第 i 个位置
    %ObjV(i)=NV+G*violate_cus    
end
end

