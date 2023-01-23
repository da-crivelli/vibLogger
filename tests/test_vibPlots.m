% test script for vibAnalyzer
clearvars
close all

% find where we are... if running from command line or from the file itself
viblogger_dir = fileparts(pwd());

addpath(viblogger_dir);
addpath([viblogger_dir,'/plots']);


%% set up

settings.output_folder = []; %where to save the results


% configuration
settings = struct();

%where the processed data was saved by vibAnalyzer
settings.processed_file = [fileparts(mfilename('fullpath')),filesep,'_processed',filesep,'processed.mat']; 

%where to save the figures (if SAVE_PLOTS is true)
settings.fg_output_folder = 'example_output/';
settings.SAVE_PLOTS = false;
settings.SAVE_PDF = false;

% probability plot params
settings.prob_chart_distribution = 'LogNormal';
settings.prob_threshold = 0.99;

settings.plots = {'all'};

settings.integrated_direction = 'increasing';

settings.coherence_filter = 0.2;

% sets bands for band-passed RMS plots
settings.freq_band_slice = 0:10:50;
settings.freq_band_slice(1) = 1;

% hours slices for by-hour statistics plots
%settings.hour_slices = [0 3 4 7 16 20 24];
settings.hour_slices = [0 3 8 16 24];

%settings.annotations_file = 'example_output\annotations1.csv';


%% run the plotter
vibPlots(settings);
