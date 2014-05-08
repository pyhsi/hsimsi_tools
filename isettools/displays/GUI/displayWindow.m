function varargout = displayWindow(varargin)
% displayWindow main window
%
% This is the main GUI window for interfacing with the Clear Type or
% Display Simulator design functions.  From this window you can visualize
% the sub-pixels, load simple images, and perform various analytical
% calculations using the display.  The display radiance data can also be
% converted into an ISET Scene format and thus transferred into the ISET
% analysis tools.
%
% This function brings up the window to edit display properties
%
%      DISPLAYWINDOW, by itself, creates a new DISPLAYWINDOW or raises the existing
%      singleton*.
%
%      H = DISPLAYWINDOW returns the handle to a new DISPLAYWINDOW or the handle to
%      the existing singleton*.
%
%      DISPLAYWINDOW('Property','Value',...) creates a new DISPLAYWINDOW using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to displayWindow_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DISPLAYWINDOW('CALLBACK') and DISPLAYWINDOW('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DISPLAYWINDOW with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% (c) Stanford, PDCSOFT, Wandell, 2010
% (HJ), PDCSOFT, 2014

%#ok<*DEFNU> % suppress unused warnings

% Edit the above text to modify the response to help displayWindow

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @displayWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @displayWindow_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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
return;

% --- Executes just before displayWindow is made visible.
function displayWindow_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Refresh handles structure
guidata(hObject, handles);

% add to vcSESSION
global vcSESSION
if ~checkfields(vcSESSION, 'GUI', 'vcDisplayWindow')
    vcSESSION.GUI.vcDisplayWindow.hObject = hObject;
    vcSESSION.GUI.vcDisplayWindow.eventdata = eventdata;
    vcSESSION.GUI.vcDisplayWindow.handles = handles;
end

% Refresh image window
I = imread(fullfile(isetRootPath, 'data', 'images', 'rgb', 'macbeth.tif'));
I = im2double(I);
vcSESSION.imgData = I;

% Refresh other components
displayRefresh(hObject, eventdata, handles);

return;

% --- Outputs from this function are returned to the command line.
function varargout = displayWindow_OutputFcn(~, ~, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

return;

% --------------------------------------------------------------------
function menuFileLoadImage_Callback(hObject, eventdata, handles)
% File | Load Image
%
fname = uigetfile('*.*', 'Choose Image File');
if fname == 0, return; end
I = im2double(imread(fname));

global vcSESSION;
vcSESSION.imgData = I;

% Refresh other components
displayRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuEditNew_Callback(~, ~, handles)
% Edit | New Model
d = displayCreate('LCD-Apple');
vcAddAndSelectObject('display', d);
displayRefresh([], [], handles);
return;

% --------------------------------------------------------------------
function menuDeleteCurrent_Callback(~, ~, handles)
% Edit | Delete
vcDeleteSelectedObject('display');
displayRefresh([], [], handles);
return;

% --------------------------------------------------------------------
function subpixeImage_Callback(~, ~, ~)
% Plot | Sub pixel image
ind = vcGetSelectedObject('display');
if isempty(ind), disp('No display selected'); return; end
d = vcGetObject('display', ind);
psfs = displayGet(d, 'psfs');
if isempty(psfs), disp('no psfs in display model'); return;
else figure; imshow(psfs/ max(psfs(:)));
end

return;

% --------------------------------------------------------------------
function menuAnalyzeOutputImage_Callback(~, ~, handles)
% Analyze | Output image (by units)
h = get(handles.axes1, 'Children');
I = get(h, 'CData');
ind = vcGetSelectedObject('display');
if isempty(ind), disp('No display selected'); return; end
d = vcGetObject('display', ind);
subI = displayCompute(d, I);
figure; imshow(subI / max(subI(:)));
return;


% --------------------------------------------------------------------
function menuAnalyzeSceneSubpixel_Callback(~, ~, ~)
% Analyze | Scene
% Opens up a Scene Window
ind = vcGetSelectedObject('display');
d = vcGetObject('display', ind);

% Get current image
global vcSESSION;
if isfield(vcSESSION, 'imgData')
    I = vcSESSION.imgData;
else
    warning('No image set');
    return;
end

% Generate scene
if isempty(I), disp('No image set'); return; end
scene = sceneFromFile(I, 'rgb', [], d, [], 1);

% Compute scene size
[r,c,~] = size(I);
vDist = sceneGet(scene, 'distance');
fov   = atand(max(r,c) * displayGet(d, 'metersperdot')/vDist);
scene = sceneSet(scene, 'fov', fov);

% Show scene window
vcAddAndSelectObject('scene', scene);
sceneWindow;

% --------------------------------------------------------------------
function menuAnalyzeScene_Callback(~, ~, ~)
% Analyze | Scene
% Opens up a Scene Window
ind = vcGetSelectedObject('display');
if isempty(ind), disp('no display selected'); return; end
d = vcGetObject('display', ind);

% Get current image
global vcSESSION;
if isfield(vcSESSION, 'imgData')
    I = vcSESSION.imgData;
else
    warning('No image set');
    return;
end

% Generate scene
if isempty(I),  warning('No image set'); return; end
scene = sceneFromFile(I, 'rgb', [], d, [], 0);

% Compute scene size
[r,c,~] = size(I);
vDist = sceneGet(scene, 'distance');
fov   = atand(max(r,c)  * displayGet(d,'metersperdot')/vDist);
scene = sceneSet(scene, 'fov', fov);

% Show scene window
vcAddAndSelectObject('scene', scene);
sceneWindow;

% --------------------------------------------------------------------
function menuClose_Callback(~, ~, handles)
% File | Close
displayClose(handles.figure1);

% --------------------------------------------------------------------
function menuSaveDisplayModel_Callback(~, ~, ~)
% File | Save Display
ind = vcGetSelectedObject('display');
if isempty(ind), disp('no display selected'); return; end
d = vcGetObject('display', ind); 
fname = uiputfile('*.mat');
if fname == 0, return; end
save(fname, 'd');

% --------------------------------------------------------------------
function displayRefresh(~, ~, handles)
displaySetEditsAndButtons(handles);

% --------------------------------------------------------------------
function figure1_CloseRequestFcn(~, ~, handles)
displayClose(handles.figure1);

% --------------------------------------------------------------------
function menuCRT_Callback(hObject, eventdata, handles)
% Display | CRT
d = displayCreate('crt');
vcAddAndSelectObject('display', d);
displayRefresh(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menuShowInNewWindow_Callback(~, ~, handles)
% Edit | Show in Zoomed View
pos = get(handles.figure1, 'Position');
figure('Position', pos);
% Get current image
h = get(handles.axes1, 'children');
I = get(h, 'CData');
% Show image
imshow(I);

% --------------------------------------------------------------------
function menuLoadDisplayModel_Callback(hObject, eventdata, handles)
% File | Load Display
%
fname = uigetfile('*.mat', 'Load Display From MAT file');
if fname == 0, return; end
tmp = load(fname);
if isfield(tmp, 'd'), d = tmp.d; else error('Not display file'); end
vcAddAndSelectObject('display', d);
displayRefresh(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menuPlotDisplaySPD_Callback(~, ~, ~)
ind = vcGetSelectedObject('display');
if isempty(ind), disp('no display selected'); return; end
d = vcGetObject('display', ind);
displayPlot(d, 'spd');

% --------------------------------------------------------------------
function menuPlotGamut_Callback(~, ~, ~)
ind = vcGetSelectedObject('display');
if isempty(ind), disp('no display selected'); return; end
d = vcGetObject('display', ind);
displayPlot(d, 'gamut');


% --------------------------------------------------------------------
function menuPlotGamma_Callback(~, ~, ~)
ind = vcGetSelectedObject('display');
if isempty(ind), disp('no display selected'); return; end
d = vcGetObject('display', ind);
displayPlot(d, 'gamma');

% --------------------------------------------------------------------
function menuLCDHorizontalStripesRGB_Callback(hObject, eventdata, handles)
% displayGD   = ctGetObject('display');
% dpi = 72;
% dSpacing = 0.001; % sample spacing in mm
% vDisplayLCD = vDisplayCreate('lcd',dpi,dSpacing,'h','rgb');
% 
% displayGD   = ctDisplaySet(displayGD,'vDisplay',vDisplayLCD);  % Add?  Replace?
% ctSetObject('display', displayGD);
% ctdpRefreshGUIWindow(hObject);
warning('NYI');

% --------------------------------------------------------------------
function menuLCDVerticalStripesRGB_Callback(hObject, eventdata, handles)
% displayGD  = ctGetObject('display');
% 
% dpi = 72;
% dSpacing = 0.001; % sample spacing in mm
% vDisplayLCD = vDisplayCreate('lcd',dpi,dSpacing,'v','rgb');
% 
% displayGD  = ctDisplaySet(displayGD,'vDisplay',vDisplayLCD);  % Add?  Replace?
% ctSetObject('display', displayGD);
% ctdpRefreshGUIWindow(hObject);
warning('NYI');

% --------------------------------------------------------------------
function menuLCDVerticalStripesBGR_Callback(hObject, eventdata, handles)
% Display | LCD | Vertical BGR
% displayGD  = ctGetObject('display');
% 
% dpi = 72;
% dSpacing = 0.001; % sample spacing in mm
% vDisplayLCD = vDisplayCreate('lcd',dpi,dSpacing,'v','bgr');
% 
% displayGD  = ctDisplaySet(displayGD,'vDisplay',vDisplayLCD);  % Add?  Replace?
% ctSetObject('display', displayGD);
% ctdpRefreshGUIWindow(hObject);
warning('NYI');

% --------------------------------------------------------------------
function menuLCDHorizontalStripesBGR_Callback(hObject, eventdata, handles)
% Display | LCD | Vertical BGR
% displayGD   = ctGetObject('display');
% 
% dpi = 72;
% dSpacing = 0.001; % sample spacing in mm
% vDisplayLCD = vDisplayCreate('lcd',dpi,dSpacing,'h','bgr');
% 
% displayGD   = ctDisplaySet(displayGD,'vDisplay',vDisplayLCD);  % Add?  Replace?
% ctSetObject('display', displayGD);
% ctdpRefreshGUIWindow(hObject);
warning('NYI');

% --------------------------------------------------------------------
function menuEditChangeFontSize_Callback(~, ~, handles)
% ctFontChangeSize(handles.figure1);
answer = inputdlg('New Font Size (7~15)');
if isempty(answer), return; end
answer = str2double(answer);
assert(answer > 6 && answer < 16, 'Front size out of range');
set(handles.text61, 'FontSize', answer);
set(handles.uipanelSummary, 'FontSize', answer);
set(handles.txtSummary, 'FontSize', answer);
set(handles.txtMaxLum, 'FontSize', answer);
set(handles.txtPosVar, 'FontSize', answer);
set(handles.txtAmp, 'FontSize', answer);
set(handles.uipanel2, 'FontSize', answer);

% --- Executes on selection change in popupSelectDisplay.
function popupSelectDisplay_Callback(hObject, eventdata, handles)
% Called when the 'Selected Display' popup is chosen
val = get(handles.popupSelectDisplay,'value');
vcSetSelectedObject('display',val);
displayRefresh(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menuEditRenameDisplay_Callback(hObject, eventdata, handles)
ind = vcGetSelectedObject('display'); 
if isempty(ind), disp('no display selected'); return; end
answer = inputdlg('New Display Name');
if isempty(answer), return; end
d = vcGetObject('display', ind);
d = displaySet(d, 'name', answer{1});
vcDeleteSelectedObject('display');
vcAddAndSelectObject('display', d);
displayRefresh(hObject, eventdata, handles);


%-----------------------------------------------------
function editMaxLum_Callback(hObject, eventdata, handles)
% Edit box for max luminance
ind = vcGetSelectedObject('display'); 
if isempty(ind), disp('no display selected'); return; end
d = vcGetObject('display', ind);
xyz = displayGet(d, 'white xyz');
newLum = str2double(get(handles.editMaxLum, 'String'));
spd = displayGet(d, 'spd') * newLum / xyz(2);
d = displaySet(d, 'spd', spd);
vcDeleteSelectedObject('display');
vcAddAndSelectObject('display', d);
displayRefresh(hObject, eventdata, handles);

%-----------------------------------------------------
function editMaxLum_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function editVar_Callback(hObject, eventdata, handles)
disp('Not yet implemented')

function editVar_CreateFcn(hObject, ~, ~)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPPI_Callback(hObject, eventdata, handles)
ind = vcGetSelectedObject('display'); 
if isempty(ind), disp('no display selected'); return; end
d = vcGetObject('display', ind);
newPPI = str2double(get(handles.editPPI, 'String'));
d = displaySet(d, 'dpi', newPPI);
vcDeleteSelectedObject('display');
vcAddAndSelectObject('display', d);
displayRefresh(hObject, eventdata, handles);

function editPPI_CreateFcn(hObject, ~, ~)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuOLED_Callback(hObject, eventdata, handles)
% hObject    handle to menuOLED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
d = displayCreate('OLED-Sony');
vcAddAndSelectObject('display', d);
displayRefresh(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menuProductHelp_Callback(~, ~, ~)
warning('NYI');

% --------------------------------------------------------------------
function menuAbout_Callback(~, ~, ~)
warning('NYI')

% --------------------------------------------------------------------
function menuCopyCurrent_Callback(hObject, eventdata, handles)
ind = vcGetSelectedObject('display'); 
if isempty(ind), disp('no display selected'); return; end
d = vcGetObject('display', ind);
dname = displayGet(d, 'name');
d = displaySet(d, 'name', ['copy - ' dname]);
vcAddAndSelectObject('display', d);
displayRefresh(hObject, eventdata, handles);

% --------------------------------------------------------------------
function popupSelectDisplay_CreateFcn(hObject, ~, ~)
% hObject    handle to popupSelectDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function SubpixelScale_Callback(hObject, eventdata, handles)
% hObject    handle to SubpixelScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ind = vcGetSelectedObject('display'); 
if isempty(ind), disp('no display selected'); return; end
answer = inputdlg('New samples per pixel (10 ~ 30)');
if isempty(answer), return; end
answer = str2double(answer);
assert(answer > 9 && answer < 31, 'samples per pixel out of range');
d = vcGetObject('display', ind);
psfs = displayGet(d, 'psfs');
d = displaySet(d, 'psfs', imresize(psfs, [answer answer]));
vcDeleteSelectedObject('display');
vcAddAndSelectObject('display', d);
displayRefresh(hObject, eventdata, handles);
