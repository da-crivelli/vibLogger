clearvars
close all

addpath('C:\Users\mca67379\Documents\MATLAB\viblogger');

% configuration
settings = struct();

%% files and file processing

switch_day = 3;
switch_hour = 12;
settings.data_folder = strcat('./raw_data/',weekstring(switch_day,switch_hour));
settings.output_file = strcat('./processed_data/',weekstring(switch_day,switch_hour),'.mat'); % where to save the processed data file

%settings.nrfiles = 10;  % number of files to analyse. Comment out to process all files.

settings.RESET_PROCESSED = false; % reset the output_file data
settings.CHECK_PLOTS = false; % plots some debugging plots. warning: "TRUE" 
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

diary(strcat('./logs/',weekstring(switch_day,switch_hour),'_analyser.txt'));

%% run the analyzer
try
    vibAnalyzer(settings);
catch e
    fprintf(1,'The identifier was:\n%s',e.identifier);
    fprintf(1,'There was an error! The message was:\n%s',e.message);
end