function [ ...
        WinT0, ...
        WindowOut, ...
        TimeStamp, ...
        RemainingSamples, ...
        RemainingTime, ...
        Valid, ...
        Continue] = ...
    WindowBuild (...
        WinT0, ...              % WindowTime that Valid becomes true less SettlingTime
        WindowIn, ...           % Window Sample Data
        WindowTime, ...         % The time at the CENTER of the window    
        SettlingTime, ...
        F0, ...                 % Nominal Frequency
        AnalysisCycles, ...     % Number of Cycles to Analyse             
        AnalysisTime, ...       % Time to Analyse (will be at the center of the Window)
        Y, ...                  % Incoming Samples
        dt, ...                 % Sample Period
        SampleT0)               % Time of the first sample in Y
    
Valid = 'f';
Continue = 't';
RemainingSamples = [];
RemainingTime = [];

% The window size
nWindow = round(AnalysisCycles/(dt*F0));

% The samples needed in the window
nSamplesNeeded = round((AnalysisTime - WindowTime)/dt);

% if we need more samples than the window size, then we only need the
% window size
if nSamplesNeeded > nWindow; nSamplesNeeded = nWindow; end

% %Get the time of the last sample in Y
% nY = length(Y);       % length of Y
% yTlast = t0 + nY*dt;    % timestamp of the last sample in Y
% wTlast = AnalysisTime + (nWindow/2)*dt; % timestamp of the last sample in the window
% 
% % If the difference between the last time in the window and the last time
% % in Y is negative, the new samples do not exist in Y so return and get the
% % next analysis time
% if (wTlast - yTlast) < 0; return; end
% 
% if isempty(WindowIn)
%     [m,~] = size(Y);
%     WindowIn = zeros(m,nWindow);
% end
% 
% 
% WindowOut = WindowIn;
% if nSamplesNeeded >= nWindow
%     TimeStamp = AnalysisTime;
%     nSamplesNeeded = nWindow;
% else    % if the Window is full, then remove the old samples from the beginning
%     WindowIn = WindowIn(:,nSamplesNeeded+1:end);
%     TimeStamp = WindowTime + nSamplesNeeded * dt;
% end

% determine the timestamp that we need
timeStampNeeded = (nWindow/2-nSamplesNeeded)*dt+AnalysisTime;

% DEBUG display the timestamp
tN = datetime(timeStampNeeded, 'ConvertFrom', 'epochtime', 'Epoch', '1904-01-01'); tN.Format='dd-MMM-uuuu HH:mm:ss.SSS';
msg = sprintf('tN: %s ',char(tN));
disp (msg);
% DEBUG

% find the index of the first needed sample of Y
%   This assumes that t0(1) is the time of the first sample of Y
nY = length(Y);
iY = round((timeStampNeeded - SampleT0)/dt)+1; 

% If the Window is just starting, fill WindowIn with 0's
if isempty(WindowIn)
    [m,~] = size(Y);
    WindowIn = zeros(m,nWindow);
    WinT0 = -1;
end
% 
if iY < 0
    % the AnalysisTime is before the data started so put the data back into 
    % the queue and wait for the next analysis timeWindowOut = WindowIn;
    WindowOut = WindowIn;
    TimeStamp = 0;
    %WinT0 = -1;
    Continue = 'f';
    RemainingSamples = Y;
    RemainingTime = SampleT0;
    return
else 
    if iY >= nY
        % The needed sample is not in Y.  Return and continue with the next Y
        TimeStamp = WindowTime;
        WindowOut = WindowIn;
        return 
    end 
end

% Delete the unneeded samples from Y and adjust t0(1)
Y = Y(:,iY:end);
nY = length(Y);
SampleT0 = timeStampNeeded;


% determine how many samples to trim from the window
[~,nWindowIn] = size(WindowIn);
nKeep = nWindow - nWindowIn;
% trim the samples being replaced out of the Window
WindowIn = WindowIn(:,nSamplesNeeded-nKeep+1:end);

% if there are enough samples in Y, then use them, if not, use what is
% there and continue to the next Y.
if nSamplesNeeded <= nY
    WindowOut = horzcat(WindowIn,Y(:,1:nSamplesNeeded));
    TimeStamp = AnalysisTime;    
    RemainingSamples = Y(:,nSamplesNeeded+1:end);
    RemainingTime = SampleT0 + nSamplesNeeded*dt;
    Continue = 'f';
    % If a valid window is available, decide if the
    % settlingTime has elapsed and set Valid if so.
    if WinT0 < 0; WinT0 = TimeStamp; end;
    if TimeStamp >= WinT0 + SettlingTime; Valid = 't'; end;    
else
    WindowOut = horzcat(WindowIn,Y);
    TimeStamp = AnalysisTime - (nSamplesNeeded - nY)*dt;
    RemainingSamples = [];
    RemainingTime = [];
    Valid = 'f';
    Continue = 't';   
end    

% DEBUG display the timestamp
tR = datetime(RemainingTime, 'ConvertFrom', 'epochtime', 'Epoch', '1904-01-01'); tN.Format='dd-MMM-uuuu HH:mm:ss.SSS';
msg = sprintf('tR: %s ',char(tR));
disp (msg);
% DEBUG

end