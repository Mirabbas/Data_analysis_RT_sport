function activityDetection
%��� 0
windowLength = 5;
detectionInterval = 1;
%������ � �������� ����� ���� ��������������, ������� 
%��� ����� �������� ������������ � ����� ���������.
uniformSampleRate = 60; % Hz. 


%%
%��� 1
% fileWalk = 'walk1.mat'; %  
% featureWalk = extractTrainingFeature(fileWalk,windowLength,uniformSampleRate);
%  
% fileRun = 'run1.mat'; %  
% featureRun = extractTrainingFeature(fileRun,windowLength,uniformSampleRate);
% 
% fileIdle = 'idle1.mat'; %
% featureIdle = extractTrainingFeature(fileIdle,windowLength,uniformSampleRate);
% 
% fileUp = 'upstairs1.mat'; %  
% featureUp = extractTrainingFeature(fileUp,windowLength,uniformSampleRate);
% 
% fileDown = 'downstairs1.mat'; %  
% featureDown = extractTrainingFeature(fileDown,windowLength,uniformSampleRate);

load('training.mat');

%��� 2: ������������� ������ ��������

data = [featureWalk; featureRun; featureIdle; featureUp; featureDown];
for i = 1:size(data,2)
    range(1,i) = max(data(:,i))-min(data(:,i)); 
    dMin(1,i) = min(data(:,i));
    data(:,i) = (data(:,i)- dMin(i)) / range(i);
end


%%
%��� 2: �������������� ����������
indexIdle =  0;
indexWalk =  2;
indexDown = -1;
indexRun  =  3;
indexUp   =  1;

Idle = indexIdle * zeros(length(featureIdle),1);
Walk = indexWalk * ones(length(featureWalk),1);
Down = indexDown * ones(length(featureDown),1);
Run  = indexRun  * ones(length(featureRun),1);
Up   = indexUp   * ones(length(featureUp),1);


%%
%��� 3: �������� ��������� ��������� ��������

X = data;
Y = [Walk;Run;Idle;Up;Down];
mdl = fitcknn(X,Y);
knnK = 30; %��������� ��������� �������, ������������ ������������� KNN
mdl.NumNeighbors = knnK;%������� ��������� ��������� �������


%%
%��� 4: �������� ���������� ������
load('newData.mat');

% ��������� ������� �������������� ������ ��� ��������� ���������� �������������� ������ ���������
newTime = 0:1/60:(t(end)-t(1));
x = a(:,1);
y = a(:,2);
z = a(:,3);
x = interp1(t,x,newTime);
y = interp1(t,y,newTime);
z = interp1(t,z,newTime);
a = [x;y;z]';
t = newTime;


%%
%��� 5: ����������� ����������
i = 1;
lastFrame = find(t>(t(end)-windowLength-0.005), 1);
% ��������� ��������� ����������
lastDetectedActivity = 0;

frameIndex = [];
result = [];
score = [];

while (i < lastFrame)
    startIndex = i;
    frameIndex(end+1,:) = startIndex;
    t0 = t(startIndex);
    nextFrameIndex = find(t > t0 + detectionInterval);
    nextFrameIndex = nextFrameIndex(1) - 1;
    stopIndex = find(t > t0 + windowLength);
    stopIndex = stopIndex(1) - 1;
    currentFeature = extractFeatures(a(startIndex:stopIndex, :, :),...
                     t(startIndex:stopIndex), uniformSampleRate);
    currentFeature = (currentFeature - dMin) ./ range;
    [tempResult,tempScore] = predict(mdl, currentFeature);
    % ������, ���������� ��������������� KNN, ����������� �� 0 �� 1. 
    %����� ������� ���� �������� ������� ����������� � �����������.
    if max(tempScore) < 0.95 || tempResult ~= lastDetectedActivity 
        % ������� ��������� ��� ��������
        result(end+1, :) = -10; 
    else
        result(end+1, :) = tempResult;
    end
    lastDetectedActivity = tempResult;
    score(end+1, :) = tempScore;
    i = nextFrameIndex + 1;
end


% ��� 6: �������� ������� � ���������� ����������� � ������� .doc
 WordFileName='Report.doc'; 
   CurDir=pwd;
   FileSpec = fullfile(CurDir,WordFileName);
   [ActXWord,WordHandle]=StartWord(FileSpec); 
   fprintf('�������� ����� �������� � %s\n',FileSpec);
    Style='Heading 1';
    TextString='������ ������������ �������� � ������� ��������� ��������� � ������ ��������� �������';
    WordText(ActXWord,TextString,Style,[0,1]); 
     style='Heading 1';
    text='������ �� Matlab';
    WordText(ActXWord,text,style,[1,1]);%������� ����� �� � �����
    Style='Heading 2';
    TextString='�������� � ��������� ����';
    WordText(ActXWord,TextString,Style,[0,1]);%������� ����� ������
    Style='Normal';
    TextString = '���� ����������� ������ �������� ������, ��������� � ���������� ���������� � ������� ������, � ������������ ��������. ';
    WordText(ActXWord,TextString,Style,[0,1]);
    TextString='��� �������� ��� ����������� ��������������:';
    WordText(ActXWord,TextString,Style,[0,1]);
    TextString='x � ������, * � ���, o � �����, ';
    WordText(ActXWord,TextString,Style,[0,0]);
    WordSymbol(ActXWord,94);
    TextString='� ������ �� ��������, v � ����� �� �������� , � � �������';
    WordText(ActXWord,TextString,Style,[0,1]);%enter after text
    %figure;
    %hold on
    %plot(load('training.mat'));
    %title('������ �������� ������ ��� �������������');
    %resX = (result ==
    %hold off
    figure;
    plot(t,a);
    ylim([-30 30]);
    hold all;

resWalk =(result == 2);
resRun  =(result == 3);
resIdle =(result == 0);
resDown =(result ==-1);
resUp   =(result == 1); 
resUnknown =(result == -10);

% ����������� ������������ 
hWalk = plot(t(frameIndex(resWalk))+windowLength, 0*result(resWalk)-25, 'kx');
hRun  = plot(t(frameIndex(resRun))+windowLength, 0*result(resRun)-25, 'r*');
hIdle = plot(t(frameIndex(resIdle))+windowLength, 0*result(resIdle)-25, 'bo');
hDown = plot(t(frameIndex(resDown))+windowLength, 0*result(resDown)-25, 'cv');
hUp   = plot(t(frameIndex(resUp))+windowLength, 0*result(resUp)-25, 'm^');
hTransition = plot(t(frameIndex(resUnknown))+windowLength, 0*result(resUnknown)-25, 'k.');
ylim([-30 20]);

title('������ ������������ � ���������������� �������������');
% ���������� ������� �� ������
legend([hWalk, hRun, hIdle, hDown, hUp, hTransition], ...
    '������','���','�����','������ �� ��������','����� �� ��������',...
    '�������');
FigureIntoWord(ActXWord); 
CloseWord(ActXWord,WordHandle,FileSpec);
end