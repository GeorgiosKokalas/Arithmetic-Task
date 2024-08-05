function present_ITI(visual_opt)

stage_idx = 0; % current stage ITI
phd_duration =visual_opt.photoD_duration{stage_idx+1};

% photodiode on
present_photodiode(visual_opt,phd_duration)