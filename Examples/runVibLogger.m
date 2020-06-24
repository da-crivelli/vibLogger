clearvars
close all

addpath('\\dc.diamond.ac.uk\dls\science\users\mca67379\MATLAB\vibLogger');

%% config

settings = struct();

settings.device_ids = {'cDAQ1Mod3','cDAQ1Mod4'};  % run "devices = daq.getDevices" and find the device ID

settings.channels{1} = [0, 1, 2, 3];  % which channels to read on each module / device
settings.channels{2} = [0, 1];

settings.sensorIDs = {'50887','50983','50985','50984','50984','50984'};  %sensor IDs (run sensors_db('list') to see all sensors)
settings.channel_names = {'V floor','H floor','V quad','H quad','V hex','H hex'}; %channel names

%settings.transmiss_inputs = [1 2];  % only for transmissibility ratio tests.
%settings.transmiss_outputs = [3 4]; % Comment out for standard vibration test

settings.channel_type = 'IEPE';  % 'Voltage' for standard voltage
                                 % 'IEPE' for IEPE / ICP sensors.
                                 % also accepts a cell of strings for
                                 % different settings per channel.
                                 
settings.iepe_excitation_current = .004;                         
                        
settings.fsamp = 2048;   % sampling frequency in Hz
settings.recording_time = 1; % time to record in seconds per block
settings.timeout = 33;   % max acquisition time in seconds

settings.output_folder = '.'; %where to save the results

settings.live_preview = true;   
settings.save_data = false;      % currently there is no way to 
                                % independently set the save and preview times

%% runs vibLogger                                
vibLogger(settings);
