% Generate a couple of test data files for viblogger. Needs to run from
% the viblogger project's root folder
clearvars
close all

viblogger_dir = fileparts(pwd());

addpath(viblogger_dir);
addpath([viblogger_dir,filesep,'utils']);




%% config
run('test_data_config.m');

%% minimal config for viblogger
settings = struct();

settings.sensorIDs = {'unity','unity'};  %sensor IDs (run sensors_db('list') to see all sensors)
settings.channel_names = {'Test 1', 'Test 2'}; %channel names

settings.fsamp = fsamp;   % sampling frequency in Hz
settings.recording_time = tone_length; % time to record in seconds per block

settings.output_folder = [fileparts(mfilename('fullpath')),filesep,'_data']; %where to save the results

settings.save_data = true;

settings.acq_date = datetime('now');


if(~isfolder(settings.output_folder))
    mkdir(settings.output_folder);
end

of = dir(settings.output_folder);
if(length(of)>2)
    of([of.isdir]) = [];   %skip directories
    filenames = fullfile(settings.output_folder, {of.name});
    delete( filenames{:} )
    warning('Clearing data directory');
end

%% creates a config file
create_vib_config_file(strcat(settings.output_folder,filesep,'config.m'),settings);


%% generate signals and creates a set of data files


for fn=1:nr_files
    t_0 = tone_length*(fn-1);
    time = t_0:1/fsamp:(t_0+tone_length);

    % for each channel
    data = zeros([size(tone_freqs,1),size(time,2)]);
    
    for ch=1:size(tone_freqs,1)
        for fp=1:size(tone_freqs,2)
            for fa=[tone_freqs(ch,fp); tone_amps(ch,fp); tone_phase(ch,fp)]
                data(ch,:) = data(ch,:) + fa(2).*cos(2*pi*fa(1).*time + deg2rad(fa(3)));
            end
        end
        data(ch,:) = data(ch,:) + noise_amp.*randn([1,size(data,2)]);
    end
    
    % inspect / plot
    figure();
    plot(time, data)
    
    % runs save_data from vibLogger.m
    acq_date = settings.acq_date + seconds(t_0);
    save_filename = strcat(settings.output_folder, filesep,datestr(acq_date,'yyyymmdd_HHMMss'),'.mat');
    
    recording_time = settings.recording_time;
    
    time = time';
    data = data';
    
    save(save_filename,'data','time','settings','acq_date','fsamp','recording_time');
    fprintf('saved data %s\n',save_filename);
end

%% analyse data and generate processed file


% configuration
settings = struct();

settings.data_folder = strcat(viblogger_dir,filesep,'tests/_data'); %where data was saved by vibAnalyzer
settings.output_file = strcat(viblogger_dir,filesep,'tests/_processed/processed.mat'); % where to save the processed data file

settings.RESET_PROCESSED = true; % reset the output_file data
settings.CHECK_PLOTS = false; % plots some debugging plots. warning: "TRUE" 
                    % may just crash Matlab if there's a lot of files

% frequency and data integration related stuff
settings.nrchunks = 30;  %number of chunks to split data before integration
settings.nrwindows = 30; % number of windows for transmissibility ratio

settings.highpass = 1;  % highpass frequency for RMS / integration
settings.fcut = 250; % Hz, lowpass cutoff frequency
settings.spectrogram_freqs = 1:1:250; % spectral lines for spectrograms

settings.is_velo = false;    % set to TRUE if the measurements are already in velocity. 

%% third octave band analysis config
octave_band = [3.15 500];   % start and end of bands
bpo = 3;                    % bands per octave (3 = 1/3 octave)
settings.octave_opts = {'FrequencyLimits',octave_band,'BandsPerOctave',bpo};

%% Transmissibility ratio
settings.winoverlap = 0.67;    % transmissibility window overlap fraction

% inputs and outputs overwriting for transmissibility ratio
settings.inputs = [1];
settings.outputs = [2];

%% run the analyzer
if(~isfolder(fileparts(settings.output_file)))
    mkdir(fileparts(settings.output_file));
end

vibAnalyzer(settings);

