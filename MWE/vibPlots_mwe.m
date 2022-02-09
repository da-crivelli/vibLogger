clearvars
close all
close all hidden

addpath('C:\Users\mca67379\Documents\MATLAB\viblogger');

% configuration
settings = struct();

%where the processed data was saved by vibAnalyzer
settings.processed_file = 'example_output/example.mat'; 

%where to save the figures (if SAVE_PLOTS is true)
settings.fg_output_folder = 'example_output/';
settings.SAVE_PLOTS = false;
settings.SAVE_PDF = false;

% probability plot params
settings.prob_chart_distribution = 'LogNormal';
settings.prob_threshold = 0.99;

settings.plots = {'transmissibility'};
%settings.plots = {'time','psd','integrated'};

settings.integrated_direction = 'increasing';

settings.coherence_filter = 0.2;

% sets bands for band-passed RMS plots
settings.freq_band_slice = 0:10:50;
settings.freq_band_slice(1) = 1;

% hours slices for by-hour statistics plots
%settings.hour_slices = [0 3 4 7 16 20 24];
settings.hour_slices = [0 3 8 16 24];


%% run the plotter
d = load('example_output\example.mat');
vibPlots(settings,d);
