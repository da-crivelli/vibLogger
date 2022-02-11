clearvars
close all

addpath('C:\Users\mca67379\Documents\MATLAB\viblogger');

%% config

settings = struct();

settings.device_ids = {'cDAQ2Mod1'};  % run "devices = daq.getDevices" and find the device ID

settings.channels{1} = [0, 1, 2];  % which channels to read on each module / device
%settings.channels{2} = [0, 1, 2];  % which channels to read on each module / device

settings.sensorIDs = {'unity','unity','unity'};  %sensor IDs (run sensors_db('list') to see all sensors)
settings.channel_names = {'1','2','3'}; %channel names

settings.transmiss_inputs = [1 2 3];  % only for transmissibility ratio tests.
settings.transmiss_outputs = [2 3 1]; % Comment out for standard vibration test
settings.winoverlap = 0.67; % for live transmissibility
settings.nrwindows = 2; % for live transmissibility

settings.channel_type = 'Voltage';  % 'Voltage' for standard voltage
                                 % 'IEPE' for IEPE / ICP sensors.
                                 % also accepts a cell of strings for
                                 % different settings per channel.
                                 
%settings.iepe_excitation_current = .004;                         
                        
settings.fsamp = 2048;   % sampling frequency in Hz
settings.recording_time = 2; % time to record in seconds per block
settings.update_time = 1; %time in-between plots and other functions updates

settings.timeout = 60;   % max acquisition time in seconds

settings.output_folder = '.'; %where to save the results

settings.live_preview = true;   
settings.save_data = false;      % currently there is no way to 
                                % independently set the save and preview times

settings.callback_shortloop = 'live_transmissibility';
                                
%% runs vibLogger                                
vibLogger(settings);
