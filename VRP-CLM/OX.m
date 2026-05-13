
%  顺序交叉是一种专门用于处理路径或序列编码的染色体的交叉方法，常见于解决旅行商问题（TSP）和车辆路径问题（VRP）等组合优化问题。   
%输入：
%a和b为两个待交叉的个体
%输出：
%a和b为交叉后得到的两个个体
function [a,b]=OX(a,b)
L=length(a);  %获取输入染色体 a 的长度，即顾客的数量
while 1       %开始一个无限循环，直到找到两个不同的随机交叉点 r1 和 r2
    r1=randsrc(1,1,[1:L]);%生成两个介于 1 到 L 之间的随机整数，作为可能的交叉点。
    r2=randsrc(1,1,[1:L]);
    if r1~=r2
        s=min([r1,r2]);   %确定两个父代染色体的交叉段的起始点 s 
        e=max([r1,r2]);   %确定两个父代染色体的交叉段的结束点 e
        a0=[b(s:e),a];    %根据父代染色体 a 和 b 以及交叉段创建两个新的后代个体 a0 和 b0。后代个体由父代染色体的交叉段和剩余部分组成
        b0=[a(s:e),b];
        for i=1:length(a0)            %遍历后代个体 a0 和 b0 的每个基因
            aindex=find(a0==a0(i));   %找到后代个体中与当前基因相同的所有基因的位置
            bindex=find(b0==b0(i));
            if length(aindex)>1       %如果有多个相同的基因（即 length(aindex)>1 或 length(bindex)>1），则移除重复的基因，只保留一个
                a0(aindex(2))=[];
            end
            if length(bindex)>1
                b0(bindex(2))=[];
            end
            if i==length(a)
                break
            end
        end
        a=a0;                      %将创建的后代个体替换原来的父代个体
        b=b0;
        break
    end
end

%randsrc(m, n, alphabet)：生成一个 m 行 n 列的矩阵，其中 alphabet 是一个向量，指定了矩阵中元素可能取值的集合。alphabet 中的元素应是不同的，且在生成的矩阵中等概率分布