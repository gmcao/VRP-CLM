function [service_idx, abandon_idx, service_num, abandon_num, weight, rate, service_c101, Z, final_scores] = ...
    customer_selection_ahp_entropy(c101, max_abandon_rate, judgment_matrix, lambda_ahp, lambda_entropy)
%CUSTOMER_SELECTION_AHP_ENTROPY 基于AHP-熵值法组合赋权的客户筛选（3指标版）
%   指标顺序（与判断矩阵一致）:
%       1. 时间窗紧迫性 = li - ei（成本型：越小越紧迫）
%       2. 距中心距离（成本型：越远越差）
%       3. 需求量（效益型：越大越好）

    %% ========== 步骤1: AHP计算主观权重 ==========
    [w_ahp, CR] = ahp_weight(judgment_matrix);
    fprintf('\n==================== AHP层次分析法 ====================\n');
    fprintf('判断矩阵阶数: %d\n', size(judgment_matrix, 1));
    fprintf('最大特征值 λ_max = %.4f\n', max(eig(judgment_matrix)));
    fprintf('一致性指标 CI = %.4f\n', (max(eig(judgment_matrix)) - size(judgment_matrix, 1)) / (size(judgment_matrix, 1) - 1));
    fprintf('随机一致性指标 RI = %.4f\n', 0.58);  % 3阶矩阵RI=0.58
    fprintf('一致性比例 CR = %.4f\n', CR);
    if CR < 0.1
        fprintf('✓ 一致性检验通过 (CR < 0.1)\n');
    else
        fprintf('✗ 一致性检验未通过 (CR >= 0.1)\n');
    end
    fprintf('主观权重: ');
    disp(w_ahp);
    fprintf('========================================================\n');
    
    if CR > 0.1
        warning('AHP判断矩阵一致性检验未通过(CR>0.1)，请检查判断矩阵！');
    end
    
    %% ========== 步骤2: 构建3指标评价矩阵 ==========
    n = size(c101, 1) - 1;  % 去掉配送中心，客户数量
    
    % 配送中心坐标（第1行）
    x0 = c101(1, 2);
    y0 = c101(1, 3);
    
    % 客户数据（第2行开始）
    x = c101(2:end, 2);           % x坐标
    y = c101(2:end, 3);           % y坐标
    demand = c101(2:end, 4);      % 需求量（第4列）
    ei = c101(2:end, 5);          % 开始时间（第5列）
    li = c101(2:end, 6);          % 结束时间（第6列）
    
    % 计算三个指标（与判断矩阵顺序一致）
    % 指标1: 时间窗紧迫性 = li - ei（成本型：越小越紧迫，需要反向归一化）
    time_window_urgency = li - ei;
    indicators(:, 1) = time_window_urgency;
    
    % 指标2: 距中心距离（成本型：越远越差，需要反向归一化）
    distance_to_center = sqrt((x - x0).^2 + (y - y0).^2);
    indicators(:, 2) = distance_to_center;
    
    % 指标3: 需求量（效益型：越大越好）
    indicators(:, 3) = demand;
    
    % 打印原始指标统计
    fprintf('\n========== 原始指标统计 ==========\n');
    fprintf('指标1(时间窗紧迫性li-ei): min=%.2f, max=%.2f, mean=%.2f\n', ...
        min(time_window_urgency), max(time_window_urgency), mean(time_window_urgency));
    fprintf('指标2(距中心距离): min=%.4f, max=%.4f, mean=%.4f\n', ...
        min(distance_to_center), max(distance_to_center), mean(distance_to_center));
    fprintf('指标3(需求量): min=%.0f, max=%.0f, mean=%.2f\n', ...
        min(demand), max(demand), mean(demand));
    
    %% ========== 步骤3: 熵值法计算客观权重 ==========
    w_entropy = entropy_weight(indicators);
    fprintf('\n熵值法权重(紧迫性/距离/需求): ');
    disp(w_entropy);
    
    %% ========== 步骤4: 组合赋权 ==========
    weight = lambda_ahp * w_ahp + lambda_entropy * w_entropy;
    fprintf('AHP权重=%.2f, 熵值法权重=%.2f\n', lambda_ahp, lambda_entropy);
    fprintf('组合权重（紧迫性/距离/需求）: ');
    disp(weight);
    
    %% ========== 步骤5: 归一化（注意指标方向！）==========
    Z = zeros(n, 3);
    
    for j = 1:3
        col = indicators(:, j);
        col_min = min(col);
        col_max = max(col);
        
        if j == 1 || j == 2
            % 成本型指标：越小越好（时间窗紧迫性、距中心距离）
            % 反向归一化：值越小，归一化后越大（表示越差，得分越低）
            Z(:, j) = (col_max - col) / (col_max - col_min + eps);
        else
            % 效益型指标：越大越好（需求量）
            Z(:, j) = (col - col_min) / (col_max - col_min + eps);
        end
    end
    
    % 最终综合评分
    rate = Z * weight';
    final_scores = rate;
    
    %% ========== 步骤6: 客户筛选 ==========
    [sorted_rate, sort_idx] = sort(rate, 'descend');
    
    total_customers = n;
    max_abandon_num = floor(total_customers * max_abandon_rate);
    abandon_num = max_abandon_num;
    service_num = total_customers - abandon_num;
    
    service_local_idx = sort_idx(1:service_num);
    abandon_local_idx = sort_idx(service_num+1:end);
    
    service_rows = service_local_idx + 1;
    abandon_rows = abandon_local_idx + 1;
    
    service_idx = c101(service_rows, 1);
    abandon_idx = c101(abandon_rows, 1);
    service_c101 = c101([1; service_rows], :);
    
    %% ========== 输出详细数据 ==========
    fprintf('\n========== 客户筛选详细数据 ==========\n');
    fprintf('客户ID  紧迫性(原始) 距离(原始)  需求量(原始)  最终评分  状态\n');
    for i = 1:n
        status = '保留';
        if ismember(i, abandon_local_idx)
            status = '舍弃';
        end
        fprintf('%6d  %12.2f  %10.4f  %12.0f  %10.4f  %s\n', ...
            c101(i+1, 1), indicators(i,1), indicators(i,2), indicators(i,3), final_scores(i), status);
    end
    
    fprintf('\n========== 归一化值（注意：成本型指标已反向）==========\n');
    fprintf('客户ID  紧迫性(归一) 距离(归一)  需求量(归一)  最终评分\n');
    for i = 1:n
        fprintf('%6d  %12.4f  %10.4f  %12.4f  %10.4f\n', ...
            c101(i+1, 1), Z(i,1), Z(i,2), Z(i,3), final_scores(i));
    end
    
    fprintf('\n========== 舍弃客户列表 ==========\n');
    for i = 1:length(abandon_idx)
        idx = abandon_rows(i) - 1;
        fprintf('舍弃客户 %d: ID=%d, 紧迫性=%.2f, 距离=%.4f, 需求量=%.0f, 最终评分=%.4f\n', ...
            i, abandon_idx(i), indicators(idx,1), indicators(idx,2), indicators(idx,3), final_scores(idx));
    end
    fprintf('可服务客户数: %d, 舍弃客户数: %d\n', service_num, abandon_num);
    fprintf('==================================\n\n');
end

%% ========== 辅助函数：熵值法 ==========
function w = entropy_weight(X)
%ENTROPY_WEIGHT 熵值法计算权重
    [n, m] = size(X);
    Z = zeros(n, m);
    for j = 1:m
        col = X(:, j);
        min_col = min(col);
        max_col = max(col);
        if max_col - min_col < eps
            Z(:, j) = 1/n;
        else
            Z(:, j) = (col - min_col) / (max_col - min_col);
        end
    end
    P = Z ./ sum(Z, 1);
    P(P == 0) = eps;
    k = 1 / log(n);
    E = -k * sum(P .* log(P), 1);
    G = 1 - E;
    w = G / sum(G);
end