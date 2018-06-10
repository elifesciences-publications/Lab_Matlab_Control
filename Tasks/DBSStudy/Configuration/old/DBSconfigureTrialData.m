function trialData = DBSconfigureTrialData()
% function trialData = DBSconfigureTrialData()
%
% Define standard trialData structure for use with both
%  topsTreeNodeTaskRTDots and topsTreeNodeTaskSaccade
%  task classes
%
% Created 6/7/18 by jig

% Standard trialData structure
trialData = struct( ...
      'taskID', nan, ...
      'trialIndex', nan, ...
      'direction', nan, ...
      'coherence', nan, ...
      'choice', -3, ...
      'RT', nan, ...
      'correct', -3, ...
      'time_screen_roundTrip', 0, ...
      'time_local_trialStart', nan, ...
      'time_ui_trialStart', nan, ...
      'time_screen_trialStart', nan, ...
      'time_TTLStart', nan, ...
      'time_TTLFinish', nan, ...
      'time_fixOn', nan, ...
      'time_targsOn', nan, ...
      'time_dotsOn', nan, ...
      'time_targsOff', nan, ...
      'time_fixOff', nan, ...
      'time_choice', nan, ...
      'time_dotsOff', nan, ...
      'time_fdbkOn', nan, ...
      'time_local_trialFinish', nan, ...
      'time_ui_trialFinish', nan, ...
      'time_screen_trialFinish', nan);
         