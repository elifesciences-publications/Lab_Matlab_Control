function eventName = RTDgetAndSaveNextEvent(datatub, acceptedEvents, eventTag)
% function eventName = RTDgetAndSaveNextEvent(datatub, acceptedEvents, eventTag)
% 
% RTD = Response-Time Dots
%
% call dotsReadable.getNext event and save the data
%
% Arguments:
%  
%  datatub        ... tub o' data
%  acceptedEvents ... cell array of strings acceptedEvents to list names of
%                       events that can be used
%  eventTag       ... string used to store timing information in trial struct

% Created 5/11/18 by jig

%% ---- Call dotsReadable.getNext
%
% data has the form [ID, value, time]
[name, data] = getNextEvent(datatub{'Control'}{'ui'}, [], acceptedEvents);

if isempty(name)
   
   % Return blank string
   eventName = '';
else

   % Return the event name 
   eventName = name;
   
   % Store the timing data
    task = datatub{'Control'}{'currentTask'};
    task.nodeData.trialData(task.nodeData.currentTrial).(sprintf('time_%s', eventTag)) = ...
        data(3);
end

