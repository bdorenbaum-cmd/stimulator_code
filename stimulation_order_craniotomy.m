% stimulation_order_craniotomy.m
%
% Craniotomy variant of stimulation_order.m
%
% Key difference from standard protocol:
%   Each electrode location has an individually calibrated current intensity
%   (derived from patient-specific E-field modelling) to match the cortical
%   field produced by 0.5 mA in subjects without skull defects.
%   Anode and cathode intensities are therefore DIFFERENT for each montage
%   and are stored in separate columns of the patient-specific montage Excel.
%
% Required input file columns:
%   1: anode             - electrode number (1-6)
%   2: cathode           - electrode number (1-6)
%   3: rampup (s)        - ramp-up duration in seconds
%   4: anode_intensity (mA)   - positive current at anode (mA), patient-specific
%   5: cathode_intensity (mA) - negative current at cathode (mA), patient-specific
%                                (stored as negative value in Excel)
%   6: duration (s)      - stimulation duration in seconds
%
% Workflow:
%   1. Run generate_montage_craniotomy.py to create the patient-specific
%      montage Excel from the stim targeting file.
%   2. Select that patient-specific montage Excel when prompted here.
%
% Usage: Run this script in MATLAB with the LSL outlet already initialised.

opts = detectImportOptions("stimulationorder.xlsx");
opts = setvartype(opts, 'double');

% CHANGE FILE TO MATCH CRANIOTOMY PATIENT
[filename, folder_path] = uigetfile('*.xlsx', 'Select patient craniotomy montage file');
if isequal(filename, 0)
    error('No file selected. Aborting.');
end
order = readtable(fullfile(folder_path, filename), opts);
order = order.Variables;

% Validate column count
if size(order, 2) < 6
    error(['Expected 6 columns (anode, cathode, rampup, anode_intensity, ' ...
           'cathode_intensity, duration). Got %d. ' ...
           'Use generate_montage_craniotomy.py to create the correct file.'], ...
           size(order, 2));
end

fprintf('Loaded craniotomy montage: %s\n', filename);
fprintf('Number of montages: %d\n', size(order, 1));
fprintf('Anode intensity range: %.3f – %.3f mA\n', min(order(:,4)), max(order(:,4)));
fprintf('Cathode intensity range: %.3f – %.3f mA\n', min(order(:,5)), max(order(:,5)));

for i = 1:size(order, 1)

    stim.anode          = order(i, 1);
    stim.cathode        = order(i, 2);
    stim.rampup         = order(i, 3);
    stim.anode_intensity   = order(i, 4);   % positive value (mA)
    stim.cathode_intensity = order(i, 5);   % negative value (mA)
    stim.duration       = order(i, 6);

    fprintf('\n--- Montage %d/%d ---\n', i, size(order, 1));
    fprintf('  Anode:   electrode %d at +%.4f mA\n', stim.anode, stim.anode_intensity);
    fprintf('  Cathode: electrode %d at %.4f mA\n', stim.cathode, stim.cathode_intensity);

    % Settings: Waveform
    ptDCS = struct('Action', 7, 'WaveformType', 'tDCS', 'SHAM', 'FALSE', ...
                   'ChannelSelection', 'MULTIPLE');
    JSONtdCS = jsonencode(ptDCS);

    pDuration = struct('Action', 7, 'Duration', stim.duration);
    JSONDuration = jsonencode(pDuration);

    % Add Channels
    % ANODE
    pChannel = struct('Action', 0, 'ChannelNumber', stim.anode);
    JSONaddAnode = jsonencode(pChannel);

    % CATHODE
    pChannel = struct('Action', 0, 'ChannelNumber', stim.cathode);
    JSONaddCathode = jsonencode(pChannel);

    % Set anode intensity (positive)
    pIntensityAnode = struct('Action', 7, 'Intensity', stim.anode_intensity);
    JSONIntensityAnode = jsonencode(pIntensityAnode);

    % Set cathode intensity (negative — already stored as negative in Excel)
    pIntensityCathode = struct('Action', 7, 'Intensity', stim.cathode_intensity);
    JSONIntensityCathode = jsonencode(pIntensityCathode);

    % RampUp
    pRampUp = struct('Action', 7, 'RampUp', stim.rampup);
    JSONRampUp = jsonencode(pRampUp);

    % Load stimulation parameters
    outlet.push_sample({JSONtdCS});
    outlet.push_sample({JSONDuration});

    % Anode: set positive intensity, then add channel
    outlet.push_sample({JSONIntensityAnode});
    pause(1)
    outlet.push_sample({JSONaddAnode});

    % Cathode: set negative intensity, then add channel
    outlet.push_sample({JSONIntensityCathode});
    pause(1)
    outlet.push_sample({JSONaddCathode});

    outlet.push_sample({JSONRampUp});

    pLoad = struct('Action', 3, 'value', 'TRUE');
    JSONLoad = jsonencode(pLoad);
    outlet.push_sample({JSONLoad});

    disp("Loaded Stimulation Parameters")

    % Wait for trigger to start and stop stimulation
    track = 0;
    wait  = 0;
    while wait == 0
        try
            trigger = load("\\HodicsHP\LMRI_V6\triggers\trigger_var.mat");
        catch
            continue
        end

        if trigger.trigger_var == 0 && track == 0
            pause(1)

        elseif trigger.trigger_var == 1 && track == 0
            pause(1.5)
            pstartStimulation = struct('Action', 4, 'value', 'TRUE');
            JSONstartStimulation = jsonencode(pstartStimulation);
            outlet.push_sample({JSONstartStimulation});
            outlet.push_sample({JSONstartStimulation});
            track = 1;
            disp("Started Stimulation")

        elseif trigger.trigger_var == 1 && track == 1
            pause(0.1)

        elseif trigger.trigger_var == 0 && track == 1
            pstopStimulation = struct('Action', 5, 'value', 'TRUE');
            JSONstopStimulation = jsonencode(pstopStimulation);
            outlet.push_sample({JSONstopStimulation});

            pdeleteCathode = struct('Action', 2, 'ChannelNumber', stim.cathode);
            JSONdeleteCathode = jsonencode(pdeleteCathode);
            outlet.push_sample({JSONdeleteCathode});

            pdeleteAnode = struct('Action', 2, 'ChannelNumber', stim.anode);
            JSONdeleteAnode = jsonencode(pdeleteAnode);
            outlet.push_sample({JSONdeleteAnode});

            pause(3)
            disp("Ended Stimulation")
            wait = 1;
        end
    end

    clearvars -except info lib outlet opts order

end
