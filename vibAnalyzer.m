%VIBANALYZER(settings) processes vibration data from VIBLOGGER
%   
%   VIBANALYZER(settings) runs the analysis code with settings specified
%   in the settings structure. Parameters: (? denotes optional)
%
%   settings.
%     data_folder (string): folder where data was saved by vibLogger
%     output_file (string): .mat file where to save the processed data
%     ? nrfiles (int): number of files to analyse. If not found, will process all files.
%
%     RESET_PROCESSED (bool): resets the output_file data
%     CHECK_PLOTS (bool): plots for debugging. Use with caution
%
%     // frequency and data integration related stuff
%     nrchunks (int): number of chunks to split data into before integration
%     nrwindows (int): number of windows for transmissibility ratio
%
%     fcut (float): lowpass cutoff frequency in Hz
%     spectrogram_freqs (array of float): spectral lines for spectrograms
%
%     is_velo (bool): set to TRUE if the measurements are already in velocity. 
%
%     // third octave band analysis config
%     octave_opts: options for octave analysis
%                  example: {'FrequencyLimits',[3.15 500],'BandsPerOctave',3}
%
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%  see also: VIBLOGGER, VIBPLOTS, SENSORS_DB

function vibAnalyzer(settings)

run(strcat(settings.data_folder,filesep,'config.m'));

% check for legacy configuration and throw warning
if(exist('conv_factor','var'))
    warning(['Old configuration file found. Consider updating to new format by '...
    'replacing conv_factor with sensor_ids']);
else
    conv_factor = sensors_db(sensor_ids);
end

%% process files one by one
files = ls([settings.data_folder,filesep,'*.mat']);

rms_disp = [];
integr_disp = [];
p2p_disp = [];
psd_vib = [];
acq_times = [];
acq_times_file = [];

%rms_disp_v2 = [];
%p2p_disp_v2 = [];
psd_vib_disp = [];

if(~isfield(settings,'nrfiles'))
    nrfiles = size(files,1);
else
    nrfiles = min(size(files,1),settings.nrfiles);
end

if(not(settings.RESET_PROCESSED) && exist(settings.output_file,'file'))
    try
        load(settings.output_file);
    catch err
        if(strcmp(err.identifier, 'MATLAB:load:unableToReadMatFile'))
            % if the file is broken we just delete it and pretend that we
            % are resetting it
            settings.RESET_PROCESSED = true;
            fprintf('Output file looks corrupted. Deleting and reprocessing\n');
        else
            fprintf(err.identifier);
            rethrow(err);
        end
    end
end

if(settings.is_velo)
    warning('Data is set to be interpreted as velocity. Check this is intended.');
end

if(exist('f','var'))
    if(isempty(f))
        error('variable f is empty... double check .mat file and retry');
    end
    f_zero = f+1;
else
    f_zero = 1;
end

nrchans = length(conv_factor);

wb = waitbar(0,sprintf('Processing file %.0d of %.0d',0,nrfiles));
for f=f_zero:nrfiles
    waitbar(f/nrfiles,wb,sprintf('Processing file %.0d of %.0d',f,nrfiles));
    
    % try to open the file... with network locations this may fail
    % occasionally so we wait and retry a few times
    attempt = 1;
    success = false;
    while (attempt <= 5) && ~success
        try
            filename = strcat(settings.data_folder,filesep,files(f,:));
            data = load(filename);
            success = true;
            skip_file = false;
        catch err
            attempt = attempt + 1;
            if(strcmp(err.identifier, 'MATLAB:load:couldNotReadFile') ||...
                strcmp(err.identifier, 'MATLAB:load:couldNotReadFileSystemMessage') ||...
                strcmp(err.identifier, 'MATLAB:load:cantReadFile'))
                % pause for a bit1 second times the current iteration no.
                % display a message
                pause_time = attempt * 1;
                fprintf('Error accessing %s, pausing for %.0ds\n',filename,pause_time);
                pause(pause_time);
            elseif(strcmp(err.identifier, 'MATLAB:load:unableToReadMatFile'))
                skip_file = true;
                fprintf('Unable to read %s - skipping - consider removing the file if this happens again\n',filename);
            else
                fprintf(err.identifier);
                rethrow(err);
            end
        end
    end
    
    if(skip_file)
        continue;   % this is horrible but it works... some errors will trigger a skip rather than a retry
    end
    
    if(~success)    
        rethrow(err);
    end
    
    % first - remove DC offsets
    y = detrend(data.data);
    y = y ./ conv_factor;
    
    
    % chop into 1 second long chunks - this is needed for integration
    for chan=1:size(y,2)

        % lowpass filter
        if(true)
            if(exist('lowpass_filter','var'))
                 %y1 = lowpass_filter.filter(y(:,chan));
                 y1 = y(:,chan);
            else
                %[y1, lowpass_filter] = lowpass(y(:,chan),settings.fcut,data.fsamp);
                y1 = y(:,chan);
            end
        end
        
        %y1 = lowpass(y(:,chan),fcut,data.fsamp);
        
        % if reshape fails, we need to pad the matrix's end
        try
            accel = reshape(y1,[],settings.nrchunks);
        catch reshape_err
            if (strcmp(reshape_err.identifier,'MATLAB:getReshapeDims:notDivisible'))
                padsize = ceil(size(y1,1)/settings.nrchunks)*settings.nrchunks - size(y1,1); % find the number of zeros needed to pad on the end
                y1 = padarray(y1,padsize,0,'post');
                accel = reshape(y1,[],settings.nrchunks);
            else
                rethrow(reshape_err)
            end
        end
        
        % transform accel into displacement    
        
        if(~settings.is_velo)
            velo = velo2disp(y1,1/data.fsamp);
        else
            velo = y1;
        end
        
        disp = velo2disp(velo,1/data.fsamp);
        
        % velocity octave spectrum in um/s
        [p,cf] = poctave(velo./1e03,data.fsamp,settings.octave_opts{:});

        velo_octave_spec(chan,:,f) = p;
        
        % calculate RMS
        %rms_disp_chunk(chan,:) = rms(disp);
        %p2p_disp_chunk(chan,:) = peak2peak(disp);   
        
        
        % calculate RMS via integrated FFT
        if(~settings.is_velo)
            [integr, ff, spec_disp, rms_disp_ff] = fft_integrated_accel2disp(accel, data.fsamp, settings.highpass);
        else
            [integr, ff, spec_disp, rms_disp_ff] = fft_integrated_accel2disp(accel, data.fsamp, settings.highpass, 'velocity');
        end
        
        integr_disp_chunk(chan,:) = mean(integr);
        rms_disp_chunk(chan,:) = rms_disp_ff;
        p2p_disp_chunk(chan,:) = 2*sqrt(2)*max(integr');
        
        % calculate spectra
        [pxx, freq] = pwelch(y1,[],1,settings.spectrogram_freqs,data.fsamp);
        
        psd_vib_block(chan,:) = pxx;
        
        psd_vib_block_disp(chan, :) = mean(spec_disp);
        
        % debug plots
        if settings.CHECK_PLOTS
            figure();
            subplot(3,2,1);
            plot(accel);
            ylabel('accel');
            subplot(3,2,3);
            plot(velo);
            ylabel('velocity');
            subplot(3,2,5);
            plot(disp);
            ylabel('displacement');
            
            subplot(3,2,[2 4 6])
            semilogx(freq,10*log10(pxx));
            xlabel('Freq');
            ylabel('PSD');
            legend({sprintf('chan %.0f',chan)},'location','southwest');
            legend boxoff
        end
    end
    
    
    
    integr_disp = cat(3,integr_disp,integr_disp_chunk);
    rms_disp = cat(2,rms_disp,rms_disp_chunk);
    p2p_disp = cat(2,p2p_disp,p2p_disp_chunk);
    psd_vib = cat(3,psd_vib,psd_vib_block);
    
    psd_vib_disp = cat(3,psd_vib_disp,psd_vib_block_disp);
    
    %rms_disp_v2 = cat(2,rms_disp_v2,rms_disp_chunk);
    %p2p_disp_v2 = cat(2,p2p_disp_v2,p2p_disp_chunk);
    
    % acquisition times
    acq_t = data.acq_date:duration(0,0,data.recording_time/settings.nrchunks):data.acq_date+duration(0,0,data.recording_time);
    acq_times = cat(2,acq_times,acq_t(1:end-1));
    acq_times_file = [acq_times_file, data.acq_date];
    
    
    % transmissibility ratio (if the file has a "input" and "output"
    % parameter
    
    % can be overridden in runVibAnalyzer.m
    if(isfield(settings,'inputs'))
        inputs = settings.inputs;
        outputs = settings.outputs;
    end
    
    if(isfield(settings,'winoverlap'))
        transm_overlap = settings.winoverlap;
    else
        transm_overlap = 0.5;
    end
    
    if(exist('inputs','var'))
        winlen = length(data.data(:,inputs(1)))/settings.nrwindows;
        winoverlap = floor(winlen*transm_overlap);
        for iii=1:length(inputs)
            [transmiss_i, transmiss_freq, transmiss_coh] = ...
                modalfrf(data.data(:,inputs(iii)),data.data(:,outputs(iii)),data.fsamp,winlen,winoverlap,'Sensor','dis');
            transmiss(iii,f,:) = transmiss_i;
            coher(iii,f,:) = transmiss_coh;
        end
    end
end
waitbar(f/nrfiles,wb,sprintf('Finished processing (%.0d of %.0d)',f,nrfiles));

save(settings.output_file,'acq_times',...
    'integr_disp','rms_disp','p2p_disp','f',...
    'psd_vib','freq','acq_times_file','psd_vib_disp','ff',...
    'velo_octave_spec','cf',...
    'channel_names','settings');

if(exist('inputs','var'))
    save(settings.output_file, 'transmiss', 'coher', 'transmiss_freq','inputs','outputs',...
        '-append');
end


end