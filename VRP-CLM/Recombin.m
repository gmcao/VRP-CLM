
%% 交叉操作
% 输入
%SelCh  被选择的个体
%Pc     交叉概率
%输出：
% SelCh 交叉后的个体
function SelCh=Recombin(SelCh,Pc) %定义了 Recombin 函数，它接受选择后的个体矩阵 SelCh 和交叉概率 Pc 作为输入参数，并返回经过交叉操作的个体矩阵 SelCh
NSel=size(SelCh,1);
for i=1:2:NSel-mod(NSel,2)        %循环遍历 SelCh 中的个体，步长为 2；（mod(NSel,2) 用于处理 NSel 为奇数的情况，确保最后一个人（如果 NSel 是奇数）不会被遗漏）
    if Pc>=rand                   %交叉概率Pc
        [SelCh(i,:),SelCh(i+1,:)]=OX(SelCh(i,:),SelCh(i+1,:));   %(顺序）交叉后的染色体替换原来的染色体
    end
end

