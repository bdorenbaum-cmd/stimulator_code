%add library path
% addpath(genpath('C:\Users\Admin\Documents\Soterix\MXN-33 Control'))

%Initiating LSL Library
lib = lsl_loadlib();
info = lsl_streaminfo(lib,'HD-SC_Markers','Markers',1,0,'cf_string');
outlet = lsl_outlet(info);


%jsonencode()%use to convert structure containing 'Action' and command to
%JSON format
%{
possible 'Action' codes:
    Action can be following:
        1. AddChannel = 0
        2. AddChannelFromFile = 1
        3. DeleteChannel = 2
        4. Load Device = 3
        5. StartStimulation = 4
        6. StopStimulation = 5
        7. UpdateSettings = 7
        8. ChangeImpedance = 8


   % Add Channel
    pChannel = struct('Action',0,'ChannelNumber', 19);
    JSONaddChannel = jsonencode(pChannel);

    %Load Device
    pLoad = struct('Action',3, 'value', 'TRUE');
    JSONLoad = jsonencode(pLoad);

    %Starting Stimulation 
    pstartStimulation = struct('Action',4,'value','TRUE');
    JSONstartStimulation = jsonencode(pstartStimulation);

    %Stop Stimulation 
    pstopStimulation = struct('Action',5, 'value', 'TRUE');
    JSONstopStimulation = jsonencode(pstopStimulation);


    %Settings: Duration
    pDuration = struct('Action',7,'Duration',10);
    JSONDuration = jsonencode(pDuration);

    %Settings: Intensity
    pIntensity = struct('Action',7,'Intensity',2);
    JSONIntensity = jsonencode(pIntensity);

    %Settings: Delay
    pDelay = struct('Action',7,'Delay',50);
    JSONDelay = jsonencode(pDelay);

    %Settings: RampUp
    pRampUp = struct('Action',7,'RampUp',3);
    JSONRampUp = jsonencode(pRampUp);

    %Input WaveForm
    pWaveForm = struct('ChannelNumber',19,'Action',1,'PathToFile','C:\waveforms_files\full_sine.txt');
    JSONWaveForm = jsonencode(pWaveForm);



    Sending Commands to MXN
    outlet.push_sample({JSONaddChannel});
    pause(2)
    outlet.push_sample({JSONIntensity});
    pause(2)
    outlet.push_sample({JSONDuration});
    pause(2)
    outlet.push_sample({JSONDelay});
    pause(2)
    outlet.push_sample({JSONRampUp});
    pause(2)
    outlet.push_sample({JSONLoad});
    pause(2)
    outlet.push_sample({JSONstartStimulation});
%}

%Load Device
pLoad = struct('Action',3);
JSONLoad = jsonencode(pLoad);

outlet.push_sample({JSONLoad});

pMxNVersion = struct('Action',7,'mxnversion',16);
JSONMxNVersion = jsonencode(pMxNVersion);

outlet.push_sample ({JSONMxNVersion});
pause(2)

%Settings: tACS
ptACS = struct('Action',7,'WaveformType','tACS','Polarity','BIPOLAR','ChannelSelection','MULTIPLE');
JSONtACS = jsonencode(ptACS);

outlet.push_sample({JSONtACS});
pause(2)

% Add Channel
pChannel = struct('Action',0,'ChannelNumber',19);
JSONaddChannel = jsonencode(pChannel);

outlet.push_sample({JSONaddChannel});
pause(2)

%Settings: Duration
pDuration = struct('Action',7,'Duration',20);
JSONDuration = jsonencode(pDuration);

outlet.push_sample({JSONDuration});                                                                 
pause(2)

%Settings: Frequency
pFrequency = struct('Action',7,'WaveformType','TACS','Polarity','BIPOLAR','Frequency',2);
JSONFrequency = jsonencode(pFrequency);


outlet.push_sample({JSONFrequency});
pause(2)

pFrequency = struct('Action',7,'WaveformType','TACS','Polarity','BIPOLAR','ChannelNumber',19, 'Frequency',20);
JSONFrequency = jsonencode(pFrequency);


%{
%Starting Stimulation 
pstartStimulation = struct('Action',4);
JSONstartStimulation = jsonencode(pstartStimulation);

outlet.push_sample({JSONstartStimulation});

%Stop Stimulation 
pstopStimulation = struct('Action',5);
JSONstopStimulation = jsonencode(pstopStimulation);

outlet.push_sample({JSONstopStimulation});

%}

%======Freq Test=====
ptACS = struct('Action',7,'WaveformType','TACS','Polarity','BIPOLAR','ChannelSelection','MULTIPLE');
JSONtACS = jsonencode(ptACS);
pChannel = struct('Action',0,'ChannelNumber',19);
JSONaddChannel = jsonencode(pChannel);

outlet.push_sample({JSONtACS});
pause(2)
outlet.push_sample({JSONaddChannel});
pause(2)

freq = 0.05:0.001:0.06;
for i = 1:length(freq)
    %Settings: Frequency
    pFrequency = struct('Action',7,'WaveformType','TACS','Polarity','BIPOLAR','ChannelNumber',19,'Frequency',freq(i));
    JSONFrequency = jsonencode(pFrequency);
    
    outlet.push_sample({JSONFrequency});
    pause
end
%-------

%Not working:
DisableImpedance TRUE FALSE

pDisableImpedance = struct('Action',7,'DisableImpedance','TRUE');
JSONDisableImpedance = jsonencode(pDisableImpedance);

pDisableImpedance = struct('Action',7,'DisableImpedance','FALSE');
JSONDisableImpedance = jsonencode(pDisableImpedance);

outlet.push_sample({JSONDisableImpedance});

pDisableImpedance = struct('Action',7,'DisableImpedance',true);
JSONDisableImpedance = jsonencode(pDisableImpedance);

outlet.push_sample({JSONDisableImpedance});

pDisableImpedance = struct('Action',7,'DisableImpedance',1);
JSONDisableImpedance = jsonencode(pDisableImpedance);

outlet.push_sample({JSONDisableImpedance});

%Impedance Disable / Enable:

pDisableImpedance = struct('Action',8, 'value', 'TRUE');
JSONDisableImpedance = jsonencode(pDisableImpedance);
outlet.push_sample({JSONDisableImpedance});


pDisableImpedance = struct('Action',8, 'value', 'FALSE');
JSONDisableImpedance = jsonencode(pDisableImpedance);
outlet.push_sample({JSONDisableImpedance});


%Correct
%Impedance Disable / Enable:

pDisableImpedance = struct('Action',8, 'value', 'TRUE');
JSONDisableImpedance = jsonencode(pDisableImpedance);

outlet.push_sample({JSONDisableImpedance});
pause(2)

pDisableImpedance = struct('Action',8, 'value', 'FALSE');
JSONDisableImpedance = jsonencode(pDisableImpedance);

outlet.push_sample({JSONDisableImpedance});
pause(2)
