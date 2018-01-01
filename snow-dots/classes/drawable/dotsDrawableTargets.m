classdef dotsDrawableTargets < dotsDrawable
   % @class dotsDrawableTargets
   % Draw one or multiple rectangular or oval targets at once.
   
   properties
      
      % colors, n rows x <scalar or [r g b]' or [r g b a]'>
      color = [1 0 0]';
      
      % Center x position
      xCenter = 0;
      
      % Center y position
      yCenter = 0;
      
      % Width of drawing rect
      width = 1;
      
      % Height of drawing rect
      height = [];
      
      % pen width, in pixels, for FrameRect and FrameOval
      penWidth = 1;
      
      % pen height, in pixels, for FrameOval
      penHeight = 1;
      
      % (string) type: 'FillRect', 'FrameRect', 'FillOval', or 'FrameOval'
      targetType = 'FillRect';
   end
   
   methods
      % Constructor takes no arguments.
      function self = dotsDrawableTargets()
         self = self@dotsDrawable();
      end
      
      % draw it
      function draw(self)
         
         % Use screen with type and collected arguments
         theScreen = dotsTheScreen.theObject();
         rect = theScreen.getRect(self.xCenter, self.yCenter, ...
            self.width, self.height);
         
         switch(self.targetType)
            
            case 'FillRect'
               Screen('FillRect', theScreen.windowPointer, ...
                  self.color, rect);
               
            case 'FrameRect'
               Screen('FrameRect', theScreen.windowPointer, ...
                  self.color, rect, ...
                  self.penWidth);
               
            case 'FillOval' % could add perfectUpToMaxDiameter
               Screen('FillOval', theScreen.windowPointer, ...
                  self.color, rect);
               
            case 'FrameOval'
               Screen('FrameOval', theScreen.windowPointer, ...
                  self.color, rect, ...
                  self.penWidth, self.penHeight);
         end
      end
   end
end
