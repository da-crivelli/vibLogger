clearvars
close all

addpath('\\dc.diamond.ac.uk\dls\science\users\mca67379\MATLAB\vibLogger');

%% config

settings = struct();

settings.device_ids = {'cDAQ2Mod3','cDAQ2Mod4'};  % run "devices = daq.getDevices" and find the device ID

settings.channels{1} = [0, 1, 2];  % which channels to read on each module / device
settings.channels{2} = [0, 1, 2];  % which channels to read on each module / device

settings.sensorIDs = {'unity','unity','unity','58595','58594','50887'};  %sensor IDs (run sensors_db('list') to see all sensors)
settings.channel_names = {'Mono X','Mono Y','Mono Z','Ground X','Ground Y','Ground Z'}; %channel names

%settings.transmiss_inputs = [1 2];  % only for transmissibility ratio tests.
%settings.transmiss_outputs = [3 4]; % Comment out for standard vibration test

settings.channel_type = 'Voltage';  % 'Voltage' for standard voltage
                                 % 'IEPE' for IEPE / ICP sensors.
                                 % also accepts a cell of strings for
                                 % different settings per channel.
                                 
%settings.iepe_excitation_current = .004;                         
                        
settings.fsamp = 2048;   % sampling frequency in Hz
settings.recording_time = 60; % time to record in seconds per block
settings.update_time = 1; %time in-between plots and other functions updates

settings.timeout = 200;   % max acquisition time in seconds

settings.output_folder = '.'; %where to save the results

settings.live_preview = true;   
settings.save_data = false;      % currently there is no way to 
                                % independently set the save and preview times

settings.callback_shortloop = 'transmissibility'
                                
%% runs vibLogger                                
vibLogger(settings);
