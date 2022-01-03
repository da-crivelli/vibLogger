clearvars
close all

addpath('C:\Users\mca67379\Documents\MATLAB\viblogger');

%% config

settings = struct();

settings.device_ids = {'cDAQ1Mod1'};  % run "devices = daq.getDevices" and find the device ID

settings.channels{1} = [0, 1, 2];  % which channels to read on each module / device

settings.sensorIDs = {'60354','60660','60662'};  %sensor IDs (run sensors_db('list') to see all sensors)
settings.channel_names = {'Ground X','Ground Y','Ground Z'}; %channel names

%settings.transmiss_inputs = [1 2];  % only for transmissibility ratio tests.
%settings.transmiss_outputs = [3 4]; % Comment out for standard vibration test

settings.channel_type = 'IEPE';  % 'Voltage' for standard voltage
                                 % 'IEPE' for IEPE / ICP sensors.
                                 % also accepts a cell of strings for
                                 % different settings per channel.
                                 
settings.iepe_excitation_current = .004;                         

switch_day = 3;
switch_hour = 12;
                        
settings.fsamp = 2048;   % sampling frequency in Hz
settings.recording_time = 60; % time to record in seconds per block

settings.output_folder = strcat('./raw_data/',weekstring(switch_day,switch_hour)); %where to save the results

settings.live_preview = true;   

diary(strcat('./logs/',weekstring(switch_day,switch_hour),'_logger.txt'));
                                
%% runs vibLogger once for 2 minutes to get rid of the huge initial decay when restarting
settings.timeout = 120;   % max acquisition time in seconds
settings.save_data = false;     
vibLogger(settings);


%settings.timeout = 60*60*7*30 - 60*20;   % max acquisition time in seconds
settings.datetime_timeout = datetime(weekstring(switch_day,switch_hour,'YYYY-mm-dd HH:MM'))+days(7);
settings.save_data = true;     

%% runs the real process  
try
    vibLogger(settings);
catch e
    fprintf(1,'The identifier was:\n%s',e.identifier);
    fprintf(1,'There was an error! The message was:\n%s',e.message);
end
