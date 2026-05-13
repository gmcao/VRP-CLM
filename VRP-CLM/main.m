clear
clc
close all
tic

%% 1. 数据准备  ==========================================================================
% （1）读取原始 Solomon C101 数据
c101_raw = dlmread('c101.txt');

% ========== 缩放参数（匹配即时配送 3km×3km 场景）==========
scale_space = 3 / 100;      % 空间缩放：100 → 3 km

% 创建缩放后的算例
c101 = c101_raw;

% 坐标缩放（第2、3列）：0~3 km
c101(:, 2) = c101_raw(:, 2) * scale_space;
c101(:, 3) = c101_raw(:, 3) * scale_space;

% ========== 时间窗缩放（基于原始紧迫性线性映射）==========
% 计算原始时间窗宽度（紧迫性）
original_width = c101_raw(2:end, 6) - c101_raw(2:end, 5);

% 原始范围
orig_min = min(original_width);
orig_max = max(original_width);

% 目标范围（即时配送：5~30分钟）
target_min = 5;
target_max = 30;

% 线性映射公式：新值 = 目标下限 + (原始值 - 原始下限) / (原始范围) × (目标范围)
scaled_width = target_min + (original_width - orig_min) / (orig_max - orig_min) * (target_max - target_min);

% 设置新时间窗：ei = 0, li = 映射后的宽度
c101(2:end, 5) = 0;
c101(2:end, 6) = scaled_width;

% 配送中心时间窗
c101(1, 5) = 0;
c101(1, 6) = 30;

% 服务时间统一设为1分钟（即时配送场景）
c101(:, 7) = 1;

% 第8列客户价值：全部设为1（避免编号偏见，不考虑价值分层）
c101(:, 8) = 1;

% 验证输出
fprintf('========== 缩放后数据验证 ==========\n');
fprintf('空间范围: x=%.4f~%.4f km, y=%.4f~%.4f km\n', ...
    min(c101(2:end, 2)), max(c101(2:end, 2)), min(c101(2:end, 3)), max(c101(2:end, 3)));
fprintf('时间窗范围: %.2f~%.2f min\n', min(c101(2:end, 6)), max(c101(2:end, 6)));
fprintf('服务时间: %.2f min\n', c101(2, 7));
fprintf('原始紧迫性范围: %.2f~%.2f, 映射后: %.2f~%.2f\n', orig_min, orig_max, min(scaled_width), max(scaled_width));

% （2）AHP-熵值法参数配置（3指标版：紧迫性、距离、需求量）
max_abandon_rate = 0;  % 最大允许舍弃率（小数）
judgment_matrix = [1, 3, 5; 
                   1/3, 1, 3; 
                   1/5, 1/3, 1];

% ==================== AHP-熵值法组合赋权权重设置 ====================
lambda_ahp = 0.5;       % AHP权重
lambda_entropy = 0.5;   % 熵值法权重

% （3）调用AHP-熵值法组合赋权的客户筛选函数
[service_idx, abandon_idx, service_num, abandon_num, weight, rate, service_c101, Z, final_scores] = ...
    customer_selection_ahp_entropy(c101, max_abandon_rate, judgment_matrix, lambda_ahp, lambda_entropy);

% （4）编号映射（原始ID ↔ 内部ID）
originalID = service_idx;
internalID = 1:length(originalID);
O2I = containers.Map(originalID, internalID);
I2O = containers.Map(internalID, originalID);
cusnum = length(internalID);

% （5）提取可服务客户核心数据
E = service_c101(1,5);
L = service_c101(1,6);
vertexs_service = service_c101(:,2:3);

% （6）客户数据提取
demands = service_c101(2:end, 4);
a = service_c101(2:end, 5);
b = service_c101(2:end, 6);
s = service_c101(2:end, 7);

% （7）计算距离矩阵
h = pdist(vertexs_service);
dist = squareform(h);

%% 车辆参数（即时配送场景）
cap = 200;         % 载重
speed = 25/60;      % 25 km/h = 0.4167 km/min
X1 = 12;            % 单车固定成本
X2 = 0.4;           % 单位距离成本
v_num = 15;         % 可用车辆上限

%% 遗传算法参数设置
alpha = 100;
NIND = 200;
MAXGEN = 300;
Pc = 0.9;
Pm = 0.05;
GGAP = 0.9;
N = cusnum + v_num - 1;

%% 初始化种群
t1 = 0.4;
t2 = 0.4;
t3 = 0.2;
init_vc = init3(t1, t2, t3, a, b, s, dist, cap, demands, speed);
Chrom = InitPopCW(NIND, N, cusnum, init_vc);

%% 优化
gen = 1;
bestFitnessValues = zeros(MAXGEN, 1);

ObjV = calObj(Chrom, cusnum, cap, demands, a, b, L, s, dist, alpha, X1, X2, speed);
preObjV = min(ObjV);
bestFitnessValues(gen) = preObjV;

while gen <= MAXGEN
    %% 计算适应度
    ObjV = calObj(Chrom, cusnum, cap, demands, a, b, L, s, dist, alpha, X1, X2, speed);
    line([gen-1, gen], [preObjV, min(ObjV)]); pause(0.0001);
    preObjV = min(ObjV);
    FitnV = Fitness(ObjV);
    
    %% 选择
    SelCh = Select(Chrom, FitnV, GGAP);
    
    %% OX交叉操作
    SelCh = Recombin(SelCh, Pc);
    
    %% 变异
    SelCh = Mutate(SelCh, Pm);
    
    %% 局部搜索操作
    SelCh = LocalSearch(SelCh, cusnum, cap, demands, a, b, L, s, dist, alpha, X1, X2, speed);
    
    %% 重插入子代的新种群
    Chrom = Reins(Chrom, SelCh, ObjV);
    
    %% 删除种群中重复个体，并补齐删除的个体
    Chrom = deal_Repeat(Chrom);
    
    %% 打印当前最优解
    ObjV = calObj(Chrom, cusnum, cap, demands, a, b, L, s, dist, alpha, X1, X2, speed);
    [minObjV, minInd] = min(ObjV);
    bestFitnessValues(gen) = minObjV;
    
    disp(['第', num2str(gen), '代最优解:'])
    [bestVC, bestNV, bestTD, besteveryTD, bestTcost, total_runtime, w, best_vionum, best_viocus, violating_points, violation_durations] = ...
        decode(Chrom(minInd(1),:), cusnum, cap, demands, a, b, L, s, dist, alpha, X1, X2, speed);
    
    % 输出
    disp(['车辆使用数目：', num2str(bestNV), '，车辆行驶总距离：', num2str(bestTD), ...
          '，车辆行驶总成本：', num2str(bestTcost), ',违约总成本:', num2str(w), ...
          '，违反约束路径数目：', num2str(best_vionum), '，违反约束顾客数目：', num2str(best_viocus)]);
    
    %% 绘制当前代的最优适应度值
    plot(gen, minObjV, 'b');
    drawnow;
    
    %% 更新迭代次数
    gen = gen + 1;
end

%% 绘制最终收敛曲线
figure;
semilogy(1:MAXGEN, bestFitnessValues, 'k', 'LineWidth', 0.75);
grid off;
set(gca, ...
    'FontSize', 8, ...
    'FontName', 'Times New Roman', ...
    'FontWeight', 'normal', ...
    'LineWidth', 0.5, ...
    'XGrid', 'off', 'YGrid', 'off', ...
    'Box', 'off', ...
    'TickDir', 'in');
title('算法收敛曲线', 'FontName', '华文中宋', 'FontSize', 9.5, 'FontWeight', 'normal');
xlabel('迭代次数/次', 'FontName', '华文中宋', 'FontSize', 9.5, 'FontWeight', 'normal');
ylabel('配送总成本/元', 'FontName', '华文中宋', 'FontSize', 9.5, 'FontWeight', 'normal');

%% 输出最优解
disp('最优解:')
bestChrom = Chrom(minInd(1), :);
[bestVC, bestNV, bestTD, besteveryTD, bestTcost, total_runtime, w, best_vionum, best_viocus, bestviolating_points, violation_durations] = ...
    decode(bestChrom, cusnum, cap, demands, a, b, L, s, dist, alpha, X1, X2, speed);

%% 输出配送路线（映射回原始编号）
fprintf('\n配送路线（原始客户编号）：\n');
for i = 1:length(bestVC)
    route = bestVC{i};
    if isempty(route)
        continue;
    end
    fprintf('配送路线%d：0', i);
    for j = 1:length(route)
        original_customer = I2O(route(j));
        fprintf('->%d', original_customer);
    end
    fprintf('->0\n');
end

%% 判断最优解是否满足时间窗约束和载重量约束
[flag, init_v, init_v_rate, violate_INTW] = Judge(bestVC, cap, demands, a, b, L, s, dist, speed);

%% 检查最优解中是否存在元素丢失的情况
DEL = Judge_Del(bestVC);

%% 画出最终路线图
abandon_original = abandon_idx;
service_internal = 1:cusnum;
draw_Best(bestVC, vertexs_service, I2O, service_internal, abandon_original, c101);

toc