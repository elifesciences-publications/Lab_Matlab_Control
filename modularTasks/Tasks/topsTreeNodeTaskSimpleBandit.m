classdef topsTreeNodeTaskSimpleBandit < topsTreeNodeTask
   % @class topsTreeNodeTaskSimpleBandit
   %
   % Simple two-armed bandit task with block-wise changes in reward
   %  probabilities.
   %
   % For standard configurations, call:
   %  topsTreeNodeTaskSimpleBandit.getStandardConfiguration
   %
   % Otherwise:
   %  1. Create an instance directly:
   %        task = topsTreeNodeTaskSimpleBandit();
   %
   %  2. Set properties. These are required:
   %        task.drawables.screenEnsemble
   %        task.helpers.readers.theObject
   %     Others can use defaults
   %
   %  3. Add this as a child to another topsTreeNode
   %
   % 5/18/19 created by jig
   
   properties % (SetObservable) % uncomment if adding listeners
      
      % Trial properties, put in a struct for convenience
      settings = struct( ...
         'changeInterval',             [10 14], ... % min/max
         'targetDistance',             8);
      
      % Task timing parameters, all in sec
      timing = struct( ...
         'choiceTimeout',              5.0, ...
         'pauseAfterChoice',           0.2, ...
         'showFeedback',               1.0, ...
         'interTrialInterval',         1.5);
      
      % Fields below are optional but if found with the given names
      %  will be used to automatically configure the task
      
      % independentVariables used by topsTreeNodeTask.makeTrials. Can
      % modify using setIndependentVariableByName and
      % setIndependentVariablesByName.
      %
      % Creates the array of trialData structures, using:
      %  name     ... list of independent variables
      %  values   ... array of values associated with each independent
      %                    variable
      %  priors   ... empty, or relative frequencies of each value for each
      %                    independent variable (automatically normalizes
      %                    to sum to 1).
      %
      %  Also uses:
      %     trialIterations property to determine the number
      %              of copies of each trial type to use
      %     trialIterationMethod property to determine the 
      %              ordering of the trials (in trialIndices)
      independentVariables = struct( ...
         'name',                       {'probabilityLeft'},       ...
         'values',                     {[0.10 0.35 0.65 0.90]},   ...
         'priors',                     {[]});
      
      % dataFieldNames is a cell array of string names used as trialData fields
      trialDataFields = {'choice', 'rewarded', 'RT', 'stimOn', 'choiceTime', ...
         'feedbackOn', 'totalCorrect', 'totalChoices', 'trialsAfterSwitch', };
      
      % Drawables settings
      drawable = struct( ...
         ...
         ...   % The main stimulus ensemble
         'stimulusEnsemble',           struct(  ...
         ...
         ...   % Left card
         'leftCard',                   struct(  ...
         'fevalable',                  @dotsDrawableImages, ...
         'settings',                   struct( ...
         'fileNames',                  {{'cardBlue.jpg'}}, ...
         'height',                     15)), ...
         ...
         ...   % Right card
         'rightCard',                  struct(  ...
         'fevalable',                  @dotsDrawableImages, ...
         'settings',                   struct( ...
         'fileNames',                  {{'cardRed.jpg'}}, ...
         'height',                     15))));
      
      % Playable settings
      playable = struct( ...
         ...
         ... % Args are frequency (Hz), time (sec), scale factor
         ... % Note that calling makeTone calls prepareToPlay automatically,
         ... %    otherwise that should be called explicitly before each trial
         'fixOffTone',                 struct( ...
         'fevalable',                  {{@dotsPlayableTone.makeTone, [1000 0.05 1]}}));
      %         'fevalable',                  {{@dotsPlayableFastTone.makeTone, [1000 0.05 1]}}));
      
      % Readable settings
      readable = struct( ...
         ...
         ...   % The readable object
         'reader',                     struct( ...
         ...
         'copySpecs',                  struct( ...
         ...
         ...   % Keyboard events
         'dotsReadableHIDKeyboard',    struct( ...
         'start',                      {{@defineEventsFromStruct, struct( ...
         'name',                       {'choseLeft', 'choseRight'}, ...
         'component',                  {'KeyboardF', 'KeyboardJ'})}}), ...
         ...
         ...   % Gamepad
         'dotsReadableHIDGamepad',   	struct( ...
         'start',                      {{@defineEventsFromStruct, struct( ...
         'name',                       {'choseLeft', 'choseRight'}, ...
         'component',                  {'Trigger1', 'trigger2'})}}), ...
         ...
         ...    % Ashwin's magic buttons
         'dotsReadableHIDButtons',     struct( ...
         'start',                      {{@defineEventsFromStruct, struct( ...
         'name',                       {'choseLeft', 'choseRight'}, ...
         'component',                  {'KeyboardLeftShift', 'KeyboardRightShift'})}}), ...
         ...
         ...   % Dummy to run in demo mode
         'dotsReadableDummy',          struct( ...
         'start',                      {{@defineEventsFromStruct, struct( ...
         'name',                       {'choseLeft', 'choseRight'}, ...
         'component',                  {'auto_1', 'auto_2'})}}))));
      
      % Feedback messages
      message = struct( ...
         ...
         'groups',                     struct( ...
         ...
         ...   Instructions
         'Instructions',               struct( ...
         'text',                       {'Choose the currently rewarded card'}, ...
         'duration',                   1.0, ...
         'pauseDuration',              0.5, ...
         'bgEnd',                      [0 0 0]), ...
         ...
         ...   Correct
         'Correct',                    struct(  ...
         'text',                       'Good choice', ...
         'playable',                   'cashRegister.wav', ...
         'bgStart',                    [0 0.6 0], ...
         'bgEnd',                      [0 0 0]), ...
         ...
         ...   Error
         'Error',                      struct(  ...
         'text',                       'Bad choice', ...
         'playable',                   'buzzer.wav', ...
         'bgStart',                    [0.6 0 0], ...
         'bgEnd',                      [0 0 0]), ...
         ...
         ...   No choice
         'No_choice',                  struct(  ...
         'text',                       'No choice - please try again!')));
   end
   
   methods
      
      %% Constuct with name optional.
      % @param name optional name for this object
      % @details
      % If @a name is provided, assigns @a name to this object.
      function self = topsTreeNodeTaskSimpleBandit(varargin)
         
         % ---- Make it from the superclass
         %
         self = self@topsTreeNodeTask(varargin{:});
      end
      
      %% Start task method
      function startTask(self)
         
         % ---- Initialize the state machine
         %
         self.initializeStateMachine();
         
         % ---- Show task-specific instructions
         %
         self.helpers.message.show('Instructions');
      end
      
      %% Overloaded finish task method
      function finishTask(self)
      end
      
      %% Overloaded start trial method
      %
      % Put stuff here that you want to do at the beginning of each
      %  trial
      function startTrial(self)
         
         % ---- Prepare components
         %
         self.prepareDrawables();
         self.prepareReadables();
         
         % ---- Get the trial
         %
         trial = self.getTrial();
         
         %---- Set up trial struct
         %
         % Initialize
         if ~isfinite(trial.trialsAfterSwitch)
            
            % We iterate through each "trial" several times, so at the
            % beginning we need to reset these counters
            trial.trialsAfterSwitch = 0;
            trial.totalCorrect = 0;
            trial.totalChoices = 0;
            
            % Here we can also check/modify the trial order.
            % Make sure very first condition is easy
            if self.trialCount==1
               vals = [self.trialData(self.trialIndices).probabilityLeft];
               if randi(2) == 1
                  mi = find(vals==max(vals), 1);
               else
                  mi = find(vals==min(vals), 1);
               end
               if mi ~= 1
                  tmpi = self.trialIndices(mi);
                  self.trialIndices(mi) = self.trialIndices(1);
                  self.trialIndices(1)  = tmpi;
               end
            end
         end
         
         % Clear the fields that get saved per trial
         for ii = 1:length(self.trialDataFields)-3
            trial.(self.trialDataFields{ii}) = nan;
         end
         
         % Re-save the trial
         self.setTrial(trial);
         
         % ---- Show information about the trial
         %
         % Task information
         taskString = sprintf('%s (task %d/%d)', self.name, ...
            self.taskID, length(self.caller.children));
         
         % Trial information
         trialString = sprintf('Trial %d(%d)/%d: Rews=[%.0f %.0f], Correct=%d/%d', ...
            self.trialCount, trial.trialsAfterSwitch+1, numel(self.trialData), ...
            trial.probabilityLeft*100.0, (1-trial.probabilityLeft)*100.0, ...
            trial.totalCorrect, trial.totalChoices);
         
         % Show the information
         self.updateStatus(taskString, trialString);
      end
      
      %% Finish Trial
      %
      % Could add stuff here
      function finishTrial(self)
         
         % ---- Get the trial
         %
         trial = self.getTrial();
         
         % ---- Check to switch reward blocks
         %
         %  1. Only one value is given for "changeInterval", which is
         %     then interpreted as the exact trial interval to use
         %  2. Two values are given and intrepreted as min & max
         %     defining a uniform distribution
         if trial.trialsAfterSwitch >= self.settings.changeInterval(1) && ...
               (length(self.settings.changeInterval) == 1 || ...
               trial.trialsAfterSwitch >= self.settings.changeInterval(2) || ...
               rand() <= 1/(1+diff(self.settings.changeInterval)))
            
            % Increment trial (use this flag instead of actually
            % incrementing the trialCount because this way it doesn't get
            % incremented until all of the bookkeeping is done before the
            % end of the trial
            self.autoIncrementTrial = true;
         else
            
            % Don't increment trial
            self.autoIncrementTrial = false;
         end
      end
      
      %% Check for choice
      %
      % Save choice/RT information and set up feedback for the dots task
      function nextState = checkForChoice(self, events, eventTag)
         
         % ---- Check for event
         %
         eventName = self.helpers.reader.readEvent(events, self, eventTag);
         
         % Nothing... keep checking
         if isempty(eventName)
            nextState = [];
            return
         end
         
         % ---- Good choice!
         %
         % Override completedTrial flag
         self.completedTrial = true;
         
         % Jump to next state when done
         nextState = 'blank';
         
         % Get current task/trial
         trial = self.getTrial();
         
         % Update count of trials since switch
         trial.trialsAfterSwitch = trial.trialsAfterSwitch + 1;
         
         % Save the choice, correct/error, RT
         trial.choice = double(strcmp(eventName, 'choseRight'));
         
         % Check to give reward
         if (trial.choice == 0 && rand() <= trial.probabilityLeft) || ...
               (trial.choice == 1 && rand() > trial.probabilityLeft)
            trial.rewarded = true;
         else
            trial.rewarded = false;
         end
         
         % Mark as correct/error (with respect to largest reward side)
         trial.totalChoices = trial.totalChoices + 1;
         trial.totalCorrect = trial.totalCorrect + double( ...
            (trial.choice==0 && trial.probabilityLeft>=0.5) || ...
            (trial.choice==1 && trial.probabilityLeft< 0.5));
         
         % Compute/save RT
         trial.RT = trial.choiceTime - trial.stimOn;
         
         % Re-save the trial
         self.setTrial(trial);
      end
      
      %% Show feedback
      %
      function showFeedback(self)
         
         % ---- Show trial feedback
         %
         trial = self.getTrial();
         
         % Check for outcome
         if ~self.completedTrial
            messageGroup = 'No_choice';
         elseif trial.rewarded
            messageGroup = 'Correct';
         else
            messageGroup = 'Error';
         end
         
         % --- Show trial feedback in gui
         %
         trialString = sprintf('Trial %d(%d)/%d: choice=%d (%s)', ...
            self.trialCount, trial.trialsAfterSwitch, numel(self.trialData), ...
            trial.choice, messageGroup);
         self.updateStatus([], trialString); % just update the second one
         
         % ---- Show trial feedback on the screen
         %
         self.helpers.message.show(messageGroup);
      end
   end
   
   methods (Access = protected)
      
      %% Prepare drawables for this trial
      %
      function prepareDrawables(self)
         
         % ---- Get the stimulus ensemble and set horizontal position using
         %        settings.targetDistance
         %
         stimulusEnsemble = self.helpers.stimulusEnsemble.theObject;
         stimulusEnsemble.setObjectProperty('x', -self.settings.targetDistance, 1);
         stimulusEnsemble.setObjectProperty('x',  self.settings.targetDistance, 2);
      end
      
      %% Prepare readables for this trial
      %
      function prepareReadables(self)
         
         % Activate chose* events
         self.helpers.reader.theObject.setEventsActiveFlag({'choseLeft', 'choseRight'});
      end
      
      %% configureStateMachine method
      %
      function initializeStateMachine(self)
         
         % ---- Fevalables for state list
         %
         dnow   = {@drawnow};
         blanks = {@dotsTheScreen.blankScreen};
         chkuic = {@checkForChoice, self, {'choseLeft' 'choseRight'}, 'choiceTime'};
         showfb = {@showFeedback, self};
         shows  = {@draw, self.helpers.stimulusEnsemble, {[1 2], []}, self, 'stimOn'};
         
         % ---- Timing variables, read directly from the timing property struct
         %
         t = self.timing;
         
         % ---- Make the state machine
         %
         % Note that the startTrial routine sets the target location and the 'next'
         % state after holdFixation, based on VGS vs MGS task
         states = {...
            'name'         'entry'  'input'  'timeout'             'exit'  'next'            ; ...
            'showStimuli'  shows    chkuic   t.choiceTimeout       {}      'blank'           ; ...
            'blank'        {}       {}       t.pauseAfterChoice    blanks  'showFeedback'    ; ...
            'showFeedback' showfb   {}       t.showFeedback        {}      'done'            ; ...
            'done'         dnow     {}       t.interTrialInterval  {}      ''                ; ...
            };
         
         % make the state machine
         self.addStateMachine(states);
      end
   end
   
   methods (Static)
      
      %% ---- Utility for defining standard configurations
      %
      function task = getStandardConfiguration(varargin)
         
         % ---- Get the task object, with optional property/value pairs
         task = topsTreeNodeTaskSimpleBandit(varargin{:});
      end
   end
end