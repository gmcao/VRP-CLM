function SelCh = RouletteWheelSelection(Chrom, FitnV)
    NIND = size(Chrom, 1);  % 种群大小
    SelCh = zeros(NIND, size(Chrom, 2));  % 初始化选择后的种群矩阵
    
    % 计算总适应度
    totalFitness = sum(FitnV);
    % 计算每个个体的选择概率
    Prob = FitnV / totalFitness;
    % 计算累积概率
    CumProb = cumsum(Prob);
    
    for i = 1:NIND
        % 产生一个[0,1)之间的随机数
        r = rand;
        % 确定随机数落在哪个区间
        index = find(r <= CumProb, 1, 'first');
        % 选择对应的个体
        SelCh(i, :) = Chrom(index, :);
    end
end