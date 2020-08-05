clearvars
%close all

addpath('\\dc.diamond.ac.uk\dls\science\users\mca67379\MATLAB\vibLogger');

% configuration
settings = struct();

%% files and file processing
settings.data_folder = 'example_data'; %where data was saved by vibAnalyzer
settings.output_file = 'example_output/example.mat'; % where to save the processed data file

%settings.nrfiles = 10;  % number of files to analyse. Comment out to process all files.

settings.RESET_PROCESSED = true; % reset the output_file data
settings.CHECK_PLOTS = true; % plots some debugging plots. warning: "TRUE" 
                    % may just crash Matlab if there's a lot of files

%% frequency and data integration related stuff
settings.nrchunks = 60;  %number of chunks to split data before integration
settings.nrwindows = 30; % number of windows for transmissibility ratio

settings.fcut = 600; % Hz, lowpass cutoff frequency
settings.spectrogram_freqs = 1:1:500; % spectral lines for spectrograms

settings.is_velo = false;    % set to TRUE if the measurements are already in velocity. 

%% third octave band analysis config
octave_band = [3.15 500];   % start and end of bands
bpo = 3;                    % bands per octave (3 = 1/3 octave)
settings.octave_opts = {'FrequencyLimits',octave_band,'BandsPerOctave',bpo};

settings.inputs = [1];
settings.outputs = [2];
settings.winoverlap = 0.5;

%% run the analyzer
vibAnalyzer(settings);