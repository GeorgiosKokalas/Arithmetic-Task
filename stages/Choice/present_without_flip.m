function present_without_flip(visual_opt, curr_str, curr_pos, phd_on,varargin)

    % specificy color
    if isempty(varargin)
        textcolor = visual_opt.white;
    else
        textcolor = varargin{1};
    end

    %% 0. Set time and text
    num2disp = curr_str;
    
    %% 1. Draw and present
    Screen('TextSize', visual_opt.window, visual_opt.textSize);
    Screen('TextColor', visual_opt.window, textcolor);
    Screen('TextStyle', visual_opt.window, visual_opt.textStyle);
    DrawFormattedText(visual_opt.window, num2disp, ...
        curr_pos(1), curr_pos(2), textcolor);
    
    % photodiode
    if phd_on
        draw_photoD(visual_opt);
    end
    
end