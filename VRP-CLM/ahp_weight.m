%% ==================== AHP相关函数 ====================

%% AHP层次分析法计算主观权重
function [weights, CR] = ahp_weight(judgment_matrix)
    %% 层次分析法（AHP）计算主观权重
    % 输入：
    %   judgment_matrix - 判断矩阵（方阵）
    % 输出：
    %   weights - 权重向量
    %   CR - 一致性比例（CR < 0.1 表示通过一致性检验）
    
    % 1. 计算判断矩阵的阶数
    n = size(judgment_matrix, 1);
    
    % 2. 计算最大特征值和特征向量
    [V, D] = eig(judgment_matrix);
    lambda_max = max(diag(D));
    
    % 3. 计算权重（归一化特征向量）
    [~, idx] = max(diag(D));
    weights = abs(V(:, idx)) / sum(abs(V(:, idx)));
    weights = weights';
    
    % 4. 计算一致性指标 CI
    CI = (lambda_max - n) / (n - 1);
    
    % 5. 随机一致性指标 RI（n=1-10）
    RI_table = [0, 0, 0.58, 0.90, 1.12, 1.24, 1.32, 1.41, 1.45, 1.49];
    if n <= 10
        RI = RI_table(n);
    else
        RI = RI_table(10);
    end
    
    % 6. 计算一致性比例 CR
    CR = CI / RI;
    
    % 7. 输出结果
    fprintf('\n==================== AHP层次分析法 ====================\n');
    fprintf('判断矩阵阶数: %d\n', n);
    fprintf('最大特征值 λ_max = %.4f\n', lambda_max);
    fprintf('一致性指标 CI = %.4f\n', CI);
    fprintf('随机一致性指标 RI = %.4f\n', RI);
    fprintf('一致性比例 CR = %.4f\n', CR);
    
    if CR < 0.1
        fprintf('✓ 一致性检验通过 (CR < 0.1)\n');
    else
        fprintf('✗ 一致性检验未通过 (CR >= 0.1)，请调整判断矩阵\n');
    end
    
    fprintf('主观权重: [');
    fprintf('%.4f, ', weights(1:end-1));
    fprintf('%.4f]\n', weights(end));
    fprintf('========================================================\n\n');
end

