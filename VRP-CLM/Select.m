
%% 选择操作
%输入
%Chrom 种群
%FitnV 适应度值
%GGAP：选择概率
%输出
%SelCh  被选择的个体 
function SelCh=Select(Chrom,FitnV,GGAP)    %返回被选中的个体矩阵 SelCh
NIND=size(Chrom,1);
NSel=max(floor(NIND*GGAP+.5),2);           %根据 GGAP 计算应该选择的个体数量 NSel。使用 floor 函数向下取整，确保即使在 GGAP 乘以 NIND 后结果不是整数，也会得到一个整数的个体数量。.5 是为了在取整时进行四舍五入。max 函数确保至少选择 2 个个体，即使 GGAP 乘以 NIND 的结果小于 2。
ChrIx=Sus(FitnV,NSel);                     %FitnV 向量作为 Sus 函数（随机普遍采样）的输入，意味着选择过程可能考虑个体的适应度。ChrIx 是被选中个体的索引数组
SelCh=Chrom(ChrIx,:);                      %根据索引数组 ChrIx 从 Chrom 矩阵中提取选中的个体，并将它们组成一个新的矩阵 SelCh 返回。