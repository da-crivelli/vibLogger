# vibLogger

Vibration data logger and analysis tools.
All the examples below are also available under the Examples folder as .m files.

## Logging data
To log data you need to call `vibLogger()` with a few configuration parameters. 
You can copy the following example in a .m script and run it.

**Caution:**
The code under `\\dc.diamond.ac.uk\` is in a working directory, therefore it may
and will break regularly, even during a measurement. Clone the master repository from Gitlab 
`https://gitlab.diamond.ac.uk/mca67379/viblogger` for a stable non-live 
copy, replace the path below with your local folder.

```matlab
clearvars
close all

% library path
addpath('\\dc.diamond.ac.uk\dls\science\users\mca67379\MATLAB\vibLogger');

settings = struct();

settings.device_id = 'cDAQ1Mod3';  % run "devices = daq.getDevices" and find the device ID

settings.channels = [0, 1, 2, 3];  % which channels to read 
settings.sensorIDs = {'50887','50983','50985','50984'};  %sensor IDs (run sensors_db('list') to see all sensors)
settings.channel_names = {'V building','H building','V slab','H slab'}; %channel names

%settings.transmiss_inputs = [1 2];  % only for transmissibility ratio tests.
%settings.transmiss_outputs = [3 4]; % Comment out for standard vibration test

settings.channel_type = 'IEPE';  % 'Voltage' for standard voltage
                                % 'IEPE' for IEPE / ICP sensors
settings.iepe_excitation_current = .004;                         
                        
settings.fsamp = 2048;   % sampling frequency in Hz
settings.recording_time = 1; % time to record in seconds per block
settings.timeout = 33;   % max acquisition time in seconds

settings.output_folder = '20200317_Office_Tests'; %where to save the results

settings.live_preview = true;   
settings.save_data = false;      % currently there is no way to 
                                % independently set the save and preview times

vibLogger(settings);
```

## Processing data

To process data you need to call the `vibAnalyzer()` function - see below example for available settings. The processor will save a single .mat file `settings.output_file` which can then be consumed by `vibPlotter()`.

```matlab
clearvars
close all

% library path
addpath('\\dc.diamond.ac.uk\dls\science\users\mca67379\MATLAB\vibLogger');

% configuration
settings = struct();

%% files and file processing
settings.data_folder = '20200210_R79_FloorToSextupole'; %where data was saved by vibAnalyzer
settings.output_file = '20200317_freq_1.mat'; % where to save the processed data file

%settings.nrfiles = 10;  % number of files to analyse. Comment out to process all files.

settings.RESET_PROCESSED = true; % reset the output_file data
settings.CHECK_PLOTS = true; % plots some debugging plots. warning: "TRUE" 
                    % may just crash Matlab if there's a lot of files

%% frequency and data integration related stuff
settings.nrchunks = 11;  %number of chunks to split data before integration
settings.nrwindows = 30; % number of windows for transmissibility ratio

settings.fcut = 600; % Hz, lowpass cutoff frequency
settings.spectrogram_freqs = 1:0.1:500; % spectral lines for spectrograms

settings.is_velo = false;    % set to TRUE if the measurements are already in velocity. 

%% third octave band analysis config
octave_band = [3.15 500];   % start and end of bands
bpo = 3;                    % bands per octave (3 = 1/3 octave)
settings.octave_opts = {'FrequencyLimits',octave_band,'BandsPerOctave',bpo};


%% run the analyzer
vibAnalyzer(settings);
```


## Plotting data

To produce plots, you need to call the `vibPlotter()` function - see below example for available settings. 
The plotter will save, if `SAVE_PLOTS` is set to `true`, a collection of .pdf and .png plots in addition to 
plotting them.


```matlab
clearvars
close all
close all hidden

addpath('\\dc.diamond.ac.uk\dls\science\users\mca67379\MATLAB\vibLogger');

% configuration
settings = struct();

%where the processed data was saved by vibAnalyzer
settings.processed_file = '20200317_freq_2.mat'; 

%where to save the figures (if SAVE_PLOTS is true)
settings.fg_output_folder = 'Plots\new_plots_test\';
settings.SAVE_PLOTS = false;
settings.SAVE_PDF = false;

% probability plot params
settings.prob_chart_distribution = 'LogNormal';
settings.prob_threshold = 0.99;

%settings.plots = {'all'};
settings.plots = {'integrated'};

settings.integrated_direction = 'increasing';

settings.coherence_filter = 0.2;

% sets bands for band-passed RMS plots
settings.freq_band_slice = 0:10:50;
settings.freq_band_slice(1) = 1;

% hours slices for by-hour statistics plots
%settings.hour_slices = [0 3 4 7 16 20 24];
settings.hour_slices = [0 3 8 16 24];


%% run the plotter
vibPlots(settings);

```