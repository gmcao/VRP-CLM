function draw_Best(bestVC, vertexs_service, I2O, service_internal, abandon_original, c101)
    % 输入：
    %   bestVC - 配送路径（内部编号），cell数组，每个元素是一条路径
    %   vertexs_service - 所有顶点坐标（第1行配送中心，后续客户按内部编号1-cusnum）
    %   I2O - 内部编号→原始编号映射表
    %   service_internal - 所有可服务客户内部编号（1:cusnum）
    %   abandon_original - 被舍弃客户原始编号
    %   c101 - 原始数据矩阵（用于查找被舍弃客户的坐标）
    
    figure('Name', '配送路线图', 'Position', [100, 100, 1200, 800]); % 加宽画布，适配横向分布
    hold on;
    
    % ==================== 1. 绘制配送中心 ====================
    depot_x = vertexs_service(1, 1);
    depot_y = vertexs_service(1, 2);
    plot(depot_x, depot_y, 'rs', 'MarkerSize', 12, 'MarkerFaceColor', 'r', 'LineWidth', 2);
    text(depot_x, depot_y, ' 配送中心', 'FontSize', 11, 'FontWeight', 'bold');
    
    % ==================== 2. 绘制被舍弃客户点 ====================
    if exist('abandon_original', 'var') && ~isempty(abandon_original) && exist('c101', 'var')
        original_to_coord = containers.Map('KeyType', 'double', 'ValueType', 'any');
        for i = 2:size(c101, 1)
            original_id = c101(i, 1);
            x = c101(i, 2);
            y = c101(i, 3);
            original_to_coord(original_id) = [x, y];
        end
        
        for i = 1:length(abandon_original)
            original_id = abandon_original(i);
            if original_to_coord.isKey(original_id)
                coord = original_to_coord(original_id);
                x = coord(1);
                y = coord(2);
                plot(x, y, 'xk', 'MarkerSize', 10, 'LineWidth', 1.5);
                text(x, y, sprintf('  %d(舍)', original_id), 'FontSize', 8, 'Color', [0.3 0.3 0.3]);
            end
        end
    end
    
    % ==================== 3. 绘制可服务客户点 ====================
    served_customers = [];
    for i = 1:length(bestVC)
        route = bestVC{i};
        if ~isempty(route)
            served_customers = [served_customers, route];
        end
    end
    served_customers = unique(served_customers);
    
    for i = 1:length(served_customers)
        customer = served_customers(i);
        x = vertexs_service(customer+1, 1);
        y = vertexs_service(customer+1, 2);
        plot(x, y, 'bo', 'MarkerSize', 6, 'MarkerFaceColor', 'b', 'LineWidth', 1);
        original_id = I2O(customer);
        % 微调标注位置，避免重叠
        text(x+0.03, y+0.03, sprintf('%d', original_id), 'FontSize', 8, 'FontWeight', 'normal');
    end
    
    % ==================== 4. 绘制配送路线（不同颜色区分车辆） ====================
    colors = {'r', 'g', 'b', 'm', 'c', 'y', 'k', [0.8 0.4 0], [0.5 0.5 0.5], [0.2 0.6 0.8]};
    route_handles = [];
    route_names = {};
    
    for i = 1:length(bestVC)
        route = bestVC{i};
        if isempty(route)
            continue;
        end
        
        points_x = [depot_x];
        points_y = [depot_y];
        
        for j = 1:length(route)
            customer = route(j);
            points_x = [points_x, vertexs_service(customer+1, 1)];
            points_y = [points_y, vertexs_service(customer+1, 2)];
        end
        points_x = [points_x, depot_x];
        points_y = [points_y, depot_y];
        
        color = colors{mod(i-1, length(colors)) + 1};
        h_route = plot(points_x, points_y, '-', 'Color', color, 'LineWidth', 2);
        route_handles = [route_handles, h_route];
        route_names{end+1} = sprintf('车辆%d', i);
    end
    
    % ==================== 5. 图例 ====================
    h_depot = plot(NaN, NaN, 'rs', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
    h_customer = plot(NaN, NaN, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    h_abandon = plot(NaN, NaN, 'xk', 'MarkerSize', 10, 'LineWidth', 1.5);
    
    legend_handles = [h_depot, h_customer, h_abandon, route_handles];
    legend_names = {'配送中心', '可服务客户', '被舍弃客户', route_names{:}};
    legend(legend_handles, legend_names, 'Location', 'best', 'FontSize', 9);
    
    % ==================== 6. 统计信息 ====================
    served_count = length(served_customers);
    vehicle_count = length(bestVC);
    if exist('abandon_original', 'var') && ~isempty(abandon_original)
        abandon_count = length(abandon_original);
        text_str = sprintf('可服务客户: %d个\n被舍弃客户: %d个\n使用车辆: %d辆', ...
            served_count, abandon_count, vehicle_count);
    else
        text_str = sprintf('可服务客户: %d个\n使用车辆: %d辆', served_count, vehicle_count);
    end
    text(0.02, 0.98, text_str, 'Units', 'normalized', 'FontSize', 10, ...
        'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
        'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontWeight', 'bold');
    
    % ==================== 7. 图形设置（关键优化） ====================
    xlabel('X坐标 (km)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Y坐标 (km)', 'FontSize', 11, 'FontWeight', 'bold');
    title('最优配送路线图', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    % 移除 axis equal，改为自动适配比例
    % axis equal; 
    % 可选：手动约束坐标范围，让图形更紧凑（根据你的数据调整）
    % xlim([min(vertexs_service(:,1))-0.2, max(vertexs_service(:,1))+0.2]);
    % ylim([min(vertexs_service(:,2))-0.2, max(vertexs_service(:,2))+0.2]);
    hold off;
end