function varargout = taskGUI(varargin)
% TASKGUI MATLAB code for taskGUI.fig
%      TASKGUI, by itself, creates a new TASKGUI or raises the existing
%      singleton*.
%
%      H = TASKGUI returns the handle to a new TASKGUI or the handle to
%      the existing singleton*.
%
%      TASKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TASKGUI.M with the given input arguments.
%
%      TASKGUI('Property','Value',...) creates a new TASKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before taskGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to taskGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help taskGUI

% Last Modified by GUIDE v2.5 10-Jun-2018 13:59:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @taskGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @taskGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before taskGUI is made visible.
function taskGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to taskGUI (see VARARGIN)

% Choose default command line output for taskGUI
handles.output = hObject;

% First (required) arg is topsTreeNode
handles.topsTreeNode = varargin{1};
handles.task = [];
   
% Second (optional) arg is dotsReadable object
handles.readableEye = [];
if nargin > 4 && ~isempty(varargin{2}) && isa(varargin{2}, 'dotsReadableEye')
   handles.readableEye = varargin{2};
   handles.readableEye.gazeMonitorAxes = handles.gazeAxes;
   handles.readableEye.initializeGazeMonitor();
end

% Run status args
handles.isRunning = false;

% Set other buttons as inactive
set([handles.skipbutton, handles.abortbutton, handles.recalibratebutton], ...
   'Enable', 'off');

% Update handles structure
guidata(hObject, handles);

% Task-specific updates
taskGUI_updateTask(hObject, [], handles, []);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using taskGUI.
if strcmp(get(hObject,'Visible'),'off') && isempty(handles.readableEye)
   % Create a grid of x and y data
   y = -10:0.5:10;
   x = -10:0.5:10;
   [X, Y] = meshgrid(x, y);
   
   % Create the function values for Z = f(X,Y)
   Z = sin(sqrt(X.^2+Y.^2)) ./ sqrt(X.^2+Y.^2);
   
   % Create a surface contour plor using the surfc function
   surfc(X, Y, Z)
   
   % Adjust the view angle
   view(-38, 18)
   
   % Add title and axis labels
   xlabel('x')
   ylabel('y')
   zlabel('z')
end

% UIWAIT makes taskGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% ---- Call when incrementing tasks
%
function taskGUI_updateTask(hObject, eventdata, handles, task)

% Add task
handles.task = task;

% update the text
text1_str = 'TASKS:';
for ii = 1:length(handles.topsTreeNode.children)
   text1_str = cat(2, text1_str, sprintf('  %d. %s', ...
      ii, handles.topsTreeNode.children{ii}.name));
   if ~isempty(task) && task==handles.topsTreeNode.children{ii}
      text1_str = [text1_str '**'];
   end
end
set(handles.status1text, 'String', text1_str);

% resave the data
guidata(hObject, handles);

% % ---- Call when incrementing trials
% %
% function taskGUI_updateTrial(hObject, eventdata, handles, str1, str2)
% 
% % possibly update the gaze windows
% if ~isempty(handles.readableEye)
%    for ii = 1:4
%       
%       if length(handles.readableEye.gazeEvents) >= ii
%          diamStr = num2str(handles.readableEye.gazeEvents(ii).windowSize);
%          durStr  = num2str(handles.readableEye.gazeEvents(ii).windowDur);
%          enable = 'on';
%       else
%          diamStr = '';
%          durStr  = '';
%          enable  = 'off';
%       end
%       
%       % Set diameter/dur in gui
%       set(handles.(sprintf('gwdiam%d', ii)), 'String', diamStr, 'Enable', enable);
%       set(handles.(sprintf('gwdur%d',  ii)), 'String', durStr,  'Enable', enable);
%    end
% end
% 
% % resave the data
% guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = taskGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)

% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
% hObject    handle to startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check status
if ~handles.isRunning
   
   % Green with envy
   set(hObject, 'String', 'Running', ...
      'BackGroundColor', [0 1 0]);

   % Set other buttons as active
   if ~isempty(handles.readableEye)
      set(handles.recalibratebutton, 'Enable', 'on', ...
         'BackGroundColor', [1 1 0]);
   end
   set(handles.skipbutton, 'Enable', 'on', ...
      'BackGroundColor', [1 0.5 0]);
   set(handles.abortbutton, 'Enable', 'on', ...
      'BackGroundColor', [1 0 0]);
   
   % Set the flag
   handles.isRunning = true;
   
   % Save the handles data
   guidata(hObject, handles);
   
   % Run the task
   handles.topsTreeNode.run();
   
   % Return when done
   return
end

% Toggle flag
handles.topsTreeNode.pauseFlag = ~handles.topsTreeNode.pauseFlag;

% Paused!
if handles.topsTreeNode.pauseFlag
   
   % Set appearance
   set(hObject, 'String', 'Paused', ...
      'BackGroundColor', [0.9 1.0 0.9]);
   drawnow;
   
   if ~handles.topsTreeNode.isRunning
      while handles.topsTreeNode.pauseFlag
         pause(0.01);
         handles = guidata(hObject);
      end
      return
   end
else
   
   % Unset paused flag and save
   set(hObject, 'String', 'Running', ...
      'BackGroundColor', [0 1 0]);
   drawnow;
end

% --- Executes on button press in skipbutton.
function skipbutton_Callback(hObject, eventdata, handles)
% hObject    handle to skipbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.topsTreeNode.skipFlag = true;


% --- Executes on button press in abortbutton.
function abortbutton_Callback(hObject, eventdata, handles)
% hObject    handle to abortbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.isRunning = false;
guidata(hObject, handles);

if ~handles.topsTreeNode.isRunning
   % Abort now
   error('Aborting early!')
else
   % Wait until end of trial
   handles.topsTreeNode.abortFlag = true;
end

% --- Executes on button press in recalibratebutton.
function recalibratebutton_Callback(hObject, eventdata, handles)
% hObject    handle to recalibratebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check that there is an eye tracker to calibrate
if ~isempty(handles.readableEye)
   handles.readableEye.calibrate();
end

% if ~handles.topsTreeNode.isRunning || handles.topsTreeNode.pauseFlag
%    % calibrate now
%    handles.readableEye.calibrate();
% else
%    % wait until end of trial
%    handles.topsTreeNode.calibrateFlag = true;
% end

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function gwdiam1_Callback(hObject, eventdata, handles)
% hObject    handle to gwdiam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gwdiam1 as text
%        str2double(get(hObject,'String')) returns contents of gwdiam1 as a double


% --- Executes during object creation, after setting all properties.
function gwdiam1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gwdiam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gwdur1_Callback(hObject, eventdata, handles)
% hObject    handle to gwdur1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gwdur1 as text
%        str2double(get(hObject,'String')) returns contents of gwdur1 as a double


% --- Executes during object creation, after setting all properties.
function gwdur1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gwdur1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gwdiam2_Callback(hObject, eventdata, handles)
% hObject    handle to gwdiam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gwdiam2 as text
%        str2double(get(hObject,'String')) returns contents of gwdiam2 as a double


% --- Executes during object creation, after setting all properties.
function gwdiam2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gwdiam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gwdur2_Callback(hObject, eventdata, handles)
% hObject    handle to gwdur2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gwdur2 as text
%        str2double(get(hObject,'String')) returns contents of gwdur2 as a double


% --- Executes during object creation, after setting all properties.
function gwdur2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gwdur2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gwdiam3_Callback(hObject, eventdata, handles)
% hObject    handle to gwdiam3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gwdiam3 as text
%        str2double(get(hObject,'String')) returns contents of gwdiam3 as a double


% --- Executes during object creation, after setting all properties.
function gwdiam3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gwdiam3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gwdur3_Callback(hObject, eventdata, handles)
% hObject    handle to gwdur3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gwdur3 as text
%        str2double(get(hObject,'String')) returns contents of gwdur3 as a double


% --- Executes during object creation, after setting all properties.
function gwdur3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gwdur3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gwdiam4_Callback(hObject, eventdata, handles)
% hObject    handle to gwdiam4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gwdiam4 as text
%        str2double(get(hObject,'String')) returns contents of gwdiam4 as a double


% --- Executes during object creation, after setting all properties.
function gwdiam4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gwdiam4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gwdur4_Callback(hObject, eventdata, handles)
% hObject    handle to gwdur4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gwdur4 as text
%        str2double(get(hObject,'String')) returns contents of gwdur4 as a double


% --- Executes during object creation, after setting all properties.
function gwdur4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gwdur4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
