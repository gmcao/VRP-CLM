function [service_idx, abandon_idx, service_num, abandon_num, weight, rate, service_c101] = customer_selection_ahp(c101, max_abandon_rate, judgment_matrix)
    %% 博弈论组合权重（AHP+熵值法）客户筛选 —— 完全兼容原接口
    % 输出格式与原函数完全一致，内部使用组合权重计算舍弃成本
    % 排序规则：舍弃成本越小 → 越优先舍弃

    %% ===================== 1. 提取数据 =====================
    customer_data = c101(2:end, :);
    num_customers = size(customer_data, 1);
    depot_x = c101(1, 2);
    depot_y = c101(1, 3);

    %% ===================== 2. 提取4个指标 =====================
    cve_raw = customer_data(:, 8);
    ctw_raw = customer_data(:, 6) - customer_data(:, 5);
    cdd_raw = sqrt((customer_data(:,2)-depot_x).^2 + (customer_data(:,3)-depot_y).^2);
    cdv_raw = customer_data(:, 4);

    %% ===================== 3. 标准化（和你权重代码一致）=====================
    raw_data = [cve_raw, ctw_raw, cdd_raw, cdv_raw];
    [n, m] = size(raw_data);
    standard_data = zeros(n, m);
    eps_val = 1e-6;

    for j = 1:m
        data_j = raw_data(:, j);
        max_j = max(data_j);
        min_j = min(data_j);
        switch j
            case 1, standard_data(:,j) = (max_j - data_j) / (max_j - min_j + eps_val);
            case 2, standard_data(:,j) = (max_j - data_j) / (max_j - min_j + eps_val);
            case 3, standard_data(:,j) = (max_j - data_j) / (max_j - min_j + eps_val);
            case 4, standard_data(:,j) = (data_j - min_j) / (max_j - min_j + eps_val);
        end
    end

    %% ===================== 4. 熵值法权重 =====================
    sd = standard_data + eps_val;
    p = sd ./ sum(sd);
    E = -sum(p .* log(p), 1) / log(n);
    g = 1 - E;
    w_entropy = g / sum(g);
    w_entropy = w_entropy(:);

    %% ===================== 5. AHP权重 =====================
    [w_ahp, CR] = ahp_weight(judgment_matrix);
    if CR >= 0.1
        error('AHP 一致性检验不通过！CR=%.4f', CR);
    end
    w_ahp = w_ahp(:);

    %% ===================== 6. 博弈论组合权重 =====================
    w1 = w_ahp;
    w2 = w_entropy;
    numerator_alpha = (w1 - w2)' * w1;
    denominator = (w1 - w2)' * (w1 - w2) + eps_val;
    alpha = numerator_alpha / denominator;
    alpha = max(0, min(1, alpha));
    beta = 1 - alpha;
    weight = alpha * w1 + beta * w2;
    weight = weight / sum(weight);

    %% ===================== 7. 计算舍弃成本（越小越舍弃）=====================
    abandon_cost = standard_data * weight;

    %% ===================== 8. 排序：从小到大 =====================
    [rate, sort_idx] = sort(abandon_cost, 'ascend');

    %% ===================== 9. 筛选客户 =====================
    abandon_num = floor(num_customers * max_abandon_rate);
    service_num = num_customers - abandon_num;

    if abandon_num > 0
        abandon_idx = sort_idx(1:abandon_num);
        service_idx = sort_idx(abandon_num+1:end);
    else
        abandon_idx = [];
        service_idx = sort_idx;
    end

    %% ===================== 10. 构建筛选后数据集 =====================
    service_c101 = c101(1,:);
    for i = 1:length(service_idx)
        service_c101 = [service_c101; c101(service_idx(i)+1,:)];
    end

    %% ===================== 11. 输出信息 =====================
    fprintf('\n========== 博弈论组合权重客户筛选结果 ==========\n');
    fprintf('组合权重：cve=%.4f, ctw=%.4f, cdd=%.4f, cdv=%.4f\n',...
        weight(1),weight(2),weight(3),weight(4));
    fprintf('AHP贡献：%.2f | 熵值法贡献：%.2f\n', alpha,beta);
    fprintf('总客户：%d | 服务：%d | 舍弃：%d | 舍弃率：%.2f%%\n',...
        num_customers,service_num,abandon_num,abandon_num/num_customers*100);
    fprintf('服务客户：'); fprintf('%d ',service_idx); fprintf('\n');
    fprintf('舍弃客户：'); fprintf('%d ',abandon_idx); fprintf('\n');
    fprintf('==================================================\n');
end