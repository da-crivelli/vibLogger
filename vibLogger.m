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
%     update_time (float): time between updates (used to fire the plots and
%       the EPICS callback functions)
%     timeout (float): max acquisition time in seconds
%     datetime_timeout(string): date & time when recording stops (overrides timeout)
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
    
    addpath(strcat(fileparts(which(mfilename)),filesep,'utils'));
    addpath(strcat(fileparts(which(mfilename)),filesep,'integrations'));

    clear global dataBuffer;
    clear global realtimePlot;

    if(~isfolder(settings.output_folder))
        mkdir(settings.output_folder);
    end

    if(~exist(strcat(settings.output_folder,filesep,'config.m'),'file'))
        % autowrite config file
        create_vib_config_file(strcat(settings.output_folder,filesep,'config.m'),settings);
    end
    
    if(~isfield(settings, 'update_time'))
        settings.update_time = settings.recording_time;
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

    s.IsContinuous = true;

    settings.acq_date = datetime('now');
    
    nrchans = 0;
    for dev=1:length(settings.device_ids)
        nrchans = nrchans + length(settings.channels{dev});
    end    
    settings.nrchans = nrchans;

    if settings.save_data
        lh_save = addlistener(s,'DataAvailable', ...
            @(src,event) save_data(event.TimeStamps, event.Data, settings));
    end

    if settings.live_preview
        lh_display = addlistener(s,'DataAvailable', ...
            @(src,event) display_data(event.TimeStamps, event.Data, settings));
    end

    if(isfield(settings, 'datetime_timeout'))
        settings.timeout = ceil(seconds(settings.datetime_timeout - datetime('now')));
    end

    % fire the event every update_time 
    s.NotifyWhenDataAvailableExceeds = ceil(settings.update_time*settings.fsamp);

    s.startBackground();

    % check if the caller wants to handle the session by themselves
    if(nargout == 0)
        % wait() will timeout by throwing an error...
        try
            s.wait(settings.timeout);
        catch err
            if not(err.identifier == "daq:Session:timeout")
                rethrow(err);
            else
                disp('Finished recording');
                s.stop();
                s.release();
            end
        end
    end

end


function save_data(time, this_data, settings)
    is_buffer_full = append_dataBuffer(time, this_data, settings);
    
    % This is called during every "short" loop. TODO: make asynchronous?
    if(isfield(settings,'callback_shortloop'))
        short_callback = str2func(settings.callback_shortloop);
        short_callback(this_data, settings);
    end
    
    if(is_buffer_full)
        buffer_data = get_dataBuffer();
        settings = buffer_data.settings;
        data = buffer_data.data;
        time = buffer_data.time;
        
        acq_date = settings.acq_date +seconds(time(1));

        save_filename = strcat(settings.output_folder, ...
            filesep,datestr(acq_date,'yyyymmdd_HHMMss'),'.mat');

        % to be removed... make it backwards compatible with the analyzer
        fsamp = settings.fsamp;
        recording_time = settings.recording_time;

        save(save_filename,'data','time','settings','acq_date','fsamp','recording_time');
        fprintf('saved data %s\n',save_filename);
    end
end

function display_data(t, data, settings)
    global realtimePlot;

    try
        figure(realtimePlot);
    catch err
        realtimePlot = figure();
    end

    nrchans = 0;
    for dev=1:length(settings.device_ids)
        nrchans = nrchans + length(settings.channels{dev});
    end

    [pw,f] = pwelch(data,[],[],[],settings.fsamp);

    tiledlayout(nrchans,2,'TileSpacing','none','Padding','loose')
    
    for ch=1:nrchans
        nexttile
        %subplot(nrchans,2,2*ch-1);
        plot(t, data(:,ch));
        ylabel(settings.channel_names{ch});
        nexttile

        %subplot(nrchans,2,2*ch);
        loglog(f,pw(:,ch));
        
    end
end

function is_full = append_dataBuffer(time, data, settings)
    global dataBuffer;
    % if dataBuffer is empty, create it
    if(isempty(dataBuffer))
        
        dataBuffer.settings = settings;
        dataBuffer.max_size = settings.recording_time*settings.fsamp; % max size before dumping in .mat file
        
        dataBuffer.data = zeros(); % preallocate data
        
        dataBuffer.data = zeros(dataBuffer.max_size, ...
            settings.nrchans);
        dataBuffer.time = zeros(dataBuffer.max_size, ...
            1);
        
        dataBuffer.lastPos = 0; % last time index
    end
    % if dataBuffer is not empty, append data
    dataBuffer.data( (dataBuffer.lastPos+1): (dataBuffer.lastPos+size(data,1)),:) = ...
        data;
    dataBuffer.time( (dataBuffer.lastPos+1): (dataBuffer.lastPos+size(time,1)),:) = ...
        time;
    dataBuffer.lastPos = dataBuffer.lastPos+size(data,1);
    
    % check dataBuffer.size vs dataBuffer.max_size
    if(dataBuffer.lastPos >= dataBuffer.max_size)
        is_full = true;
    else
        is_full = false;
    end
end

function data = get_dataBuffer()
    global dataBuffer;
    
    data = dataBuffer;
    clear global dataBuffer;
end
