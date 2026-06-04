
%Add Channel
pChannel = struct("Action",0,"ChannelNumber",19);
JSONaddChannel = jsonencode(pChannel);

%Load Device
pLoad = struct("Action",3);
JSONLoad = jsonencode(pLoad);

%Starting Stimulation 
pstartStimulation = struct("Action",4);
JSONstartStimulation = jsonencode(pstartStimulation);

%Stop Stimulation 
pstopStimulation = struct("Action",5);
JSONstopStimulation = jsonencode(pstopStimulation);


%Settings: Duration
pDuration = struct("Action",7,"Duration",10);
JSONDuration = jsonencode(pDuration);

%Settings: Intensity
pIntensity = struct("Action",7,"Intensity",2);
JSONIntensity = jsonencode(pIntensity);

%Settings: Delay
pDelay = struct("Action",7,"Delay",50);
JSONDelay = jsonencode(pDelay);

%Settings: RampUp
pRampUp = struct("Action",7,"RampUp",3);
JSONRampUp = jsonencode(pRampUp);

%Input WaveForm
pWaveForm = struct("ChannelNumber",19,"Action",1,"PathToFile","C:\waveforms_files\full_sine.txt");
JSONWaveForm = jsonencode(pWaveForm);



%Sending Commands to MXN
outlet.push_sample({JSONaddChannel});
% pause(2)
outlet.push_sample({JSONIntensity});
% pause(2)
outlet.push_sample({JSONDuration});
% pause(2)
outlet.push_sample({JSONDelay});
% pause(2)
outlet.push_sample({JSONRampUp});
% pause(2)
outlet.push_sample({JSONLoad});
pause(2)
outlet.push_sample({JSONstartStimulation});




