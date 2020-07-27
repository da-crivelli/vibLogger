%VIBLOGGER(settings) logs data from a NI9234 board. 
%   supports IEPE (ICP) accelerometers
%   
%   VIBLOGGER(settings) runs the acquisition code with settings specified
%   in the settings structure. Parameters: (? denotes optional)
%
%   settings.
%     device_ids (cell of string): the devices to log from. Run "devices = daq.getDevices" to find the device ID
%     channels{i} (cell of arrays of int): which channels to read per device (start from 0)
%     sensorIDs (cell of strings): sensor IDs (run sensors_db('list') to see all sensors currently on the database
%     channel_names (cell of strings): human readable labels for channels
%
%     channel_type (string): type of channel. 'Voltage' for standard voltage, 'IEPE' for IEPE / ICP sensors. Applies to all channels.
%     ? iepe_excitation_current: excitation current for ICP sensors                  
%                    
%     fsamp (int): sampling frequency per channel in Hz (all channels)
%     recording_time (float): time to record in seconds per block
%     timeout (float): max acquisition time in seconds
%
%     output_folder (string): a folder where to save the results
%     live_preview (bool): enables live graphs
%     save_data (bool): whether to save data or just run the live preview 
%   
%     // the following parameters are optional and can also be manually
%     specified in the config.m file that gets generated at the end:
%
%  Davide Crivelli
%  davide.crivelli@diamond.ac.uk
%
%  For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%  see also: VIBANALYZER, VIBPLOTS, SENSORS_DB

function s = vibLogger(settings)

    if(~exist(strcat(settings.output_folder,filesep,'config.m'),'file'))
        % autowrite config file
        create_vib_config_file(strcat(settings.output_folder,filesep,'config.m'),settings); 
    end

    % create session & initialise device
    s = daq.createSession('ni');

    for dev = 1:length(settings.device_ids)
        for ch=1:length(settings.channels{dev})
            if(isstr(settings.channel_type))
                this_channel_type = settings.channel_type;
            else
                this_channel_type = settings.channel_type{ch};
            end
            
            addAnalogInputChannel(s, settings.device_ids{dev}, ...
                                     settings.channels{dev}(ch), ...
                                     this_channel_type);
                                 
            if strcmp(this_channel_type,'IEPE')
                s.Channels(ch).ExcitationCurrent = settings.iepe_excitation_current;
            end
        end
    end

    s.Rate = settings.fsamp;

    % start the data acquisition session in foreground & save data afterwards
    pause('on');
    scan_count = 0;

    if(~isfolder(settings.output_folder))
        mkdir(settings.output_folder);
    end
    
    s.IsContinuous = true;

    settings.acq_date = datetime('now');

    if settings.save_data
        lh = addlistener(s,'DataAvailable', ...
            @(src,event) save_data(event.TimeStamps, event.Data, settings));
    end

    if settings.live_preview
        lh = addlistener(s,'DataAvailable', ...
            @(src,event) display_data(event.TimeStamps, event.Data, settings));
    end

    s.NotifyWhenDataAvailableExceeds = settings.recording_time*settings.fsamp;

    s.startBackground();
    
    % wait() will timeout by throwing an error...
    try
        s.wait(settings.timeout);
    catch err
        if not(err.identifier == "daq:Session:timeout")
            rethrow(err);
        else
            disp('Finished recording');
            s.stop();
        end
    end

end


function save_data(time, data, settings)

    acq_date = settings.acq_date +seconds(time(1));
    
    save_filename = strcat(settings.output_folder, ...
        filesep,datestr(acq_date,'yyyymmdd_HHMMss'),'.mat');
    
    % to be removed... make it backwards compatible with the analyzer
    fsamp = settings.fsamp;
    recording_time = settings.recording_time;
    
    save(save_filename,'data','time','settings','acq_date','fsamp','recording_time');
    fprintf('saved data %s\n',save_filename);        
end

function display_data(t, data, settings)
    nrchans = 0;
    for dev=1:length(settings.device_ids)
        nrchans = nrchans + length(settings.channels{dev});
    end
    
    for ch=1:nrchans
        subplot(nrchans,2,2*ch-1);
        plot(t, data(:,ch));
        ylabel(settings.channel_names{ch});
        
        subplot(nrchans,2,2*ch);
        pwelch(data(:,ch),[],[],[],settings.fsamp);
        
    end
end

function create_vib_config_file(filename,settings)
    %CREATE_VIB_CONFIG_FILE(filename,settings) creates a .m configuration file for vibration data

    cfg = fopen(filename,'w');
    fprintf(cfg,'%s\n','% Automatically generated config file');
    fprintf(cfg,'%% Generated on: %s\n\n',datestr(now,'yyyy/mm/dd HH:MM:ss'));

    sensors_string = sprintf('''%s'',',settings.sensorIDs{:});
    fprintf(cfg,'sensor_ids = {%s};\n',sensors_string(1:end-1));

    channel_string = sprintf('''%s'',',settings.channel_names{:});
    fprintf(cfg,'channel_names = {%s};\n',channel_string(1:end-1));

    if(isfield(settings,'transmiss_inputs'))
        settings.transmiss_inputs(:)
        fprintf(cfg,'inputs = [%s];\n',strtrim(sprintf('%.0f ',settings.transmiss_inputs(:))));
        fprintf(cfg,'outputs = [%s];\n',strtrim(sprintf('%.0f ',settings.transmiss_outputs(:))));
    end

    fclose(cfg);

end
