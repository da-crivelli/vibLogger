clearvars
close all

addpath('\\dc\dls\science\groups\vibration\viblogger');

% configuration
settings = struct();

%% files and file processing
%settings.nrfiles = 10;  % number of files to analyse. Comment out to process all files.

settings.RESET_PROCESSED = true; % reset the output_file data
settings.CHECK_PLOTS = true; % plots some debugging plots. warning: "TRUE" 
                    % may just crash Matlab if there's a lot of files

%% frequency and data integration related stuff
settings.nrchunks = 30;  %number of chunks to split data before integration
settings.nrwindows = 30; % number of windows for transmissibility ratio

settings.highpass = 2;  % highpass frequency for RMS / integration
settings.fcut = 600; % Hz, lowpass cutoff frequency
settings.spectrogram_freqs = 1:1:500; % spectral lines for spectrograms

settings.is_velo = false;    % set to TRUE if the measurements are already in velocity. 

%% third octave band analysis config
octave_band = [3.15 500];   % start and end of bands
bpo = 3;                    % bands per octave (3 = 1/3 octave)
settings.octave_opts = {'FrequencyLimits',octave_band,'BandsPerOctave',bpo};

%% Transmissibility ratio
% settings.winoverlap = 0.67;    % transmissibility window overlap fraction

% inputs and outputs overwriting for transmissibility ratio
%settings.inputs = [1 2];
%settings.outputs = [3 3];

%% Batch run the analyzer
dirs = dir('Data\*');
dirs = dirs([dirs.isdir]);
dirs = dirs(~ismember({dirs.name},{'.','..'}));
fprintf('\nBatch processing begin\n');
for d=1:length(dirs)
    settings.data_folder = [dirs(d).folder,filesep,dirs(d).name]; %where data was saved by vibAnalyzer
    settings.output_file = ['processed\',dirs(d).name,'.mat']; % where to save the processed data file
    %vibAnalyzer(settings);
    fprintf('%2d/%2d done: %s\n',d, length(dirs), dirs(d).name);
end
fprintf('Batch processing done\n');