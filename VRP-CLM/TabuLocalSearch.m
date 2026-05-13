% 修正后的TabuLocalSearch函数（核心部分）
function [SelCh,tabuList,tabuCount]=TabuLocalSearch(SelCh,cusnum,cap,demands,a,b,L,s,dist,alpha,X1,X2,customer_type,speed,tabuList,tabuCount,tabuLength,neighborNum,tabuProb,v_num)
    [nInd,nVar]=size(SelCh);
    for i=1:nInd
        % 随机触发禁忌搜索
        if rand()>tabuProb
            continue;
        end
        % 原始解解码与评估
        originalChrom=SelCh(i,:);
        [~,~,~,~,originalCost,~,~,~,~,~,~,~,~,~]=decode(originalChrom,cusnum,cap,demands,a,b,L,s,dist,alpha,X1,X2,customer_type,speed);
        bestNeighborCost=originalCost;
        bestNeighborChrom=originalChrom;
        
        % 生成邻域解（修正客户索引计算）
        for n=1:neighborNum
            % 随机选择1个客户移除（修正：客户在染色体中的位置为1~cusnum）
            cusIdx=randi(cusnum); % 直接生成1~cusnum的随机整数，对应客户在染色体中的位置
            tempChrom=originalChrom;
            removedCus=tempChrom(cusIdx); % 提取要移除的客户编号
            % 移除客户后重新整理染色体（保留车辆分隔符逻辑）
            % 步骤1：分离客户和车辆分隔符
            customerPart=tempChrom(1:cusnum); % 前cusnum位是客户
            separatorPart=tempChrom(cusnum+1:end); % 后面是车辆分隔符
            % 步骤2：移除目标客户
            customerPart(cusIdx)=[];
            % 步骤3：重新组合染色体（客户+车辆分隔符）
            tempChrom=[customerPart, separatorPart];
            % 步骤4：重插客户到最优位置（综合距离和路径相关性）
            insertPos=randi(length(customerPart)+1); % 在客户部分选择插入位置
            customerPart=[customerPart(1:insertPos-1), removedCus, customerPart(insertPos:end)];
            % 步骤5：重新生成完整染色体
            tempChrom=[customerPart, separatorPart];
            
            % 检查邻域解是否在禁忌表中
            isTabu=false;
            for t=1:tabuCount
                if isequal(tempChrom,tabuList{t})
                    isTabu=true;
                    break;
                end
            end
            if isTabu
                continue;
            end
            
            % 评估邻域解
            [~,~,~,~,neighborCost,~,~,~,~,~,~,~,~,~]=decode(tempChrom,cusnum,cap,demands,a,b,L,s,dist,alpha,X1,X2,customer_type,speed);
            % 保留最优邻域解
            if neighborCost<bestNeighborCost
                bestNeighborCost=neighborCost;
                bestNeighborChrom=tempChrom;
            end
        end
        
        % 更新当前解并加入禁忌表
        if bestNeighborCost<originalCost
            SelCh(i,:)=bestNeighborChrom;
            % 更新禁忌表（先进先出）
            tabuCount=tabuCount+1;
            if tabuCount>tabuLength
                tabuList(1:tabuLength-1)=tabuList(2:tabuLength);
                tabuCount=tabuLength;
            end
            tabuList{tabuCount}=bestNeighborChrom;
        end
    end
end