% Checks the inputs of main to adjust the program
function [expEnv, ID] = check_inputs(Args)
    % Assign default values
    expEnv = 'None';
    ID = 'test';

    % If user needs help, print it and exit out of scripts
    if length(Args) == 1 && strcmpi(Args{1}, 'help')
        file = fopen("main_help.txt");
        fprintf("%s\n", fread(file));
        fclose(file);
        error("End of message");
    end

    % Otherwise check that the number of inputs is appropriate
    if round(length(Args)/2) ~= length(Args)/2
        error_msg = "There was an incorrect amount of variables entered.";
        error_msg = sprintf("%s\nUse main('help') to see appropriate use.", error_msg);
        error(error_msg);
    end

    % Loop over every parameter given
    argCnt = 1;
    while argCnt < length(Args)
        curVar = lower(char(Args{argCnt}));
        curVal = lower(char(Args{argCnt + 1}));
        switch curVar
            case 'env'   % Check the experimental environment in which we will test the 
                switch curVal
                    case 'emu'
                        expEnv = 'emu';
                    case 'none'
                        expEnv = 'None';
                    otherwise
                        error("Wrong value for env entered")
                end
            case 'id'    % Check the id that should be provided for the participant
                ID = curVal;
            otherwise
                error(sprintf("Parameter %s not recognized. Use main('help') for further info.", curVar));
        end
        argCnt = argCnt + 2;
    end

    input_msg = "Here are your selected parameters:\n";
    input_msg = sprintf("%sExpEnv: %s\n", input_msg, expEnv);
    input_msg = sprintf("%sID: %s\n", input_msg, ID);
    
    input_msg = sprintf("%s\nPress Enter to continue or Ctr + C to stop.", input_msg);
    input(input_msg);
end