%   VibLogge    r
%
%   logs data from a NI 9234 board
%   supports IEPE (ICP) accelerometers
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   v0.1 20200110 - initial release
%   

%% config

clearvars
close all

device_id = 'cDAQ1Mod1';  % run "devices = daq.getDevices" and find the device ID
channels = [1, 2, 3];  % which channels to read 

channel_type = 'IEPE';  % 'Voltage' for standard voltage
                        % 'IEPE' for IEPE / ICP sensors

iepe_excitation_current = .004;                         
                        
fsamp = 2048;   % sampling frequency
recording_time = 60; % time to record in seconds
recording_pause = 0; % time to pause in between recordings

output_folder = '20200311_Mirror_I19_TMD_X'; %where to save the results



max_acq_no = 5;   % max number of acquisitions. set to Inf if you want to keep scanning


%% create session & initialise device
s = daq.createSession('ni');

for ch=1:length(channels)
    addAnalogInputChannel(s, device_id, channels(ch), channel_type);
    s.Channels(ch).ExcitationCurrent = iepe_excitation_current;
end

s.Rate = fsamp;

%% start the data acquisition session in foreground & save data afterwards

pause('on');
scan_count = 0;

if(~isdir(output_folder))
    mkdir(output_folder);
end

while(scan_count < max_acq_no)
    s.DurationInSeconds = recording_time;

    acq_date = datetime('now');

    [data,time] = s.startForeground;

    save_filename = strcat(output_folder,filesep,datestr(acq_date,'yyyymmdd_HHMMss'),'.mat');
    save(save_filename,'data','time','acq_date','fsamp','recording_time');

    scan_count = scan_count+1;
    if(recording_pause)
        pause(recording_pause);
    end
    fprintf('Finished acquiring %d/%d',scan_count,max_acq_no);
    drawnow;
end

if(~exist(strcat(output_folder,filesep,'config.m'),'file'))
    copyfile('./Copy_of_config.m',strcat(output_folder,filesep,'config.m'));
    open(strcat(output_folder,filesep,'config.m'));
end