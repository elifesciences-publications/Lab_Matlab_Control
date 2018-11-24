classdef topsTaskHelperTTL < topsTaskHelper
   % Class topsTaskHelperTTL
   %
   % Add topsTaskHelperTTL, a subclass of topsTaskHelper
   
   properties (SetObservable)
      
      % Maximum number of pulses
      maxPulses = 4;
      
      % trialData fields
      trialDataFields = {'TTLstart', 'TTLnum', 'TTLfinish'};      
   end
   
   methods
      
      % Constuct the helper
      %
      % Arguments:
      %  readableName ... string name of readable
      function self = topsTaskHelperTTL()
            
         % Create it
         self = self@topsTaskHelper('TTL', [], ...
            'fevalable',   @dotsWritableDOut.getDefault);
      end
      
      % Overloaded bind method
      %
      %  Overwrites the prepare fevalable to call sendPulses method
      %  based on the current trial
      function bind(self, treeNode)
         
         % Only bind to topsTreeNodeTask
         if isa(treeNode, 'topsTreeNodeTask')
            
            % Add the prepare call
            self.prepareCallList.addCall({@sendTTL, self, treeNode}, 'sendTTL');
            
            % Add the trialData field
            for ii = 1:length(self.trialDataFields)
               if ~isfield(treeNode.trialData, self.trialDataFields{ii})
                  [treeNode.trialData.(self.trialDataFields{ii})] = deal(nan);
               end
            end
         end
      end
      
      %% sendTTL
      %
      function sendTTL(self, treeNode)
                
         % Num pulses is based on the trial number
         numPulses =  mod(max(0, treeNode.trialCount-1), self.maxPulses)+1;
         
         % send pulses
         [startTime, endTime] = self.theObject.sendTTLPulses([], numPulses);
         
         % Set the values in the trialData struct
         treeNode.setTrialData([], self.trialDataFields{1}, startTime);
         treeNode.setTrialData([], self.trialDataFields{2}, numPulses);
         treeNode.setTrialData([], self.trialDataFields{3}, endTime);
      end
   end
end