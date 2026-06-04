%Import excel table of stimulation order
opts = detectImportOptions("stimulationorder.xlsx");
opts = setvartype(opts,'double');
% CHANGE FILE TO MATCH EXPERIMENT
[filename, folder_path] = uigetfile('Select patient stim file to import');
order = readtable(filename, opts);
order = order.Variables;

for i = 1:size(order, 1)
    stim.anode = order(i, 1);
    stim.cathode = order(i, 2);
    stim.rampup = order(i, 3);
    stim.intensity = order(i, 4);
    stim.duration = order(i, 5);


    %Settings: Waveform Change tACS
    ptDCS = struct('Action',7,'WaveformType','tDCS','SHAM','FALSE','ChannelSelection','MULTIPLE') ;
    JSONtdCS = jsonencode(ptDCS);
    

    pDuration = struct('Action',7,'Duration', stim.duration); 
    JSONDuration = jsonencode(pDuration); 
     
    

    %Add Channels

    % ANODE
    pChannel = struct("Action",0,"ChannelNumber",stim.anode);
    JSONaddAnode = jsonencode(pChannel);
     
    
    
    % CATHODE
    pChannel = struct("Action",0,"ChannelNumber",stim.cathode);
    JSONaddCathode = jsonencode(pChannel);
    

    % Set intensity
    pIntensity = struct('Action',7,'Intensity', stim.intensity); 
    JSONIntensity = jsonencode(pIntensity);
    


    % %Settings: Delay 1
    % pDelay1 = struct('Action',7,'Delay', stim.delay1); 
    % JSONDelay1 = jsonencode(pDelay1);
    % outlet.push_sample({JSONDelay1}); 

    
    %Settings: RampUp 
    pRampUp = struct('Action',7,'RampUp',stim.rampup); 
    JSONRampUp = jsonencode(pRampUp);
    
   

    
    
    %Load Stimulation
    outlet.push_sample({JSONtdCS});
    outlet.push_sample({JSONDuration});
    pIntensity = struct('Action',7,'Intensity', stim.intensity); 
    JSONIntensity = jsonencode(pIntensity);
    outlet.push_sample({JSONIntensity});
    pause(1)
    outlet.push_sample({JSONaddAnode});

    pIntensity = struct('Action',7,'Intensity', -1*stim.intensity); 
    JSONIntensity = jsonencode(pIntensity);
    outlet.push_sample({JSONIntensity});
    pause(1)
    outlet.push_sample({JSONaddCathode});
    
    outlet.push_sample({JSONRampUp}); 
    

    pLoad = struct('Action',3, 'value', 'TRUE'); 
    JSONLoad = jsonencode(pLoad);
    outlet.push_sample({JSONLoad});
    % pause(2)

    disp("Loaded Stimulation Parameters")
    track = 0;
    wait = 0;
    while wait == 0
        try
            trigger = load("\\HodicsHP\LMRI_V6\triggers\trigger_var.mat");
        catch trigger
            continue
        end

        if trigger.trigger_var == 0 & track == 0
            pause(1)
        elseif trigger.trigger_var == 1 & track == 0
           
            %Starting Stimulation
            pause(1.5)
            pstartStimulation = struct('Action',4,'value', 'TRUE'); 
            JSONstartStimulation = jsonencode(pstartStimulation);
            outlet.push_sample({JSONstartStimulation});
            pstartStimulation = struct('Action',4,'value', 'TRUE'); 
            JSONstartStimulation = jsonencode(pstartStimulation);
            outlet.push_sample({JSONstartStimulation});
            track = 1;
            disp("Started Stimulation")

        elseif trigger.trigger_var == 1 & track == 1
            pause(0.1)

        elseif trigger.trigger_var == 0 & track == 1
            %Stopping Stimulation
            pstopStimulation = struct('Action',5,'value', 'TRUE'); 
            JSONstopStimulation = jsonencode(pstopStimulation);
            outlet.push_sample({JSONstopStimulation}); 
         
            pdeleteCathode = struct('Action',2, "ChannelNumber", stim.cathode); 
            JSONdeleteCathode = jsonencode(pdeleteCathode);
            outlet.push_sample({JSONdeleteCathode}); 
           

            pdeleteAnode = struct('Action',2, "ChannelNumber", stim.anode); 
            JSONdeleteAnode = jsonencode(pdeleteAnode);
            outlet.push_sample({JSONdeleteAnode}); 
            pause(3)
            disp("Ended Stimulation")
            wait = 1;
        end
        
    end
    clearvars -except info lib outlet opts order


    

end


