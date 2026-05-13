
%% 计算每辆车所行驶的距离，以及所有车行驶的总距离
%输入vehicles_customer   是一个单元数组，其中每个元素代表一辆车的顾客访问序列
%输入dist                距离矩阵
%输出sumTD               所有车行驶的总距离
%输出everyTD             每辆车所行驶的距离
function [TD,everyTD]=travel_distance(vehicles_customer,dist)
n=size(vehicles_customer,1);                        %车辆数
everyTD=zeros(n,1);
for i=1:n
    part_seq=vehicles_customer{i};                  %获取第 i 辆车的顾客访问序列
       if ~isempty(part_seq)                        %（~，逻辑非）检查该车辆是否访问了至少一个顾客。如果 part_seq 不为空，则执行以下操作：
        everyTD(i)=part_length( part_seq,dist );    % 计算一个子回路的路径长度
    end
end
TD=sum(everyTD);                                 %所有车行驶的总距离

