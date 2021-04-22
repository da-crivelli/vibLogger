% generate random signal; save to example_data
clearvars
close all

output_folder = 'example_data';
fsamp = 2048;
nr_files = 2;
recording_time = 60;
nr_chans = 3;

% prepare the file variables
acq_date = datetime();
t_0 = 0;
nrsamp = recording_time*fsamp;
settings.device_ids = {["generate_random_signal"]};
for ch=1:nr_chans
    settings.channels{ch} = sprintf('Ch%d',ch);
    settings.sensorIDs{ch} = 'unity';
    settings.channel_names{ch} = sprintf('Ch%d',ch);
    settings.channel_type{ch} = 'IEPE';
end
settings.fsamp = fsamp;
settings.recording_time = recording_time;
settings.timeout = recording_time*nr_files;

   

% actual generation 
rms_vals = {[1, 1], [3], [3, 2]};
freq_vals = {[0, 5], [11], [11, 50]};
noise_rms = 0;

figure();
for i=1:nr_files
    for ch=1:nr_chans
        [d, t] = generate_random_signal(rms_vals{ch},freq_vals{ch},...
            noise_rms, fsamp*recording_time, fsamp);
        data(:,ch) = d;
    end
    time = t+t_0;
    t_0 = recording_time * (i-1);
    acq_date = acq_date + seconds(recording_time);
    settings.acq_date = acq_date;
    
    save_filename = strcat(output_folder, ...
            filesep,datestr(acq_date,'yyyymmdd_HHMMss'),'.mat');
    save(save_filename,'time','data','settings','acq_date','fsamp','recording_time');
end