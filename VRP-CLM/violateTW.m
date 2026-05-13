function [bsv, total_runtime, w, violating_points, violation_durations] = ...
    violateTW(curr_vc, a, b, s, L, dist, speed)
%% 计算当前解违反的时间窗约束（不分客户类型）
% 输入：
%   curr_vc     - 每辆车所经过的顾客（cell数组）
%   a, b        - 顾客时间窗开始/结束时间
%   s           - 对每个顾客的服务时间
%   L           - 仓库时间窗结束时间
%   dist        - 距离矩阵
%   speed       - 行驶速度
% 输出：
%   bsv         - 每辆车各点的开始服务时间（cell数组）
%   total_runtime - 每辆车配送总时间
%   w           - 总违约成本
%   violating_points - 违背时间窗的配送点（cell数组）
%   violation_durations - 违背时间窗的时长（cell数组）

    NV = size(curr_vc, 1);
    w = 0;
    violating_points = cell(NV, 1);
    violation_durations = cell(NV, 1);
    
    % 惩罚参数设置（可根据需要调整）
    belta = 4;              % 线性惩罚系数
    t0 = 10;                % 超时阈值（分钟），超过li但在t0内线性惩罚
    threshold_time = t0;    % 超时时间阈值
    
    % 计算每辆车的开始服务时间和返回时间
    [bsv, total_runtime] = begin_s_v(curr_vc, a, s, dist, speed);
    
    for i = 1:NV
        route = curr_vc{i};
        bs = bsv{i};
        
        % 遍历路线上每个顾客（包括最后一个）
        for j = 1:length(bs)
            if j <= length(route)
                % 顾客点
                point_idx = route(j);
                time_limit = b(point_idx);  % 顾客时间窗结束时间 li
            else
                % 返回配送中心
                point_idx = 0;  % 配送中心
                time_limit = L;  % 仓库时间窗结束时间
            end
            
            % 检查是否违反时间窗
            if bs(j) > time_limit
                violation_time = bs(j) - time_limit;  % 超时时长
                
                % 计算惩罚成本
                if violation_time <= threshold_time
                    % 在t0内：线性惩罚
                    penalty_cost = violation_time * belta;
                else
                    % 超过t0：两部分惩罚
                    % 第一部分：t0内的线性惩罚
                    linear_part = threshold_time * belta;
                    
                    % 第二部分：超过t0的部分，指数惩罚
                    base = belta;
                    exponent = violation_time - threshold_time;
                    bese_1 = power(base, exponent);
                    
                    % 安全检查：防止指数爆炸
                    if isnan(bese_1) || isinf(bese_1)
                        bese_1 = 1e10;
                    end
                    
                    penalty_cost = linear_part + bese_1;
                end
                
                % 累加总惩罚
                w = w + penalty_cost;
                
                % 记录违规信息
                if point_idx > 0
                    violating_points{i} = [violating_points{i}, point_idx];
                else
                    violating_points{i} = [violating_points{i}, 0];  % 0表示配送中心
                end
                violation_durations{i} = [violation_durations{i}, violation_time];
            end
        end
    end
end