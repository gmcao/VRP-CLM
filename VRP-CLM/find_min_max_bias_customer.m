%% 同时找出偏差率最小和最大的客户
function [min_customer, min_bias, max_customer, max_bias, all_customer_bias] = find_min_max_bias_customer(bestVC, a, b, s, dist, speed, cusnum)
    %% 找出当前配送方案中送达偏差率最小和最大的客户
    % 输入：
    %   bestVC - 车辆路径（cell数组）
    %   a,b - 客户时间窗
    %   s - 服务时间
    %   dist - 距离矩阵
    %   speed - 配送速度
    %   cusnum - 客户数量
    % 输出：
    %   min_customer - 偏差率最小的客户编号
    %   min_bias - 最小偏差率（%）
    %   max_customer - 偏差率最大的客户编号
    %   max_bias - 最大偏差率（%）
    %   all_customer_bias - 所有客户的偏差率列表 [客户编号, 偏差率]
    
    min_bias = inf;
    max_bias = -inf;
    min_customer = -1;
    max_customer = -1;
    all_customer_bias = [];
    
    for k = 1:length(bestVC)
        route = bestVC{k};
        if isempty(route)
            continue;
        end
        
        current_time = 0;
        current_pos = 0;
        
        for i = 1:length(route)
            customer = route(i);
            if customer > cusnum
                continue;
            end
            
            travel_time = dist(current_pos + 1, customer + 1) / speed;
            current_time = current_time + travel_time;
            
            if current_time < a(customer)
                current_time = a(customer);
            end
            
            tw_mid = (a(customer) + b(customer)) / 2;
            tw_width = b(customer) - a(customer);
            deviation = abs(current_time - tw_mid);
            
            if tw_width > 0
                bias_percentage = (deviation / tw_width) * 100;
            else
                bias_percentage = 0;
            end
            
            all_customer_bias = [all_customer_bias; customer, bias_percentage];
            
            if bias_percentage < min_bias
                min_bias = bias_percentage;
                min_customer = customer;
            end
            
            if bias_percentage > max_bias
                max_bias = bias_percentage;
                max_customer = customer;
            end
            
            current_time = current_time + s(customer);
            current_pos = customer;
        end
    end
    
    % 输出结果
    fprintf('送达偏差率最小的客户: %d号, 偏差率: %.2f%%\n', min_customer, min_bias);
    fprintf('送达偏差率最大的客户: %d号, 偏差率: %.2f%%\n', max_customer, max_bias);
end