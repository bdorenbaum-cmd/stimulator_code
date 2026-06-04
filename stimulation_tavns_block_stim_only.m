%Import excel table of stimulation order
opts = detectImportOptions("stimulationorder.xlsx");
opts = setvartype(opts,'double');
order = readtable("stimulation_mri_tavns_block_stim_only.xlsx", opts);
order = order.Variables;
breaks = [9, 18, 27, 36, 45];
for i = 1:size(order, 1)
    stim.anode = order(i, 1);
    stim.intensity = order(i, 2);
    stim.duration = order(i, 3);
    
    if stim.intensity == 0
        pWaveForm = struct('ChannelNumber',stim.anode,'Action',1,'PathToFile','C:\Users\MxN-33\Desktop\SMI_HDSC_SW_V3010\waveforms_files\square_0.txt'); 
    
    elseif stim.intensity == 0.1
        pWaveForm = struct('ChannelNumber',stim.anode,'Action',1,'PathToFile','C:\Users\MxN-33\Desktop\SMI_HDSC_SW_V3010\waveforms_files\square_sham_3.txt'); 

    elseif stim.intensity == 0.8
        pWaveForm = struct('ChannelNumber',stim.anode,'Action',1,'PathToFile','C:\Users\MxN-33\Desktop\SMI_HDSC_SW_V3010\waveforms_files\square_0.8.txt'); 

    elseif stim.intensity == 1.6
        pWaveForm = struct('ChannelNumber',stim.anode,'Action',1,'PathToFile','C:\Users\MxN-33\Desktop\SMI_HDSC_SW_V3010\waveforms_files\square_1.6.txt'); 

    else 
        pWaveForm = struct('ChannelNumber',stim.anode,'Action',1,'PathToFile','C:\Users\MxN-33\Desktop\SMI_HDSC_SW_V3010\waveforms_files\square_3.0.txt'); 

    end

    JSONWaveForm = jsonencode(pWaveForm); 
    outlet.push_sample({JSONWaveForm});                                                                 
    if stim.intensity == 0.1
        pFrequency = struct('Action',7,'ChannelNumber',1,'Frequency',0.1); 
        JSONFrequency = jsonencode(pFrequency); 
        outlet.push_sample({JSONFrequency});
    end
    

    pDuration = struct('Action',7,'Duration', stim.duration); 
    JSONDuration = jsonencode(pDuration); 
    outlet.push_sample({JSONDuration});
   
    pause(3)
    
    %Load Stimulation
    pLoad = struct('Action',3, 'value', 'TRUE'); 
    JSONLoad = jsonencode(pLoad);
    outlet.push_sample({JSONLoad});
    % pause(2)

    disp("Loaded Stimulation Parameters")
           
    %Starting Stimulation
    pause(3)
    pstartStimulation = struct('Action',4,'value', 'TRUE'); 
    JSONstartStimulation = jsonencode(pstartStimulation);
    outlet.push_sample({JSONstartStimulation});
    disp("Started Stimulation")
    
    pause(stim.duration)


    % pstopStimulation = struct('Action',5,'value', 'TRUE'); 
    % JSONstopStimulation = jsonencode(pstopStimulation);
    % outlet.push_sample({JSONstopStimulation}); 

   

    pdeleteAnode = struct('Action',2, "ChannelNumber", stim.anode); 
    JSONdeleteAnode = jsonencode(pdeleteAnode);
    outlet.push_sample({JSONdeleteAnode}); 
    pause(3)
    disp("Ended Stimulation")

end
clearvars -except info lib outlet opts order


   


