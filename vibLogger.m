%   VibLogger
%
%   logs data from a NI 9234 board
%   supports IEPE (ICP) accelerometers
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%

function vibLogger(settings)
    % create session & initialise device
    s = daq.createSession('ni');

    for ch=1:length(settings.channels)
        addAnalogInputChannel(s, settings.device_id, ...
                                 settings.channels(ch), ...
                                 settings.channel_type);
        s.Channels(ch).ExcitationCurrent = settings.iepe_excitation_current;
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
        end
    end

    if(~exist(strcat(settings.output_folder,filesep,'config.m'),'file'))
        
        % autowrite config file
        create_vib_config_file(strcat(settings.output_folder,filesep,'config.m'),settings);
        
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
    nrchans = length(settings.channels);
    nrcols = ceil(sqrt(nrchans));
    nrrows = ceil(nrchans/nrcols)*2;
    for ch=1:length(settings.channels)
        subplot(nrrows,nrcols,2*ch-1);
        plot(t, data(:,ch));
        
        subplot(nrrows,nrcols,2*ch);
        pwelch(data(:,ch),[],[],[],settings.fsamp);
        
    end
end