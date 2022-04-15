function [ queue, pop_id ] = pop_queue( queue, index ,num_to_pop )
    pop_id = [];
    num_pop = 0;
    if queue(index,1) <= num_to_pop %想取出的学生数少于当前层排队人数
        num_pop = queue(index,1); %排队的人都取出
        for i = 2:(num_pop+1)
            pop_id = [pop_id queue(index,i)];
            if queue(index,i) == 0
                bb = 1;
            end
        end
        queue(index,:) = 0;
    else %想取出的学生数多于当前层排队人数
        num_pop = num_to_pop;
        queue(index,1) = queue(index,1) - num_pop;
        for i = 2:(num_pop +1)
            pop_id = [pop_id queue(index,i)];
            if queue(index,i) == 0
                bb = 1;
            end
            queue(index,i) = 0; %将被取出的学生 位置处 置0
        end
        for i = 2:(queue(index,1)+1)
            queue(index,i) = queue(index,i+num_pop); %将后面没被取出的同学 排队前移
            queue(index,i+num_pop) = 0; %被前移的学生位置处 置0
        end
        
    end
end
