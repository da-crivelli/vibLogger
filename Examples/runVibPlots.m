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
