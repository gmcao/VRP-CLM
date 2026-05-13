%% 计算平均送达偏差率（%）
function avgDeviationRate = calculate_average_delivery_bias(VC, a, b, s, dist, speed, cusnum)
    total_deviation_rate = 0;
    total_customers = 0;
    
    for k = 1:length(VC)
        route = VC{k};
        if isempty(route)
            continue;
        end
        
        current_time = 0;  % 从配送中心出发开始，时间为0
        current_pos = 0;   % 配送中心编号为0
        
        for i = 1:length(route)
            customer = route(i);
            if customer > cusnum
                continue;
            end
            
            % 行驶时间
            travel_time = dist(current_pos + 1, customer + 1) / speed;
            current_time = current_time + travel_time;
            
            % 等待至时间窗开始（早到就等待）
            if current_time < a(customer)
                current_time = a(customer);
            end
            
            % 计算偏差率
            tw_mid = (a(customer) + b(customer)) / 2;
            tw_width = b(customer) - a(customer);
            deviation = abs(current_time - tw_mid);
            
            if tw_width > 0
                bias_percentage = (deviation / tw_width) * 100;
                total_deviation_rate = total_deviation_rate + bias_percentage;
            end
            total_customers = total_customers + 1;
            
            % 服务时间
            current_time = current_time + s(customer);
            current_pos = customer;
        end
    end
    
    if total_customers > 0
        avgDeviationRate = total_deviation_rate / total_customers;
    else
        avgDeviationRate = 0;
    end
end