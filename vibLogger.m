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
    
    while(scan_count < settings.max_acq_no)
        s.DurationInSeconds = settings.recording_time;

        acq_date = datetime('now');

        [data,time] = s.startForeground;

        save_filename = strcat(settings.output_folder, ...
            filesep,datestr(acq_date,'yyyymmdd_HHMMss'),'.mat');
        
        save(save_filename,'data','time','acq_date','settings');

        scan_count = scan_count+1;
        if(settings.recording_pause)
            pause(settings.recording_pause);
        end
        
        if settings.live_preview
            
        end
        
        fprintf('Acquiring %d/%d\n',scan_count,settings.max_acq_no);
        drawnow
    end

    if(~exist(strcat(settings.output_folder,filesep,'config.m'),'file'))
        fun_path = fileparts(which('vibLogger'));
        copyfile(strcat(fun_path,filesep,'/Copy_of_config.m'),...
            strcat(settings.output_folder,filesep,'config.m'));
        
        open(strcat(settings.output_folder,filesep,'config.m'));
    end
end