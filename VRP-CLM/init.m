
%% 初始化路径:随机遍历插值法 
%输入cusnum   顾客数量 1-100
%输入a        左时间窗 [a,b]，最早允许开始服务时间
%输入demands  每个顾客的需求量
%输入cap      车辆最大载货量
function [init_vc] = init(cusnum,a,demands,cap,customer_type)
j=ceil(rand*cusnum);                    %ceil为向上取整；从所有顾客中随机选择一个顾客，rand生成从0到1之间的均匀分布的随机数
k=1;                                    %使用车辆数目，初始设置为1
init_vc=cell(k,1);                     
% 按照如下序列，遍历每个顾客，并执行以下步骤
if j==1
    seq=1:cusnum;
elseif j==cusnum
    seq=[cusnum,1:j-1];
else
    seq1=1:j-1;
    seq2=j:cusnum;
    seq=[seq2,seq1];
end
% 开始遍历
route=[];       %存储每条路径上的顾客
load=0;         %初始路径上在仓库的装载量为0
i=1;
while i<=cusnum
    %如果没有超过容量约束，则按照左时间窗大小，将顾客添加到当前路径
    if load+demands(seq(i))<=cap         
        load=load+demands(seq(i));          %初始在仓库的装载量增加
        %如果当前路径为空，直接将顾客添加到路径中
        if isempty(route)
            route=[seq(i)];
               elseif length(route)==1        %如果当前路径只有一个顾客，再添加新顾客时，需要根据左时间窗大小进行添加
            if a(seq(i))<=a(route(1))  %判断新顾客seq(i)的左时间窗开始时间是否小于或等于当前路径中第一个顾客的左时间窗开始时间route(1)
                route=[seq(i),route];  %将新顾客添加到路径的开头;新顾客就成为了路径上的第一个顾客 
            else
                route=[route,seq(i)];
            end
        else
            lr=length(route);       %当前路径长度,则有lr-1对连续的顾客
            flag=0;                 %标记是否存在这样1对顾客，能让seq(i)插入两者之间
            %遍历这lr-1对连续的顾客的中间插入位置
            for m=1:lr-1
                % 如何在当前路径中找到合适的位置来插入一个新的顾客，同时确保顾客的时间窗约束得到满足。这里的代码片段专注于在路径中找到一对顾客，使得新顾客可以被插入到这对顾客之间，而不违反任何时间窗的约束
                if (a(seq(i))>=a(route(m)))&&(a(seq(i))<=a(route(m+1))) %判断语句检查当前待插入的顾客seq(i)的左时间窗开始时间是否在路径中第m个顾客和第m+1个顾客的左时间窗之间;&&逻辑与，用时为真
                    route=[route(1:m),seq(i),route(m+1:end)]; %如果上述条件成立，这行代码将执行顾客的插入操作。
                    flag=1;
                    break
                end
            end
            %如果不存在这样1对顾客，能让seq(i)插入两者之间，也就是flag=0，则需要将seq(i)插到route末尾
            if flag==0
                route=[route,seq(i)];
            end
        end
        %如果遍历到最后一个顾客，则更新init_vc，并跳出程序
        if i==cusnum
            init_vc{k,1}=route;
            break
        end
        i=i+1;
    else   %一旦超过车辆载货量约束，则需要增加一辆车
        %先储存上一辆车所经过的顾客
        init_vc{k,1}=route;
        %然后将route清空，load清零,k加1
        route=[];
        load=0;
        k=k+1;
    end
end
end

