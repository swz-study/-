clc;clear;
close all;
%***********************
Event_queue= [];%事件队列
N=6;%楼层数
student_num = 20*N;
queue = zeros(N,20);
elevator_loc = 1;%电梯所在楼层
elevator_num_threshold = 10;%电梯人数上限
num_in_elevator = 0;%在电梯中的人数
time_every_floor = 0.0004388; %2.1361/3600s
elevator_dst = 0;
queue_in_elevator = [];
elevator_door = 0;%电梯门的状态

wakeup_time=normrnd(7.633,0.7822,1,student_num);
wash_time=normrnd(0.17689,0.00235,1,student_num);
t=wakeup_time+wash_time;
time=sort(t);

for t=1:student_num
    s(t)=student;
    s(t).id = t;
    s(t).StartTime = time(t);
    s(t).floor = unidrnd(N); %floor=1 2 3 4 5 6 7 8 9
    s(t).left_elevator = 0;%离开电梯时间
    if s(t).floor == 1
        s(t).left_elevator = s(t).StartTime;
    else
        Event_queue = insert_Event_queue(Event_queue, s(t).StartTime, 1,s(t).id);
    end
end
t_floor = []; %打印生成同学对应的楼层
for i = 1:student_num
    t_floor = [t_floor s(i).floor];
end
t_floor;
t_start=[]; %打印生成同学进入电梯系统对应的开始时间
for i =1:student_num
    t_start = [t_start s(i).StartTime];
end
t_start;

t=0;
mid = 0;
while(~isempty(Event_queue))

        
    [t,type,id,Event_queue]=pop_Event_queue(Event_queue);
%**********************************************************************************************
    if type == -1 %电梯关门
        elevator_door = 0;
        if elevator_loc == 1 
            for i = N:-1:1
                if queue(i,1) ~= 0
                    elevator_dst = i;
                    break;
                end
            end
            if i == 1
                elevator_dst = 0;
            else
                Event_queue = insert_Event_queue(Event_queue,t+time_every_floor*(elevator_dst-1), 0, elevator_dst);
            end
        else
            time_arrive_next_floor = t + time_every_floor;%去下一层
            Event_queue = insert_Event_queue(Event_queue,time_arrive_next_floor, 0, elevator_loc-1);%insert change event
        end
%**********************************************************************************************         
    elseif type == 0 %电梯运行
       elevator_loc = id;%电梯楼层
       elevator_door = 1;
       if elevator_loc == 1%出电梯
           while(num_in_elevator ~= 0)
               temp_id = queue_in_elevator(1);
               s(temp_id).left_elevator = t;%记录下时间
               queue_in_elevator = queue_in_elevator(2:length(queue_in_elevator));
               num_in_elevator = num_in_elevator - 1;
           end
%            queue_in_elevator = [];
           elevator_dst = 0;
           time_elevator_close = t + (10 + 50 * rand())/3600;
           Event_queue = insert_Event_queue(Event_queue,time_elevator_close, -1, elevator_loc);%insert close event
       elseif elevator_loc == elevator_dst
           elevator_dst = 1;
           time_elevator_close = t + (10 + 50 * rand())/3600;
           Event_queue = insert_Event_queue(Event_queue,time_elevator_close, -1, elevator_loc);%insert close event
           if queue(elevator_loc,1) ~= 0
               [queue, pop_id] = pop_queue(queue,elevator_loc,elevator_num_threshold-num_in_elevator);
                while(~isempty(pop_id))
                    temp_id = pop_id(1);
                    queue_in_elevator = [queue_in_elevator temp_id];%ID放入电梯里
                    num_in_elevator = num_in_elevator + 1;
                    pop_id = pop_id(2:length(pop_id));
                end
           end
       elseif elevator_dst == 1 
           if queue(elevator_loc,1) ~= 0 && num_in_elevator < elevator_num_threshold%判断是否有人
               [queue, pop_id] = pop_queue(queue,elevator_loc,elevator_num_threshold-num_in_elevator);
                while(~isempty(pop_id))%挨层判断
                    temp_id = pop_id(1);
                    queue_in_elevator = [queue_in_elevator temp_id];
                    num_in_elevator = num_in_elevator + 1;
                    pop_id = pop_id(2:length(pop_id));
                end
                time_elevator_close = t + (10 + 50 * rand())/3600;
                Event_queue = insert_Event_queue(Event_queue,time_elevator_close, -1, elevator_loc);%insert close event
           else
                Event_queue = insert_Event_queue(Event_queue,t+time_every_floor, 0, elevator_loc-1);%insert change event
           end
      end
 %**********************************************************************************************   
    elseif type == 1% 电梯
        if elevator_loc == s(id).floor && elevator_door == 1%刚好电梯在并且门开
                queue_in_elevator = [queue_in_elevator id];
                num_in_elevator = num_in_elevator + 1;
        elseif queue(s(id).floor,1) == 0 %判断当前楼层队列是否为空
            temp_num_in_queue = queue(s(id).floor,1);%这一楼层的人数
            queue(s(id).floor,temp_num_in_queue+2) = id;
            queue(s(id).floor,1) = queue(s(id).floor,1) + 1;
            if elevator_loc == 1 && elevator_dst == 0 %刚开始的时候，电梯在一层
                for i = N:-1:1
                    if queue(i,1) ~= 0
                        elevator_dst = i;
                        break;
                    end
                end
                Event_queue = insert_Event_queue(Event_queue,t+time_every_floor*(elevator_dst-1), 0, elevator_dst);%把id换成了楼层
            end
        else %else, join the queue
            temp_num_in_queue = queue(s(id).floor,1);
            queue(s(id).floor,temp_num_in_queue+2) = id;
            queue(s(id).floor,1) = queue(s(id).floor,1) + 1;
        end
    end

end
% 结果图形可视化
t_cost=[];
t_left=[];
for i =1:student_num
        t_cost = [t_cost (s(i).left_elevator-s(i).StartTime)*3600];
end
for i =1:student_num
    t_left = [t_left s(i).left_elevator];
end

x=(1:student_num);
figure
plot(x,t_cost,'LineWidth',1.5);
xlabel('ID');
ylabel('耗费时长(单位：秒)');
grid on;

%结果值输出
fprintf('楼层数: %d  学生总数：%d\n',N,student_num);
fprintf('-----------------------------------------------------------\n')
t_start_hour=floor(t_start);
t_start_middle = (t_start-floor(t_start))*60;
t_start_min=floor(t_start_middle);
t_start_second=(t_start_middle-floor(t_start_middle))*60;

t_left_hour=floor(t_left);
t_left_middle = (t_left-floor(t_left))*60;
t_left_min=floor(t_left_middle);
t_left_second=(t_left_middle-floor(t_left_middle))*60;

for k=1:student_num
       fprintf('ID号为 %d 的学生在第 %d 层出发的时间为 %d:%d:%0.1f,离开时间为 %d:%d:%0.1f,耗时%0.1fs\n',s(k).id,s(k).floor,t_start_hour(k),t_start_min(k),t_start_second(k),t_left_hour(k),t_left_min(k),t_left_second(k),t_cost(k));
end
fprintf('-----------------------------------------------------------\n')
fprintf('学生乘坐电梯平均消耗时长= %f 秒\n',mean(t_cost));
