
%     这段代码定义了一个名为 Sus 的函数，用于执行随机普遍采样（Stochastic Universal Sampling，简称 SUS）选择算法。SUS 是一种基于适应度的选择方法，它用于从当前种群中选择一定数量的个体以形成新的种群。该函数接受适应度向量 FitnV 和要选择的个体数量 Nsel 作为输入参数，并返回新种群的个体索引 NewChrIx。
% 输入:
%FitnV  个体的适应度值
%Nsel   被选择个体的数目
% 输出:
%NewChrIx  被选择个体的索引号
function NewChrIx = Sus(FitnV,NSel)

% Identify the population size (Nind)确定种群规模
   [Nind,ans] = size(FitnV);%获取适应度向量 FitnV 的长度，即种群中个体的数量 Nind

% Perform stochastic universal sampling(进行随机普遍抽样)
   cumfit = cumsum(FitnV);                               %计算适应度向量 FitnV 的累积和
   trials = cumfit(Nind) / NSel * (rand + (0:NSel-1)');  %生成一个与 Nsel 同长度的向量，其中的元素是从 0 到 Nsel-1 的整数，然后将其乘以 cumfit(Nind) / Nsel 并加上 rand 生成的随机数，以模拟适应度比例的随机选择
   Mf = cumfit(:, ones(1, NSel));                        %创建一个矩阵 Mf，其中每一行都是 cumfit 向量的一个副本，用于后续比较
   Mt = trials(:, ones(1, Nind))';                       %创建一个矩阵 Mt，其中每一列都是 trials 向量的一个副本，用于后续比较
   [NewChrIx, ans] = find(Mt < Mf & [ zeros(1, NSel); Mf(1:Nind-1, :) ] <= Mt);%找到 Mt 矩阵中小于 Mf 矩阵对应元素的位置，这些位置的个体被选中。find 函数返回这些位置的索引，即 NewChrIx
  % & 它通常用于表示逻辑运算中的"与"操作，表示两个条件同时满足的情况
% Shuffle new population 洗牌新种群
   [ans, shuf] = sort(rand(NSel, 1)); %rand(Nsel, 1)：生成一个 Nsel 行 1 列的矩阵；sort(..., 'ascend')：对生成的随机数矩阵进行排序。默认情况下，sort 函数按升序排序。
   NewChrIx = NewChrIx(shuf);         %根据 shuf 打乱 NewChrIx 的顺序，以确保选择过程的随机性。


% End of function


%size 函数的基本用法是 [size_rows, size_columns] = size(A)，其中 A 是一个矩阵或数组，size_rows
%和 size_columns 分别是矩阵的行数和列数。在这个特定的例子中，FitnV 是一个向量，所以它只有一行，因此 size_columns 将给出向量的长度（即种群中个体的数量），而 size_rows 将是 1。
%在这行代码中：Nind 被赋值为 FitnV 的长度，即种群中个体的数量;ans 是一个辅助变量，用于存储 size 函数返回的第二个值（在这个情况下是列数）。在这个上下文中，由于 FitnV 是一个行向量，所以 ans 将会是 1。
%cumfit(Nind)：这部分代码计算适应度累积分布的最后一个值。cumfit 是一个累积适应度向量，其中 cumfit(1) 是第一个个体的适应度值，cumfit(2) 是前两个个体适应度值的总和，以此类推，直到 cumfit(Nind)，它是整个种群适应度值的总和
%sort 函数返回两个值。第一个返回值 ans 是排序后的索引数组，它表示原始随机数矩阵中元素在排序后的新位置。第二个返回值 shuf 是根据排序后的索引重新排列的随机数矩阵