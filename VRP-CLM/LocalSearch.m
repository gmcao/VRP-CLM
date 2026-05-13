%% 局部搜索函数
%输入：SelCh               被选择的个体
%输入：cusnum              顾客数目
%输入：cap                 最大载重量
%输入：demands             需求量
%输入：a                   顾客时间窗开始时间[a[i],b[i]]
%输入：b                   顾客时间窗结束时间[a[i],b[i]]
%输入：L                   配送中心时间窗结束时间
%输入：s                   客户点的服务时间
%输入：dist                距离矩阵，满足三角关系，暂用距离表示花费c[i][j]=dist[i][j]
%输出：SelCh               进化逆转后的个体
function SelCh=LocalSearch(SelCh,cusnum,cap,demands,a,b,L,s,dist,alpha,X1,X2,speed)  %接受选择后的个体矩阵 SelCh 和 VRP 问题的相关参数作为输入，并返回经过局部搜索优化的个体矩阵 SelCh
D=5;                                                       %Remove过程中的随机元素
toRemove=6;                                                %将要移出顾客的数量
[row,N]=size(SelCh);
for i=1:row
    %解码和计算成本
   [VC,NV,TD,everyTD,Tcost,total_runtime,w,violate_num,violate_cus]=decode(SelCh(i,:),cusnum,cap,demands,a,b,L,s,dist,alpha,X1,X2,speed); %解码当前个体的染色体 SelCh(i,:) 得到车辆路径 VC
    CF=costFuction(VC,a,b,s,L,dist,demands,cap,alpha,X1,X2,speed);                               %计算当前个体的成本函数值 CF
    %Remove 局部搜索操作
    [removed,rfvc] = Remove(cusnum,toRemove,D,dist,VC);  %调用 Remove 函数从当前路径 VC 中移除一定数量的顾客，得到移除的顾客列表 removed 和新的路径 rfvc
    %Re-inserting  重新插入
    [ReIfvc,RTD] = Re_inserting(removed,rfvc,L,a,b,s,dist,demands,cap,speed); %调用 Re_inserting 函数将移除的顾客重新插入到新的路径 rfvc 中，得到重新插入后的路径 ReIfvc 和重新计算的总距离 RTD
    %计算惩罚函数
    RCF=costFuction(ReIfvc,a,b,s,L,dist,demands,cap,alpha,X1,X2,speed);       %计算重新插入顾客后的成本函数值 RCF
    if RCF<CF                                                           %如果新路径的成本 RCF 小于原路径的成本 CF，则执行更新操作
        chrom=change(ReIfvc,N,cusnum);                                  %调用 change 函数更新个体的染色体
        if length(chrom)~=N                                             %检查更新后的染色体长度是否与原长度 N 相同
            record=ReIfvc;                                              %如果长度不同，记录新的路径 ReIfvc  
            break
        end
        SelCh(i,:)=chrom;                                               %函数返回经过局部搜索优化的个体矩阵 SelCh
    end
end
