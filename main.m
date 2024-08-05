function main()
	
    %%	Number Cognition TASK CODE.
    % Each trial, the computer poses a math problem.
    %   Computer randomly selects either {addition, subtraction}
    %   Computer randomly selectsa number from {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
    %   Computer randomly selects either {prefix format, reverse polish (postfix)}
    %   Computer randomly selects 3 locations on the monitor (out of 12, in a 3x4 grid)
    
    % Temporal information 
    % 750ms for each cue (1st/2nd operand, operation): stim_present in set_game.m
    %   Patient can type the number into the keyboard, and press enter/space to get either
    %   “correct” or “incorrect” feedback (500ms), ITI of 500 ms
    
    %% TODO
    % for George
    %  1. blackrock strobe / event-msg?
    %  2. Connect eye-tracker
    
    %% notes for discussion
    %     1. Should we turn off stimulus later in each period (750ms) to avoid stimulus-driven response and focus on mental aspect?
    %     2. Should we try RT version of the task? ie. let subjects respond asap after last query. Pros and cons?
    %     3. removing each cue after its presentation makes subjects to rely memorization/verbal straetegy?
    
%%
    clear all; close all; clc;
    set_default_paths();
    ID = 'test';
    %[EMUnum,ID] = getNextLogEntry(); % not exist
    %saveFileName = sprintf('EMU-%0.4d_subj-%s_Arithmetic-Task', EMUnum, ID);
    %TaskComment('start', saveFileName);

    %% Initialize
    % autoclear(); % not exist
    verbose = false; % true; % false; % Mostly for debugging
    [visual_opt,device_opt, game_opt, path_opt] = stage_initialize(ID);
    
    %% Task starts
    if verbose
        session_onset=true;
    else
        disp('Right Arrow to start | Escape to Exit');
        [session_onset, times.key_press_t] = ...
            start_session(visual_opt, device_opt, game_opt);
    end
    
    %% Main while loop running controlling the experiment
    stage_idx = 0;
    times.exp_start_t = GetSecs();
    save_duration=0;
    while(session_onset)
        switch stage_idx
            
            case -1 
                %% Saving stage (Part 1 of ITI)
                times.save_start_t = GetSecs();
                present_ITI(visual_opt); % only photodiode
                stage_idx = save_data(curr_opt, keyProfile, times, ID, path_opt,device_opt);
                save_duration = GetSecs()-times.save_start_t; % saving time
                
            case 0 
                %% Preparing next trials (Part 2 of ITI)
                times.ITI_start_t = GetSecs();
                
                % Add number of trials.
                path_opt.curr_trial	= path_opt.curr_trial + 1;
                if path_opt.curr_trial > game_opt.sess_trs
                    stage_idx = 21; % Session ends
                end
                disp('--------------------------------');
                fprintf( 'Trial: %4.0d \n', path_opt.curr_trial);
    
                % Preparing next trials
                [curr_opt, stage_idx] = stage_ITI(game_opt);
    
                % Time control.
                align_time(times.ITI_start_t, ...
                    game_opt.ITI_duration-save_duration, ...
                    game_opt.t_resolution)
                times.ITI_end_t = GetSecs();
                times.ITI_len = times.ITI_end_t-times.ITI_start_t;
    
                if verbose
                    if times.ITI_len > game_opt.ITI_duration + visual_opt.refresh_rate
                        fprintf( 'ITI time: %4.2d \n', times.ITI_len);
                    end
                end
                
            case 1 
                %% Presentation step
                times.present_start_t = GetSecs();
                stage_idx = stage_present(visual_opt, game_opt, curr_opt);
    
                % Time control.
                times.present_end_t = GetSecs();
                times.present_len = times.present_end_t - times.present_start_t;
    
                if verbose
                    if times.present_len > game_opt.stim_present_total + visual_opt.refresh_rate
                        fprintf( 'presentation time: %4.2d \n', times.present_len);
                    end
                end
            
            case 2 
                %% Choice step
                times.choice_start_t = GetSecs();
                [times.RT, keyProfile, stage_idx] = stage_choice(...
                    visual_opt, game_opt, device_opt, curr_opt);
                times.choice_end_t = GetSecs();
                
            case 3
                %% feedback
                times.feedback_start_t = GetSecs();
                [curr_opt, game_opt, stage_idx] = stage_feedback(...
                    visual_opt, game_opt, device_opt, curr_opt,keyProfile);
                times.feedback_end_t = GetSecs();
                
            case 21 
                %% Either abort or end
                times.exp_end_t = GetSecs( );
                if strcmp(keyProfile.names(end), device_opt.abort)
                    end_str = 'Trials aborted!';
                else
                    end_str = 'Thank you!';
                end
                displayText(visual_opt.window, end_str, ...
                    [visual_opt.xCenter, visual_opt.yCenter], ...
                    visual_opt.white);
                times.exp_dur = exp_end_t - exp_start_t;
                fprintf( 'experiment duration: %4.2d \n', times.exp_dur);
                disp( '------------------------' );
                session_onset = false; %#ok<NASGU>
                break;
        end
    end

    TaskComment('stop', saveFileName);
    
    %% Clear the screen and reset
	sca;
	Priority(0);
end


%% change log
% Hansem @ 2024/7/30
%     - dot size adaptable for 80-inch screen: game_opt.radius_range
%     - to code for task stages in photodiode, decrement duration of photodiode stimulus across task stages
%     - now show number as subjects press and give target number as feedback (color: green if error is within a +/-3 range, red otherwise)

% Hansem @ 2024/8/1
%    - photodiode timing checked
%    - separate feedback staircases for dot/arabic
%    - update save_data.m

% Hansem @ 2024/8/5
%     - no dot (separate numerosity estimation task - 10minutes; [1 15]);
%     - number sampling [0 15] with no constraint
%           with 30min limit for patients and 5 sec/trial, we got 360 trials.
%           With 2 notations (post/pre-fix) x 2 operations (+/-), we can have
%           90 trials across different numbers. 