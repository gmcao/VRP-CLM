
%% 根据vehicles_customer整理出final_vehicles_customer，将vehicles_customer中空的数组移除
% 它用于处理车辆-顾客矩阵（vehicles_customer），并返回一个整理后的车辆-顾客矩阵（final_vehicles_customer）以及实际使用的车辆数量（vehicles_used）。这个函数的目的是移除任何空的车辆路径，这些路径可能由于某些顾客没有被分配到任何车辆而产生。
% 输入：vehicles_customer        每辆车所经过的顾客
% 输出：final_vehicles_customer  删除空数组，整理后的vehicles_customer
function [ final_vehicles_customer,vehicles_used ] = deal_vehicles_customer( vehicles_customer )
vecnum=size(vehicles_customer,1);               %车辆数
final_vehicles_customer={};                     %初始化一个空的单元数组 ，用于存储整理后的车辆-顾客路径
count=1;                                        %计数器
for i=1:vecnum                                  %循环遍历所有的车辆
    par_seq=vehicles_customer{i};               %获取第 i 辆车的路径
    %如果该辆车所经过顾客的数量不为0，则将其所经过的顾客数组添加到final_vehicles_customer中
    if ~isempty(par_seq)   %检查该路径是否为空。如果路径不为空，即该车辆至少分配了一个顾客，则执行以下操作                         
        final_vehicles_customer{count}=par_seq;  %将非空路径添加到 final_vehicles_customer 单元数组中
        count=count+1;
    end
end
%% 为了容易看，将上述生成的1行多列的final_vehicles_customer转置了，变成多行1列的了
final_vehicles_customer=final_vehicles_customer';     %转置，使其从一行多列的形式变为多行一列的形式，这样每行代表一辆车的顾客路径，便于后续处理和可视化    
vehicles_used=size(final_vehicles_customer,1);        %获取整理后的车辆-顾客矩阵的行数，即实际使用的车辆数量
end

