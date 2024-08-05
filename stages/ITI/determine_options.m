function curr_opt = determine_options(game_opt)

    %% determin options for current trial
    % Each trial, the computer poses a math problem.
    %   Computer randomly selects either {addition, subtraction}
    %   Computer randomly selectsa number from {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
    %   Computer randomly selects either {prefix format, reverse polish (postfix)}
    %   Computer randomly selects 3 locations on the monitor (out of 12, in a 3x4 grid)
    
    %% 1. Operation
    curr_oper_type = game_opt.oper_type{randi(game_opt.num_oper, 1)}; % {'+', '-'}
    
    %% 2. Determine numbers
    curr_nums=randi([game_opt.min_num game_opt.max_num], game_opt.num_samples, 1);
    curr_opt.curr_nums = curr_nums;
%     disp(curr_nums); % debug
    
    % correct answer
    switch curr_oper_type
        case '+'
            curr_opt.target_num = sum(curr_nums);
        case '-'
            curr_opt.target_num = -diff(curr_nums);
    end
    curr_opt.curr_oper_type=curr_oper_type;
%     disp(curr_oper_type); % debug
%     disp(['task is: ' num2str(curr_nums(:)') ' ' curr_oper_type]); % debug
    
    %% 3. presentation (notation)
    operand_pos = randi(game_opt.num_pres, 1);
    curr_pres_type = game_opt.pres_type{operand_pos};
    
    %% 4. formats 
    curr_opt.curr_format = game_opt.format{randi(game_opt.num_format,1)};

    %% 5. Determine the presentation location.
    % select positions for all numbers and operation
    id_location = randperm(game_opt.n_grid,game_opt.num_samples+1); % linear index: e.g., 9 1 3
    grid_size = [game_opt.n_grid_y game_opt.n_grid_x]; % note vertical(row) for y, horizontal(column) for x
    [curr_opt.pos_y_idx,curr_opt.pos_x_idx]=ind2sub(grid_size,id_location);
    
    %% 5. Finalize the presentation options
    switch curr_pres_type
        case 'infix'
            curr_opt.strs = {num2str(curr_nums(1)), curr_oper_type, num2str(curr_nums(2))};
        case 'prefix'
            curr_opt.strs = {curr_oper_type, num2str(curr_nums(1)), num2str(curr_nums(2))};
        case 'rev_pol' % same as postfix
            curr_opt.strs = {num2str(curr_nums(1)), num2str(curr_nums(2)), curr_oper_type};
        case 'postfix'
            curr_opt.strs = {num2str(curr_nums(1)), num2str(curr_nums(2)), curr_oper_type};
    end
    
    switch curr_opt.curr_format
        case 'arabic'
            curr_opt.symbol=true(game_opt.num_samples+1,1);
            disp(['task is: ' cell2mat(curr_opt.strs)]); % debug
        case 'dot'
            % generate dot here during ITI to save resource
            number_range = [game_opt.min_num game_opt.max_num];
            curr_opt.dot(1)=generate_dots(curr_nums(1),number_range,game_opt.radius_range,game_opt.field_range); % structure has x y z for each dot
            curr_opt.dot(2)=generate_dots(curr_nums(2),number_range,game_opt.radius_range,game_opt.field_range);

            switch curr_pres_type
                case 'infix'
                    curr_opt.strs = {curr_opt.dot(1), curr_oper_type, curr_opt.dot(2)};
                    curr_opt.symbol = [false, true,false];
                case 'prefix'
                    curr_opt.strs = {curr_oper_type, curr_opt.dot(1),curr_opt.dot(2)};
                    curr_opt.symbol = [true, false, false];
                case 'rev_pol' % same as postfix
                    curr_opt.strs = {curr_opt.dot(1), curr_opt.dot(2), curr_oper_type};
                    curr_opt.symbol = [false, false, true];
                case 'postfix'
                    curr_opt.strs = {curr_opt.dot(1), curr_opt.dot(2), curr_oper_type};
                    curr_opt.symbol = [false, false, true];
            end
    end

%     disp([curr_oper_type curr_nums_str(:)']); % debug

end