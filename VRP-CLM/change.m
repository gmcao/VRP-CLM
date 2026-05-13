
%% 配送方案与个体之间进行转换
% change它用于修改车辆路径 VC 以适应特定的染色体长度 N。这个函数在遗传算法中可能用于处理解码过程中的染色体，确保它们满足特定的结构要求
%% 输入与输出
%输入车辆路径 VC、期望的染色体长度 N（N=cusnum+v_num-1） 和顾客数目 cusnum 
%输出返回修改后的染色体 chrom
function chrom=change(VC,N,cusnum)     %函数返回 chrom，即修改后的染色体
NV=size(VC,1);                         %车辆使用数目
chrom=[];                              %创建一个空的染色体 chrom，用于存储修改后的车辆路径和配送中心编号
for i=1:NV
    if (cusnum+i)<=N                  %如果 cusnum+i（当前顾客编号加上车辆编号）小于或等于 N（期望的染色体长度）
        chrom=[chrom,VC{i},cusnum+i];%则将车辆路径 VC{i} 和当前顾客编号 cusnum+i 添加到染色体 chrom 中
    else
        chrom=[chrom,VC{i}];         %否则，只将车辆路径 VC{i} 添加到染色体 chrom 中
    end
end
if length(chrom)<N               %如果染色体长度小于N，则需要向染色体添加配送中心编号
    %添加配送中心编号到染色体
    supply=(cusnum+NV+1):N;     %创建一个包含配送中心编号的向量 supply，从 cusnum+NV+1 到 N           
    chrom=[chrom,supply];       %将配送中心编号 supply 添加到染色体 chrom 的末尾
end
end

