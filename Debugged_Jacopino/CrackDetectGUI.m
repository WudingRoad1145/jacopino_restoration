function varargout = CrackDetectGUI(varargin)
% CrackDetectGUI MATLAB code for CrackDetectGUI.fig
%      CrackDetectGUI, by itself, creates a new CrackDetectGUI or raises the existing
%      singleton*.
%
%      H = CrackDetectGUI returns the handle to a new CrackDetectGUI or the handle to
%      the existing singleton*.
%
%      CrackDetectGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CrackDetectGUI.M with the given input arguments.
%
%      CrackDetectGUI('Property','Value',...) creates a new CrackDetectGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CrackDetectGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CrackDetectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CrackDetectGUI

% Last Modified by GUIDE v2.5 16-Jun-2017 10:08:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CrackDetectGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CrackDetectGUI_OutputFcn, ...
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


% --- Executes just before CrackDetectGUI is made visible.
function CrackDetectGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CrackDetectGUI (see VARARGIN)

% Choose default command line output for CrackDetectGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% create the listener for each slider
handles.sliderParam1Listener = addlistener(handles.sliderParam1,'ContinuousValueChange', ...
                                      @(hFigure,eventdata) sliderParam1ContValCallback(...
                                        hObject,eventdata));
handles.sliderParam2Listener = addlistener(handles.sliderParam2,'ContinuousValueChange', ...
                                      @(hFigure,eventdata) sliderParam2ContValCallback(...
                                        hObject,eventdata));                               
handles.sliderParam3Listener = addlistener(handles.sliderParam3,'ContinuousValueChange', ...
                                      @(hFigure,eventdata) sliderParam3ContValCallback(...
                                        hObject,eventdata));  
handles.sliderParam4Listener = addlistener(handles.sliderParam4,'ContinuousValueChange', ...
                                      @(hFigure,eventdata) sliderParam4ContValCallback(...
                                        hObject,eventdata));                               
handles.sliderParam5Listener = addlistener(handles.sliderParam5,'ContinuousValueChange', ...
                                      @(hFigure,eventdata) sliderParam5ContValCallback(...
                                        hObject,eventdata));  
handles.sliderParam6Listener = addlistener(handles.sliderParam6,'ContinuousValueChange', ...
                                      @(hFigure,eventdata) sliderParam6ContValCallback(...
                                        hObject,eventdata));                               
handles.sliderParam7Listener = addlistener(handles.sliderParam7,'ContinuousValueChange', ...
                                      @(hFigure,eventdata) sliderParam7ContValCallback(...
                                        hObject,eventdata));  
                                    
% Set initial states
set(handles.viewer,'Visible','off');

set(handles.editParam1,'String',get(handles.sliderParam1,'Value'));
set(handles.editParam2,'String',get(handles.sliderParam2,'Value'));
set(handles.editParam3,'String',get(handles.sliderParam3,'Value'));
set(handles.editParam4,'String',get(handles.sliderParam4,'Value'));
set(handles.editParam5,'String',get(handles.sliderParam5,'Value'));
set(handles.editParam6,'String',get(handles.sliderParam6,'Value'));
set(handles.editParam7,'String',get(handles.sliderParam7,'Value'));

set(handles.checkboxSegment,'Value',0);
set(findall(handles.uipanelSegment,'-property','Enable'),'Enable','off');

set([handles.textWait1, handles.textWait2],'Visible','off');

% Initialize useful data handles
handles.image = 0;
handles.ridgeParams = [0 0 0];
handles.ridge = 0;
handles.thresholds = [0;0];
handles.threshold = [0;0];
handles.crack = 0;
handles.marked = 0;
handles.segment = 0;
handles.segmentParams = [0 0];
guidata(hObject, handles);


% UIWAIT makes CrackDetectGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CrackDetectGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Renders preview image.
function view(image, viewer)
% image      the image to be shown on the image viewer
imagesc(image,'Parent',viewer);
axis image; box off; set(gca,'xtick',[],'ytick',[]);

% --- Executes on button press in pushbuttonUploader.
function pushbuttonUploader_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonUploader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% select file from browser
[filename, foldername] = uigetfile({'*.*'}, 'Select file');
if filename ~= 0
    FileName = fullfile(foldername, filename);
    set(handles.textNoPreview,'Visible','off'); % Remove "no preview" message
    set(handles.viewer,'Visible','on'); % Make image viewer visible
    F = imread(FileName);
    if ~isequal(F, handles.image) % only if new image was chosen
        handles.image = F; % set image as chosen file
        handles.ridge = 0; % reset ridge
        handles.ridgeParams = [0 0 0]; % reset ridge parameters
        handles.crack = 0; % reset crackmap
        handles.marked = 0; % reset crack marked image
        handles.segment = 0; % reset segmentation
        handles.segmentParams = [0 0]; % reset segmentation parameters
        guidata(hObject,handles);
        if size(filename,2) > 43
            filename = [strtrim(filename(1:40)) '...']; 
        end
        set(handles.textFileName,'String',filename); % Show the name of selected image
        view(handles.image, handles.viewer); % Display selected image
    end
end

% --- Executes on button press in pushbuttonDetectCrack
function pushbuttonDetectCrack_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDetectCrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load saved image and parameters
image = handles.image;
ridge = handles.ridge;
params = handles.ridgeParams;

if ~isequal(0, image)
    set(handles.textWait1,'Visible','on');
    pause(0.1);
    % Take in the parameters from the edit boxes
    angles = round(get(handles.sliderParam1,'Value'));
    S = get(handles.sliderParam2,'Value');
    A = get(handles.sliderParam3,'Value');
    ridgeParamChanged = (angles ~= params(1)) | (S ~= params(2)) | (A ~= params(3));
    n = 1; % reserved in case segmentation of image is required

    if isequal(0, ridge) | ridgeParamChanged
        ridge = detectCrackP(image, angles, S, A, 1 - get(handles.checkboxBright,'Value')); % Run crack detection code
        handles.ridge = ridge;
        handles.ridgeParams = [angles S A];
        guidata(hObject,handles);
    end
    imshow(ridge, 'Parent', handles.viewer);
    cmap = colormap(gray)*3;
    cmap(find(cmap>1)) = 1;
    cmap = 1 - cmap;
    
    colormap(handles.viewer, cmap);
end
set(handles.textWait1,'Visible','off');

% --- Thresholds an image as a whole.
function threshold(ridge, T1, T2, handles)
% disp('threshold called')
crackmap = zeros(size(ridge));
im_threshold = zeros(size(ridge));

ridge2 = ridge;
ridge2(ridge>T1) = 0;
bw = hysthresh(ridge, T1, T2);
im_threshold(:) = T1;
crackmap = crackmap | bw;
im_marked = markCracks(handles.image,crackmap,[1 0 0]);
handles.crack = crackmap;
handles.marked = im_marked;
guidata(handles.pushbuttonThreshold, handles);
imshow(im_marked,'Parent',handles.viewer);

% --- Thresholds a specific segment of an image.
function thresholdSegment(ridge, T, label, handles)
% disp('thresholdSegment called')
crackmap = zeros(size(ridge));
im_threshold = zeros(size(ridge));
seg = handles.segment==label;

ridge2 = ridge;
ridge2(ridge>T(1,label)) = 0;
bw = hysthresh(ridge, T(1,label), T(2,label));
bw(~seg) = 0;
im_threshold(seg) = T(1,label);
crackmap = crackmap | bw;
im_marked = markCracks(handles.image,crackmap,[1 0 0]);
handles.crack(find(seg)) = crackmap(find(seg));
handles.marked(find(seg)) = im_marked(find(seg));
guidata(handles.pushbuttonThreshold, handles);
imshow(im_marked.*cat(3,seg,seg,seg),'Parent',handles.viewer);

% --- Executes on button press in pushbuttonSegment.
function pushbuttonSegment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
image = handles.image;
segment = handles.segment;
params = handles.segmentParams;

if ~isequal(0, image)
    set(handles.textWait2,'Visible','on');
    pause(0.1);
    % Take in parameters from sliders
    scale = get(handles.sliderParam5,'Value');
    bandwidth = get(handles.sliderParam4,'Value');
    segmentParamChanged = (bandwidth ~= params(1)) | (scale ~= params(2)); % Check if segment parameters changed
    
    if isequal(0, segment) | segmentParamChanged
        set(handles.popupmenuSegment,'Enable','on')
        
        im = image(:,:,1:3);
        [im_h, im_w, ~] = size(im);

        img_tn = imresize(im,scale);        % scale
        [img_h, img_w, n] = size(img_tn);   
        h = fspecial('gaussian', 5, 2);     % blur
        img_blurred = imfilter(img_tn,h);

        % conversion to Lab colorspace
        img_blurred = colorspace('Lab<-rgb',img_blurred);

        % meanshift clustering
        c1 = img_blurred(:,:,1); c2 = img_blurred(:,:,2); c3 = img_blurred(:,:,3);
        x = [c1(:) c2(:) c3(:)]';
        [clustCent,point2cluster,clustMembsCell] = MeanShiftCluster(x,bandwidth);
        
        segment = reshape(point2cluster,[img_h img_w]);
        k = max(max(segment));
        segment = imresize(segment,[im_h im_w],'nearest');
                
        handles.segment = segment;
        handles.segmentParams = [bandwidth scale];
        T = zeros(2,k);
        handles.thresholds = T;
        guidata(hObject,handles);
    end
    k = max(max(segment));
    % Generate popup menu from which each segment can be selected
    cells = {'Full image'};
    for label = 1:k
        cells = [cells ['Segment ' num2str(label)]];
    end
    set(handles.pushbuttonThreshold,'Enable','on');
    set(handles.popupmenuSegment,'Value',1,'String',cells);
end
set(handles.textWait2,'Visible','off');

% --- Executes on button press in auto pushbuttonThreshold.
function pushbuttonThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
image = handles.image;
ridge = handles.ridge;

if ~isequal(0, ridge);
    if get(handles.checkboxSegment,'Value')
        segment = handles.segment;
        T = handles.thresholds;
    else
        segment = ones(size(ridge));
        T = handles.threshold;
    end

    n_labels = max(max(segment));
    crackmap = zeros(size(ridge));
    T = zeros(2,n_labels); 

    % for each segment, find new threshold
    for label = 1:n_labels

        histogram = imhist(ridge(segment==label));
        histogram(1) = []; % suppress zero values

        T(1,label) = RosinThreshold(histogram)/256;

        ridge2 = ridge;
        ridge2(ridge> T(1,label)) = 0;

        histogram = imhist(ridge2(segment==label));
        histogram(1) = []; % suppress zero values

        T(2,label) = RosinThreshold(histogram)/256;

        bw = hysthresh(ridge,  T(1,label), T(2,label));
        bw(segment~=label) = 0;
        crackmap = crackmap | bw;
    end
    if get(handles.checkboxSegment,'Value')
        handles.thresholds = T;
    else
        handles.threshold = T;    
    end
    im_marked = markCracks(image,crackmap,[1 0 0]);
    handles.crack = crackmap;
    handles.marked = im_marked;
    guidata(hObject, handles);

    % display crackmap
    view(im_marked, handles.viewer);

    % store the threshold parameters
    val = get(handles.popupmenuSegment,'Value') - 1;
    if get(handles.checkboxSegment,'Value') & val
        T1 = T(1,val);
        T2 = T(2,val);
    else
        T1 = T(1,1);
        T2 = T(2,1);
    end
    set(handles.sliderParam6,'Value',T1);
    set(handles.sliderParam7,'Value',T2);
    set(handles.editParam6,'String',T1);
    set(handles.editParam7,'String',T2);
end

% --- Executes on button press in pushbuttonExport.
function pushbuttonExport_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
image = handles.image;
ridgeParams = handles.ridgeParams;
ridge = handles.ridge;
crackmap = handles.crack;
im_marked = handles.marked;
segments = handles.segment;
segmentParams = handles.segmentParams;
filename = strsplit(get(handles.textFileName,'String'),'.');
filename = filename{1};

SE = strel('disk',1);
crackmap = imdilate(crackmap,SE);

name = inputdlg({'Enter file name:'},'Save as',1,{filename});

if get(handles.checkboxSegment,'Value')
    T = handles.thresholds;
    save([name{1} '_threshold.mat'],'T','segments','segmentParams');
else
    T = handles.threshold;
    save([name{1} '_threshold.mat'],'T');
end
save([name{1} '_crackmap.mat'],'crackmap','im_marked','ridge','ridgeParams');
imwrite(crackmap,[name{1} '_crackmap.png']);


% parameter edit boxes for crack detection
function editParam1_Callback(hObject, eventdata, handles)
% hObject    handle to editParam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = max(0,min(str2double(get(hObject,'String')),get(handles.sliderParam1,'Max')));
set(handles.sliderParam1,'Value',val);
set(hObject,'String',val);
function editParam1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editParam2_Callback(hObject, eventdata, handles)
% hObject    handle to editParam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = max(0,min(str2double(get(hObject,'String')),get(handles.sliderParam2,'Max')));
set(handles.sliderParam2,'Value',val);
set(hObject,'String',val);
function editParam2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editParam3_Callback(hObject, eventdata, handles)
% hObject    handle to editParam3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = max(0,min(str2double(get(hObject,'String')),get(handles.sliderParam3,'Max')));
set(handles.sliderParam3,'Value',val);
set(hObject,'String',val);
function editParam3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParam3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% parameter sliders for crack detection
function sliderParam1ContValCallback(hFigure,eventdata)
% hFigure    handle to sliderParam1
% eventdata  reserved
handles = guidata(hFigure);
set(handles.editParam1,'String',round(get(handles.sliderParam1,'Value')));
function sliderParam1_Callback(hObject, eventdata, handles)
function sliderParam1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderParam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
maxVal = 16; stepSize = 1;
set(hObject,'Min',0,'Max',maxVal); 
set(hObject,'SliderStep',[stepSize/maxVal 0.1]); % Make slider move by an increment of 1
set(hObject,'Value',8); % Default to 8
function sliderParam2ContValCallback(hFigure,eventdata)
% hFigure    handle to sliderParam2
% eventdata  reserved
handles = guidata(hFigure);
set(handles.editParam2,'String',round(get(handles.sliderParam2, 'Value'),1));
function sliderParam2_Callback(hObject, eventdata, handles)
function sliderParam2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderParam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
maxVal = 10; stepSize = 1;
set(hObject,'Min',0,'Max',maxVal); 
set(hObject,'SliderStep',[stepSize/maxVal 0.1]); % Make slider move by an increment of 1
set(hObject,'Value',2); % Default to 2
function sliderParam3ContValCallback(hFigure,eventdata)
% hFigure    handle to sliderParam3
% eventdata  reserved
handles = guidata(hFigure);
set(handles.editParam3,'String',round(get(handles.sliderParam3, 'Value'),1));
function sliderParam3_Callback(hObject, eventdata, handles)
function sliderParam3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderParam3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
maxVal = 10; stepSize = 1;
set(hObject,'Min',0,'Max',maxVal); 
set(hObject,'SliderStep',[stepSize/maxVal 0.1]); % Make slider move by an increment of 1
set(hObject,'Value',2); % Default to 2

% parameter edit boxes for segmentation
function editParam4_Callback(hObject, eventdata, handles)
% hObject    handle to editParam4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = max(0,min(str2double(get(hObject,'String')),get(handles.sliderParam4,'Max')));
set(handles.sliderParam4,'Value',val);
set(hObject,'String',val);
function editParam4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParam4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editParam5_Callback(hObject, eventdata, handles)
% hObject    handle to editParam5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = max(0,min(str2double(get(hObject,'String')),get(handles.sliderParam5,'Max')));
set(handles.sliderParam5,'Value',val);
set(hObject,'String',val);
function editParam5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParam5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% parameter sliders for segmentation
function sliderParam4ContValCallback(hFigure,eventdata)
% hFigure    handle to sliderParam4
% eventdata  reserved
handles = guidata(hFigure);
set(handles.editParam4,'String',round(get(handles.sliderParam4,'Value'),1));
function sliderParam4_Callback(hObject, eventdata, handles)
function sliderParam4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderParam4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
maxVal = 10; stepSize = 1;
set(hObject,'Min',0,'Max',maxVal); 
set(hObject,'SliderStep',[stepSize/maxVal 0.1]); % Make slider move by an increment of 1
set(hObject,'Value',6); % Default to 6
function sliderParam5ContValCallback(hFigure,eventdata)
% hFigure    handle to sliderParam1
% eventdata  reserved
handles = guidata(hFigure);
set(handles.editParam5,'String',round(get(handles.sliderParam5,'Value'),2));
function sliderParam5_Callback(hObject, eventdata, handles)
function sliderParam5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderParam5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]); 
end
maxVal = 1; stepSize = 0.1;
set(hObject,'Min',0,'Max',maxVal); 
set(hObject,'SliderStep',[stepSize/maxVal 0.1]); % Make slider move by an increment of 0.1
set(hObject,'Value',0.2); % Default to 0.2

% parameter edit boxes for thresholding
function editParam6_Callback(hObject, eventdata, handles)
% hObject    handle to editParam6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = max(0,min(str2double(get(hObject,'String')),get(handles.sliderParam6,'Max')));
set(handles.sliderParam6,'Value',value);
set(hObject,'String',value);
val = get(handles.popupmenuSegment,'Value') - 1;
checkbox = get(handles.checkboxSegment,'Value');
if checkbox
    handles.thresholds(1,max(1,val)) = get(handles.editParam6,'String');
else
    handles.threshold(1) = get(handles.editParam6,'String');
end
guidata(hObject, handles);
if ~isequal(0, handles.ridge)
    label = get(handles.popupmenuSegment,'Value') - 1;
    if label
        thresholdSegment(handles.ridge, handles.thresholds, label, handles);
    else
        if checkbox
            T1 = handles.thresholds(1,label);
            T2 = handles.thresholds(2,label);
        else
            T1 = handles.threshold(1);
            T2 = handles.threshold(2);
        end
        threshold(handles.ridge, T1, T2, handles);
    end
end
function editParam6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParam6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editParam7_Callback(hObject, eventdata, handles)
% hObject    handle to editParam7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = max(0,min(str2double(get(hObject,'String')),get(handles.sliderParam7,'Max')));
set(handles.sliderParam7,'Value',value);
set(hObject,'String',value);
val = get(handles.popupmenuSegment,'Value') - 1;
checkbox = get(handles.checkboxSegment,'Value');
if checkbox
    handles.thresholds(2,max(1,val)) = str2double(get(handles.editParam7,'String'));
else
    handles.threshold(2) = str2double(get(handles.editParam7,'String'));
end
guidata(hObject, handles);
if ~isequal(0, handles.ridge)
    label = get(handles.popupmenuSegment,'Value') - 1;
    if label
        thresholdSegment(handles.ridge, handles.thresholds, label, handles);
    else
        if checkbox
            T1 = handles.thresholds(1,label);
            T2 = handles.thresholds(2,label);
        else
            T1 = handles.threshold(1);
            T2 = handles.threshold(2);
        end
        threshold(handles.ridge, T1, T2, handles);
    end
end
function editParam7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editParam7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% parameter sliders for thresholding
function sliderParam6ContValCallback(hFigure,eventdata)
% hFigure    handle to sliderParam1
% eventdata  reserved
handles = guidata(hFigure);
set(handles.editParam6,'String',round(get(handles.sliderParam6,'Value'),3));
function sliderParam6_Callback(hObject, eventdata, handles)
% hObject    handle to sliderParam6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.popupmenuSegment,'Value') - 1;
checkbox = get(handles.checkboxSegment,'Value');
if checkbox
    handles.thresholds(1,max(1,val)) = get(handles.sliderParam6,'Value');
else
    handles.threshold(1) = get(handles.sliderParam6,'Value');
end
guidata(hObject, handles);
if ~isequal(0, handles.ridge)
    label = get(handles.popupmenuSegment,'Value') - 1;
    if label
        thresholdSegment(handles.ridge, handles.thresholds, label, handles);
    else
        if checkbox
            T1 = handles.thresholds(1,label);
            T2 = handles.thresholds(2,label);
        else
            T1 = handles.threshold(1);
            T2 = handles.threshold(2);
        end
        threshold(handles.ridge, T1, T2, handles);
    end
end
function sliderParam6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderParam6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
maxVal = 0.25;
set(hObject,'Min',0,'Max',maxVal);
set(hObject,'SliderStep',[0.005/maxVal 0.1]);
set(hObject,'Value',0); % Default to 0
function sliderParam7ContValCallback(hFigure,eventdata)
% hFigure    handle to sliderParam1
% eventdata  reserved
handles = guidata(hFigure);
set(handles.editParam7,'String',round(get(handles.sliderParam7,'Value'),3));
function sliderParam7_Callback(hObject, eventdata, handles)
% hObject    handle to sliderParam7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.popupmenuSegment,'Value') - 1;
checkbox = get(handles.checkboxSegment,'Value');
if checkbox
    handles.thresholds(2,max(1,val)) = get(handles.sliderParam7,'Value');
else
    handles.threshold(2) = get(handles.sliderParam7,'Value');
end
guidata(hObject, handles);
if ~isequal(0, handles.ridge)
    label = get(handles.popupmenuSegment,'Value') - 1;
    if label
        thresholdSegment(handles.ridge, handles.thresholds, label, handles);
    else
        if checkbox
            T1 = handles.thresholds(1,label);
            T2 = handles.thresholds(2,label);
        else
            T1 = handles.threshold(1);
            T2 = handles.threshold(2);
        end
        threshold(handles.ridge, T1, T2, handles);
    end
end
function sliderParam7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderParam7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
maxVal = 0.25;
set(hObject,'Min',0,'Max',maxVal);
set(hObject,'SliderStep',[0.005/maxVal 0.1]);
set(hObject,'Value',0); % Default to 0

function checkboxBright_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxBright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if 0 end

function checkboxSegment_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.popupmenuSegment,'Value',1);
set(handles.sliderParam6,'Value',handles.threshold(1));
set(handles.sliderParam7,'Value',handles.threshold(2));
set(handles.editParam6,'String',handles.threshold(1));
set(handles.editParam7,'String',handles.threshold(2));
if get(hObject,'Value')
    set(findall(handles.uipanelSegment,'-property','Enable'),'Enable','on');
    set(handles.popupmenuSegment,'Enable','on');
    if isequal(0, handles.segment)
        set(findall(handles.uipanelCrackThreshold,'-property','Enable'),'Enable','off');
    end
    set(findall(handles.uipanelParam6,'-property','Enable'),'Enable','off');
    set(findall(handles.uipanelParam7,'-property','Enable'),'Enable','off');
else
    set(findall(handles.uipanelCrackThreshold,'-property','Enable'),'Enable','on');
    set(findall(handles.uipanelSegment,'-property','Enable'),'Enable','off');
    set(handles.popupmenuSegment,'Enable','off');
end
function popupmenuSegment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Full image'},'Enable','off');

function popupmenuSegment_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(hObject,'Value') - 1;
image = handles.image;
marked = handles.marked;
segment = handles.segment;

if val
    set(findall(handles.uipanelParam6,'-property','Enable'),'Enable','on');
    set(findall(handles.uipanelParam7,'-property','Enable'),'Enable','on');
    T = handles.thresholds;
    T1 = T(1,val);
    T2 = T(2,val);
    s = cat(3,segment==val,segment==val,segment==val);
    if ~isequal(0, marked)
        view(im2double(marked).*s, handles.viewer);
    else
        view(im2double(image).*s, handles.viewer);
    end
else
    set(findall(handles.uipanelParam6,'-property','Enable'),'Enable','off');
    set(findall(handles.uipanelParam7,'-property','Enable'),'Enable','off');
    T = handles.threshold;
    T1 = T(1);
    T2 = T(2);
    if ~isequal(0, marked)
        view(marked, handles.viewer);
    else
        view(image, handles.viewer);
    end
end
set(handles.sliderParam6,'Value',T1);
set(handles.sliderParam7,'Value',T2);
set(handles.editParam6,'String',T1);
set(handles.editParam7,'String',T2);

function [clustCent,data2cluster,cluster2dataCell] = MeanShiftCluster(dataPts,bandWidth,plotFlag);
%perform MeanShift Clustering of data using a flat kernel
%
% ---INPUT---
% dataPts           - input data, (numDim x numPts)
% bandWidth         - is bandwidth parameter (scalar)
% plotFlag          - display output if 2 or 3 D    (logical)
% ---OUTPUT---
% clustCent         - is locations of cluster centers (numDim x numClust)
% data2cluster      - for every data point which cluster it belongs to (numPts)
% cluster2dataCell  - for every cluster which points are in it (numClust)
% 
% Bryan Feldman 02/24/06
% MeanShift first appears in
% K. Funkunaga and L.D. Hosteler, "The Estimation of the Gradient of a
% Density Function, with Applications in Pattern Recognition"


%*** Check input ****
if nargin < 2
    error('no bandwidth specified')
end

if nargin < 3
    plotFlag = true;
    plotFlag = false;
end

%**** Initialize stuff ***
[numDim,numPts] = size(dataPts);
numClust        = 0;
bandSq          = bandWidth^2;
initPtInds      = 1:numPts;
maxPos          = max(dataPts,[],2);                          %biggest size in each dimension
minPos          = min(dataPts,[],2);                          %smallest size in each dimension
boundBox        = maxPos-minPos;                        %bounding box size
sizeSpace       = norm(boundBox);                       %indicator of size of data space
stopThresh      = 1e-3*bandWidth;                       %when mean has converged
clustCent       = [];                                   %center of clust
beenVisitedFlag = zeros(1,numPts,'uint8');              %track if a points been seen already
numInitPts      = numPts;                               %number of points to posibaly use as initilization points
clusterVotes    = zeros(1,numPts,'uint16');             %used to resolve conflicts on cluster membership


while numInitPts

    tempInd         = ceil( (numInitPts-1e-6)*rand);        %pick a random seed point
    stInd           = initPtInds(tempInd);                  %use this point as start of mean
    myMean          = dataPts(:,stInd);                           % intilize mean to this points location
    myMembers       = [];                                   % points that will get added to this cluster                          
    thisClusterVotes    = zeros(1,numPts,'uint16');         %used to resolve conflicts on cluster membership

    while 1     %loop untill convergence
%         sqDistToAll = sum(())
        sqDistToAll = sum((repmat(myMean,1,numPts) - dataPts).^2);    %dist squared from mean to all points still active
        inInds      = find(sqDistToAll < bandSq);               %points within bandWidth
        thisClusterVotes(inInds) = thisClusterVotes(inInds)+1;  %add a vote for all the in points belonging to this cluster
        
        
        myOldMean   = myMean;                                   %save the old mean
        myMean      = mean(dataPts(:,inInds),2);                %compute the new mean
        myMembers   = [myMembers inInds];                       %add any point within bandWidth to the cluster
        beenVisitedFlag(myMembers) = 1;                         %mark that these points have been visited
        
        %*** plot stuff ****
        if plotFlag
            figure(12345),clf,hold on
            if numDim == 2
                plot(dataPts(1,:),dataPts(2,:),'.')
                plot(dataPts(1,myMembers),dataPts(2,myMembers),'ys')
                plot(myMean(1),myMean(2),'go')
                plot(myOldMean(1),myOldMean(2),'rd')
                pause
            end
        end

        %**** if mean doesn't move much stop this cluster ***
        if norm(myMean-myOldMean) < stopThresh
            
            %check for merge posibilities
            mergeWith = 0;
            for cN = 1:numClust
                distToOther = norm(myMean-clustCent(:,cN));     %distance from posible new clust max to old clust max
                if distToOther < bandWidth/2                    %if its within bandwidth/2 merge new and old
                    mergeWith = cN;
                    break;
                end
            end
            
            
            if mergeWith > 0    % something to merge
                clustCent(:,mergeWith)       = 0.5*(myMean+clustCent(:,mergeWith));             %record the max as the mean of the two merged (I know biased twoards new ones)
                %clustMembsCell{mergeWith}    = unique([clustMembsCell{mergeWith} myMembers]);   %record which points inside 
                clusterVotes(mergeWith,:)    = clusterVotes(mergeWith,:) + thisClusterVotes;    %add these votes to the merged cluster
            else    %its a new cluster
                numClust                    = numClust+1;                   %increment clusters
                clustCent(:,numClust)       = myMean;                       %record the mean  
                %clustMembsCell{numClust}    = myMembers;                    %store my members
                clusterVotes(numClust,:)    = thisClusterVotes;
            end

            break;
        end

    end
    
    
    initPtInds      = find(beenVisitedFlag == 0);           %we can initialize with any of the points not yet visited
    numInitPts      = length(initPtInds);                   %number of active points in set

end

[val,data2cluster] = max(clusterVotes,[],1);                %a point belongs to the cluster with the most votes

%*** If they want the cluster2data cell find it for them
if nargout > 2
    cluster2dataCell = cell(numClust,1);
    for cN = 1:numClust
        myMembers = find(data2cluster == cN);
        cluster2dataCell{cN} = myMembers;
    end
end

% Compute the Rosin threshold for an input histogram.
% T is the histogram index that should be used as a threshold.
% The optional second argument "picknonempty" is a binary variable
% indicating that the chosen bin should be non-zero.
%
% REF: Paul L. Rosin, "Unimodal thresholding", Pattern Recognition 34(11): 2083-2096 (2001)
%
function T = RosinThreshold(imhist, picknonempty)

% should I ensure the chosen(threshold) bin is non empty?
if (nargin < 2)
    picknonempty = 0;
end

% find best threshold

[mmax2, mpos] = max(imhist);
p1 = [mpos, mmax2];

% find last non-empty bin
L = length(imhist);
lastbin = mpos;
for i = mpos:L
    if (imhist(i) > 0)
        lastbin=i;
    end
end
    
p2 = [lastbin, imhist(lastbin)];
DD = sqrt((p2(1)-p1(1))^2 + (p2(2)-p1(2))^2);

if (DD ~= 0)
	best = -1;
	found = -1;
	for i = mpos:lastbin
        p0 = [i,  imhist(i)];
        d = abs((p2(1)-p1(1))*(p1(2)-p0(2)) - (p1(1)-p0(1))*(p2(2)-p1(2)));
        d = d / DD;
        
        if ((d > best) && ((imhist(i)>0) || (picknonempty==0)))
            best=d;
            found = i;
        end
	end
	
	if (found == -1)
        found = lastbin+1;
	end
else
    found = lastbin+1;
end


T = min(found, L);

function kernel = SOAGK(sigma, theta, rho, size, step)

realsize = [length(1:step:size(2))+1 length(1:step:size(1))+1];

kernel = zeros(realsize(1), realsize(2));

Mtheta = [cos(theta) sin(theta); -sin(theta) cos(theta)];
Mtheta2 = [cos(-theta) sin(-theta); -sin(-theta) cos(-theta)];

for j = 1:realsize(2)
    for i = 1:realsize(1)
        
        x = (i-(realsize(1)+1)/2)*step;
        y = (j-(realsize(2)+1)/2)*step;
        
        phi = [x y]*Mtheta2*[rho^2 0; 0 rho^(-2)]*Mtheta*[x ; y];
        temp = (cos(theta)*x+sin(theta)*y)^2/(rho^(-2)*sigma^2);
        kernel(j,i) = rho^2/sigma^2*(temp-1)/(2*pi*sigma^2)* exp(-phi/(2*sigma^2));
        
    end
end
kernel = kernel/sum(sum(abs(kernel)));

function varargout = colorspace(Conversion,varargin)
%COLORSPACE  Transform a color image between color representations.
%   B = COLORSPACE(S,A) transforms the color representation of image A
%   where S is a string specifying the conversion.  The input array A 
%   should be a real full double array of size Mx3 or MxNx3.  The output B 
%   is the same size as A.
%
%   S tells the source and destination color spaces, S = 'dest<-src', or 
%   alternatively, S = 'src->dest'.  Supported color spaces are
%
%     'RGB'              sRGB IEC 61966-2-1
%     'YCbCr'            Luma + Chroma ("digitized" version of Y'PbPr)
%     'JPEG-YCbCr'       Luma + Chroma space used in JFIF JPEG
%     'YDbDr'            SECAM Y'DbDr Luma + Chroma
%     'YPbPr'            Luma (ITU-R BT.601) + Chroma 
%     'YUV'              NTSC PAL Y'UV Luma + Chroma
%     'YIQ'              NTSC Y'IQ Luma + Chroma
%     'HSV' or 'HSB'     Hue Saturation Value/Brightness
%     'HSL' or 'HLS'     Hue Saturation Luminance
%     'HSI'              Hue Saturation Intensity
%     'XYZ'              CIE 1931 XYZ
%     'Lab'              CIE 1976 L*a*b* (CIELAB)
%     'Luv'              CIE L*u*v* (CIELUV)
%     'LCH'              CIE L*C*H* (CIELCH)
%     'CAT02 LMS'        CIE CAT02 LMS
%
%  All conversions assume 2 degree observer and D65 illuminant.
%
%  Color space names are case insensitive and spaces are ignored.  When 
%  sRGB is the source or destination, it can be omitted. For example 
%  'yuv<-' is short for 'yuv<-rgb'.
%
%  For sRGB, the values should be scaled between 0 and 1.  Beware that 
%  transformations generally do not constrain colors to be "in gamut."  
%  Particularly, transforming from another space to sRGB may obtain 
%  R'G'B' values outside of the [0,1] range.  So the result should be 
%  clamped to [0,1] before displaying:
%     image(min(max(B,0),1));  % Clamp B to [0,1] and display
%
%  sRGB (Red Green Blue) is the (ITU-R BT.709 gamma-corrected) standard
%  red-green-blue representation of colors used in digital imaging.  The 
%  components should be scaled between 0 and 1.  The space can be 
%  visualized geometrically as a cube.
%  
%  Y'PbPr, Y'CbCr, Y'DbDr, Y'UV, and Y'IQ are related to sRGB by linear
%  transformations.  These spaces separate a color into a grayscale
%  luminance component Y and two chroma components.  The valid ranges of
%  the components depends on the space.
%
%  HSV (Hue Saturation Value) is related to sRGB by
%     H = hexagonal hue angle   (0 <= H < 360),
%     S = C/V                   (0 <= S <= 1),
%     V = max(R',G',B')         (0 <= V <= 1),
%  where C = max(R',G',B') - min(R',G',B').  The hue angle H is computed on
%  a hexagon.  The space is geometrically a hexagonal cone.
%
%  HSL (Hue Saturation Lightness) is related to sRGB by
%     H = hexagonal hue angle                (0 <= H < 360),
%     S = C/(1 - |2L-1|)                     (0 <= S <= 1),
%     L = (max(R',G',B') + min(R',G',B'))/2  (0 <= L <= 1),
%  where H and C are the same as in HSV.  Geometrically, the space is a
%  double hexagonal cone.
%
%  HSI (Hue Saturation Intensity) is related to sRGB by
%     H = polar hue angle        (0 <= H < 360),
%     S = 1 - min(R',G',B')/I    (0 <= S <= 1),
%     I = (R'+G'+B')/3           (0 <= I <= 1).
%  Unlike HSV and HSL, the hue angle H is computed on a circle rather than
%  a hexagon. 
%
%  CIE XYZ is related to sRGB by inverse gamma correction followed by a
%  linear transform.  Other CIE color spaces are defined relative to XYZ.
%
%  CIE L*a*b*, L*u*v*, and L*C*H* are nonlinear functions of XYZ.  The L*
%  component is designed to match closely with human perception of
%  lightness.  The other two components describe the chroma.
%
%  CIE CAT02 LMS is the linear transformation of XYZ using the MCAT02 
%  chromatic adaptation matrix.  The space is designed to model the 
%  response of the three types of cones in the human eye, where L, M, S,
%  correspond respectively to red ("long"), green ("medium"), and blue
%  ("short").

% Pascal Getreuer 2005-2010


%%% Input parsing %%%
if nargin < 2, error('Not enough input arguments.'); end
[SrcSpace,DestSpace] = parse(Conversion);

if nargin == 2
   Image = varargin{1};
elseif nargin >= 3
   Image = cat(3,varargin{:});
else
   error('Invalid number of input arguments.');
end

FlipDims = (size(Image,3) == 1);

if FlipDims, Image = permute(Image,[1,3,2]); end
if ~isa(Image,'double'), Image = double(Image)/255; end
if size(Image,3) ~= 3, error('Invalid input size.'); end

SrcT = gettransform(SrcSpace);
DestT = gettransform(DestSpace);

if ~ischar(SrcT) && ~ischar(DestT)
   % Both source and destination transforms are affine, so they
   % can be composed into one affine operation
   T = [DestT(:,1:3)*SrcT(:,1:3),DestT(:,1:3)*SrcT(:,4)+DestT(:,4)];      
   Temp = zeros(size(Image));
   Temp(:,:,1) = T(1)*Image(:,:,1) + T(4)*Image(:,:,2) + T(7)*Image(:,:,3) + T(10);
   Temp(:,:,2) = T(2)*Image(:,:,1) + T(5)*Image(:,:,2) + T(8)*Image(:,:,3) + T(11);
   Temp(:,:,3) = T(3)*Image(:,:,1) + T(6)*Image(:,:,2) + T(9)*Image(:,:,3) + T(12);
   Image = Temp;
elseif ~ischar(DestT)
   Image = rgb(Image,SrcSpace);
   Temp = zeros(size(Image));
   Temp(:,:,1) = DestT(1)*Image(:,:,1) + DestT(4)*Image(:,:,2) + DestT(7)*Image(:,:,3) + DestT(10);
   Temp(:,:,2) = DestT(2)*Image(:,:,1) + DestT(5)*Image(:,:,2) + DestT(8)*Image(:,:,3) + DestT(11);
   Temp(:,:,3) = DestT(3)*Image(:,:,1) + DestT(6)*Image(:,:,2) + DestT(9)*Image(:,:,3) + DestT(12);
   Image = Temp;
else
   Image = feval(DestT,Image,SrcSpace);
end

%%% Output format %%%
if nargout > 1
   varargout = {Image(:,:,1),Image(:,:,2),Image(:,:,3)};
else
   if FlipDims, Image = permute(Image,[1,3,2]); end
   varargout = {Image};
end

return;


function [SrcSpace,DestSpace] = parse(Str)
% Parse conversion argument

if ischar(Str)
   Str = lower(strrep(strrep(Str,'-',''),'=',''));
   k = find(Str == '>');
   
   if length(k) == 1         % Interpret the form 'src->dest'
      SrcSpace = Str(1:k-1);
      DestSpace = Str(k+1:end);
   else
      k = find(Str == '<');
      
      if length(k) == 1      % Interpret the form 'dest<-src'
         DestSpace = Str(1:k-1);
         SrcSpace = Str(k+1:end);
      else
         error(['Invalid conversion, ''',Str,'''.']);
      end   
   end
   
   SrcSpace = alias(SrcSpace);
   DestSpace = alias(DestSpace);
else
   SrcSpace = 1;             % No source pre-transform
   DestSpace = Conversion;
   if any(size(Conversion) ~= 3), error('Transformation matrix must be 3x3.'); end
end
return;


function Space = alias(Space)
Space = strrep(strrep(Space,'cie',''),' ','');

if isempty(Space)
   Space = 'rgb';
end

switch Space
case {'ycbcr','ycc'}
   Space = 'ycbcr';
case {'hsv','hsb'}
   Space = 'hsv';
case {'hsl','hsi','hls'}
   Space = 'hsl';
case {'rgb','yuv','yiq','ydbdr','ycbcr','jpegycbcr','xyz','lab','luv','lch'}
   return;
end
return;

function T = gettransform(Space)
% Get a colorspace transform: either a matrix describing an affine transform,
% or a string referring to a conversion subroutine
switch Space
case 'ypbpr'
   T = [0.299,0.587,0.114,0;-0.1687367,-0.331264,0.5,0;0.5,-0.418688,-0.081312,0];
case 'yuv'
   % sRGB to NTSC/PAL YUV
   % Wikipedia: http://en.wikipedia.org/wiki/YUV
   T = [0.299,0.587,0.114,0;-0.147,-0.289,0.436,0;0.615,-0.515,-0.100,0];
case 'ydbdr'
   % sRGB to SECAM YDbDr
   % Wikipedia: http://en.wikipedia.org/wiki/YDbDr
   T = [0.299,0.587,0.114,0;-0.450,-0.883,1.333,0;-1.333,1.116,0.217,0];
case 'yiq'
   % sRGB in [0,1] to NTSC YIQ in [0,1];[-0.595716,0.595716];[-0.522591,0.522591];
   % Wikipedia: http://en.wikipedia.org/wiki/YIQ
   T = [0.299,0.587,0.114,0;0.595716,-0.274453,-0.321263,0;0.211456,-0.522591,0.311135,0];
case 'ycbcr'
   % sRGB (range [0,1]) to ITU-R BRT.601 (CCIR 601) Y'CbCr
   % Wikipedia: http://en.wikipedia.org/wiki/YCbCr
   % Poynton, Equation 3, scaling of R'G'B to Y'PbPr conversion
   T = [65.481,128.553,24.966,16;-37.797,-74.203,112.0,128;112.0,-93.786,-18.214,128];
case 'jpegycbcr'
   % Wikipedia: http://en.wikipedia.org/wiki/YCbCr
   T = [0.299,0.587,0.114,0;-0.168736,-0.331264,0.5,0.5;0.5,-0.418688,-0.081312,0.5]*255;
case {'rgb','xyz','hsv','hsl','lab','luv','lch','cat02lms'}
   T = Space;
otherwise
   error(['Unknown color space, ''',Space,'''.']);
end
return;

function Image = rgb(Image,SrcSpace)
% Convert to sRGB from 'SrcSpace'
switch SrcSpace
case 'rgb'
   return;
case 'hsv'
   % Convert HSV to sRGB
   Image = huetorgb((1 - Image(:,:,2)).*Image(:,:,3),Image(:,:,3),Image(:,:,1));
case 'hsl'
   % Convert HSL to sRGB
   L = Image(:,:,3);
   Delta = Image(:,:,2).*min(L,1-L);
   Image = huetorgb(L-Delta,L+Delta,Image(:,:,1));
case {'xyz','lab','luv','lch','cat02lms'}
   % Convert to CIE XYZ
   Image = xyz(Image,SrcSpace);
   % Convert XYZ to RGB
   T = [3.2406, -1.5372, -0.4986; -0.9689, 1.8758, 0.0415; 0.0557, -0.2040, 1.057];
   R = T(1)*Image(:,:,1) + T(4)*Image(:,:,2) + T(7)*Image(:,:,3);  % R
   G = T(2)*Image(:,:,1) + T(5)*Image(:,:,2) + T(8)*Image(:,:,3);  % G
   B = T(3)*Image(:,:,1) + T(6)*Image(:,:,2) + T(9)*Image(:,:,3);  % B
   % Desaturate and rescale to constrain resulting RGB values to [0,1]   
   AddWhite = -min(min(min(R,G),B),0);
   R = R + AddWhite;
   G = G + AddWhite;
   B = B + AddWhite;
   % Apply gamma correction to convert linear RGB to sRGB
   Image(:,:,1) = gammacorrection(R);  % R'
   Image(:,:,2) = gammacorrection(G);  % G'
   Image(:,:,3) = gammacorrection(B);  % B'
otherwise  % Conversion is through an affine transform
   T = gettransform(SrcSpace);
   temp = inv(T(:,1:3));
   T = [temp,-temp*T(:,4)];
   R = T(1)*Image(:,:,1) + T(4)*Image(:,:,2) + T(7)*Image(:,:,3) + T(10);
   G = T(2)*Image(:,:,1) + T(5)*Image(:,:,2) + T(8)*Image(:,:,3) + T(11);
   B = T(3)*Image(:,:,1) + T(6)*Image(:,:,2) + T(9)*Image(:,:,3) + T(12);
   Image(:,:,1) = R;
   Image(:,:,2) = G;
   Image(:,:,3) = B;
end

% Clip to [0,1]
Image = min(max(Image,0),1);
return;

function Image = xyz(Image,SrcSpace)
% Convert to CIE XYZ from 'SrcSpace'
WhitePoint = [0.950456,1,1.088754];  

switch SrcSpace
case 'xyz'
   return;
case 'luv'
   % Convert CIE L*uv to XYZ
   WhitePointU = (4*WhitePoint(1))./(WhitePoint(1) + 15*WhitePoint(2) + 3*WhitePoint(3));
   WhitePointV = (9*WhitePoint(2))./(WhitePoint(1) + 15*WhitePoint(2) + 3*WhitePoint(3));
   L = Image(:,:,1);
   Y = (L + 16)/116;
   Y = invf(Y)*WhitePoint(2);
   U = Image(:,:,2)./(13*L + 1e-6*(L==0)) + WhitePointU;
   V = Image(:,:,3)./(13*L + 1e-6*(L==0)) + WhitePointV;
   Image(:,:,1) = -(9*Y.*U)./((U-4).*V - U.*V);                  % X
   Image(:,:,2) = Y;                                             % Y
   Image(:,:,3) = (9*Y - (15*V.*Y) - (V.*Image(:,:,1)))./(3*V);  % Z
case {'lab','lch'}
   Image = lab(Image,SrcSpace);
   % Convert CIE L*ab to XYZ
   fY = (Image(:,:,1) + 16)/116;
   fX = fY + Image(:,:,2)/500;
   fZ = fY - Image(:,:,3)/200;
   Image(:,:,1) = WhitePoint(1)*invf(fX);  % X
   Image(:,:,2) = WhitePoint(2)*invf(fY);  % Y
   Image(:,:,3) = WhitePoint(3)*invf(fZ);  % Z
case 'cat02lms'
    % Convert CAT02 LMS to XYZ
   T = inv([0.7328, 0.4296, -0.1624;-0.7036, 1.6975, 0.0061; 0.0030, 0.0136, 0.9834]);
   L = Image(:,:,1);
   M = Image(:,:,2);
   S = Image(:,:,3);
   Image(:,:,1) = T(1)*L + T(4)*M + T(7)*S;  % X 
   Image(:,:,2) = T(2)*L + T(5)*M + T(8)*S;  % Y
   Image(:,:,3) = T(3)*L + T(6)*M + T(9)*S;  % Z
otherwise   % Convert from some gamma-corrected space
   % Convert to sRGB
   Image = rgb(Image,SrcSpace);
   % Undo gamma correction
   R = invgammacorrection(Image(:,:,1));
   G = invgammacorrection(Image(:,:,2));
   B = invgammacorrection(Image(:,:,3));
   % Convert RGB to XYZ
   T = inv([3.2406, -1.5372, -0.4986; -0.9689, 1.8758, 0.0415; 0.0557, -0.2040, 1.057]);
   Image(:,:,1) = T(1)*R + T(4)*G + T(7)*B;  % X 
   Image(:,:,2) = T(2)*R + T(5)*G + T(8)*B;  % Y
   Image(:,:,3) = T(3)*R + T(6)*G + T(9)*B;  % Z
end
return;

function Image = lab(Image,SrcSpace)
% Convert to CIE L*a*b* (CIELAB)
WhitePoint = [0.950456,1,1.088754];

switch SrcSpace
case 'lab'
   return;
case 'lch'
   % Convert CIE L*CH to CIE L*ab
   C = Image(:,:,2);
   Image(:,:,2) = cos(Image(:,:,3)*pi/180).*C;  % a*
   Image(:,:,3) = sin(Image(:,:,3)*pi/180).*C;  % b*
otherwise
   Image = xyz(Image,SrcSpace);  % Convert to XYZ
   % Convert XYZ to CIE L*a*b*
   X = Image(:,:,1)/WhitePoint(1);
   Y = Image(:,:,2)/WhitePoint(2);
   Z = Image(:,:,3)/WhitePoint(3);
   fX = f(X);
   fY = f(Y);
   fZ = f(Z);
   Image(:,:,1) = 116*fY - 16;    % L*
   Image(:,:,2) = 500*(fX - fY);  % a*
   Image(:,:,3) = 200*(fY - fZ);  % b*
end
return;

function Image = luv(Image,SrcSpace)
% Convert to CIE L*u*v* (CIELUV)
WhitePoint = [0.950456,1,1.088754];
WhitePointU = (4*WhitePoint(1))./(WhitePoint(1) + 15*WhitePoint(2) + 3*WhitePoint(3));
WhitePointV = (9*WhitePoint(2))./(WhitePoint(1) + 15*WhitePoint(2) + 3*WhitePoint(3));

Image = xyz(Image,SrcSpace); % Convert to XYZ
Denom = Image(:,:,1) + 15*Image(:,:,2) + 3*Image(:,:,3);
U = (4*Image(:,:,1))./(Denom + (Denom == 0));
V = (9*Image(:,:,2))./(Denom + (Denom == 0));
Y = Image(:,:,2)/WhitePoint(2);
L = 116*f(Y) - 16;
Image(:,:,1) = L;                        % L*
Image(:,:,2) = 13*L.*(U - WhitePointU);  % u*
Image(:,:,3) = 13*L.*(V - WhitePointV);  % v*
return;  

function Image = huetorgb(m0,m2,H)
% Convert HSV or HSL hue to RGB
N = size(H);
H = min(max(H(:),0),360)/60;
m0 = m0(:);
m2 = m2(:);
F = H - round(H/2)*2;
M = [m0, m0 + (m2-m0).*abs(F), m2];
Num = length(m0);
j = [2 1 0;1 2 0;0 2 1;0 1 2;1 0 2;2 0 1;2 1 0]*Num;
k = floor(H) + 1;
Image = reshape([M(j(k,1)+(1:Num).'),M(j(k,2)+(1:Num).'),M(j(k,3)+(1:Num).')],[N,3]);
return;

function H = rgbtohue(Image)
% Convert RGB to HSV or HSL hue
[M,i] = sort(Image,3);
i = i(:,:,3);
Delta = M(:,:,3) - M(:,:,1);
Delta = Delta + (Delta == 0);
R = Image(:,:,1);
G = Image(:,:,2);
B = Image(:,:,3);
H = zeros(size(R));
k = (i == 1);
H(k) = (G(k) - B(k))./Delta(k);
k = (i == 2);
H(k) = 2 + (B(k) - R(k))./Delta(k);
k = (i == 3);
H(k) = 4 + (R(k) - G(k))./Delta(k);
H = 60*H + 360*(H < 0);
H(Delta == 0) = nan;
return;

function Rp = gammacorrection(R)
Rp = zeros(size(R));
i = (R <= 0.0031306684425005883);
Rp(i) = 12.92*R(i);
Rp(~i) = real(1.055*R(~i).^0.416666666666666667 - 0.055);
return;

function R = invgammacorrection(Rp)
R = zeros(size(Rp));
i = (Rp <= 0.0404482362771076);
R(i) = Rp(i)/12.92;
R(~i) = real(((Rp(~i) + 0.055)/1.055).^2.4);
return;

function fY = f(Y)
fY = real(Y.^(1/3));
i = (Y < 0.008856);
fY(i) = Y(i)*(841/108) + (4/29);
return;

function Y = invf(fY)
Y = fY.^3;
i = (Y < 0.008856);
Y(i) = (fY(i) - 4/29)*(108/841);
return;

function ridge_validated = detectCrackP(image,angles,S,A,dark);
%perform crack detection on data
%
% ---INPUT---
% image             - input image (numCol x numRow double) 
% angles            - angles (scalar) *defaults to 16
% S                 - width (scalar) *defaults to 2 
% A                 - length (scalar) *defaults to 2
% dark              - dark crack detection (logical) *defaults to TRUE
% ---OUTPUT---
% ridge_validated   - validated ridge for thresholding (numCol x numRow double)
%

%*** Check input ****
if nargin < 5
    dark = true;
end

if nargin < 4
    A = 2;
end

if nargin < 3
    S = 2;
end

if nargin < 2
    angles = 16;
end

%**** Initialize stuff ***
D           = 0:pi/angles:pi-pi/angles;   % angles
n           = angles *length(S)*length(A);
im          = image;


im = im2double(im);

if (size(im,3) > 1)
    im = im(:,:,1 + dark); % Use red channel for dark crack; green channel for bright crack
end

%**** Crack detection ***
% im = histeq(im);
[im_h, im_w] = size(im);
h = fspecial('gaussian', 4, 0.3);
im = imfilter(im,h);

% pre-allocation
orientation_table = zeros(1,n);
im_filtered = zeros(im_h, im_w,n);

% filtering
index = 1;
for d = 1:length(D)
    for s = 1: length(S)
        for a = 1:length(A)
            kernel = SOAGK(S(s),D(d),A(a),[20 20],1);
            im_filtered(:,:,index) = filter2(kernel*(dark*2-1),im); % Negate if detecting bright crack
            orientation_table(index) = D(d);
            index = index+1;
        end
    end
end

[ridge_intensity,angle_index] = max(im_filtered,[],3);
ridge_orientation = orientation_table(angle_index);

% validation
h = fspecial('gaussian', [5 5], 0.6);
im_blurred = imfilter(im,h);
ridge_validated = validateFilter(ridge_intensity,im_blurred,ridge_orientation,4-dark,dark);

function bw = hysthresh(im, T1, T2)
if T1 < T2    % T1 and T2 reversed - swap values 
tmp = T1;
T1 = T2; 
T2 = tmp;
end

aboveT2 = im > T2;                     % Edge points above lower
                                       % threshold. 
[aboveT1r, aboveT1c] = find(im > T1);  % Row and colum coords of points
                                       % above upper threshold.

% Obtain all connected regions in aboveT2 that include a point that has a
% value above T1 
bw = bwselect(aboveT2, aboveT1c, aboveT1r, 8);

function [im_rgb] = markCracks(im,final_map,rgb_color)

im = im2double(im);
[im_h, im_w, n] = size(im);

if (n >= 3)
    im = rgb2gray(im);
end

im_rgb = zeros(im_h,im_w,3);
im_rgb(:,:,1) = im;
im_rgb(:,:,2) = im;
im_rgb(:,:,3) = im;

[col, row] = find(final_map == 1);

for i=1:length(col)
    im_rgb(col(i),row(i),1) = rgb_color(1);
    im_rgb(col(i),row(i),2) = rgb_color(2);
    im_rgb(col(i),row(i),3) = rgb_color(3);
end

function validated = validateFilter(filtered, S, angle, distance,option)

f = 1;
v = distance;
[im_h, im_w] = size(filtered);

validated = zeros(size(filtered));
if option  
    for j=v+1:im_h-(v+1)
        for i=v+1:im_w-(v+1)
            n = [cos(angle(j,i)), sin(angle(j,i))];

            if ((S(round(j+v*n(2)),round(i+v*n(1))) > f*S(j,i)) && (S(round(j-v*n(2)),round(i-v*n(1))) > f*S(j,i)))
                validated(j,i) = filtered(j,i);    
            end

        end
    end
else
    for j=v+1:im_h-(v+1)
        for i=v+1:im_w-(v+1)
            n = [cos(angle(j,i)), sin(angle(j,i))];

            if ((S(round(j+v*n(2)),round(i+v*n(1))) < f*S(j,i)) && (S(round(j-v*n(2)),round(i-v*n(1))) < f*S(j,i)))
                validated(j,i) = filtered(j,i);    
            end

        end
    end
end


% --- Executes on key press with focus on pushbuttonThreshold and none of its controls.
function pushbuttonThreshold_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonThreshold (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
