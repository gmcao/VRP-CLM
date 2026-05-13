function Chrom=Inits(NIND,N)
Chrom=zeros(NIND,N);
for i=1:NIND
    Chrom(i,:)=randperm(N);  %循环内部，使用 randperm 函数生成一个长度为 N 的随机排列。randperm 函数返回一个从 1 到 N 的随机排列，这代表了染色体的一个随机解。这个随机解被存储在 Chrom 矩阵的第 i 行。
end
