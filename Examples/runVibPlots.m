clearvars
close all
close all hidden

addpath('\\dc\dls\science\groups\vibration\viblogger');

% configuration
settings = struct();

%where the processed data was saved by vibAnalyzer
settings.processed_file = '20200317_freq_2.mat'; 

% start and end times for plots. Format: '31-May-2020 03:49:48'
% if you omit the time, it assumes the very start of the day.
settings.datetime_range = {'30-May-2020','31-May-2020'};

%where to save the figures (if SAVE_PLOTS is true)
settings.fg_output_folder = 'Plots\new_plots_test\';
settings.SAVE_PLOTS = false;
settings.SAVE_PDF = false;
settings.SAVE_FIG = false;

% probability plot params
settings.prob_chart_distribution = 'LogNormal';
settings.prob_threshold = 0.99;

%settings.plots = {'all'};
settings.plots = {'vc_peak'};

settings.integrated_direction = 'increasing';

settings.coherence_filter = 0.2;

% sets bands for band-passed RMS plots
settings.freq_band_slice = 0:10:50;
settings.freq_band_slice(1) = 1;

% hours slices for by-hour statistics plots
%settings.hour_slices = [0 3 4 7 16 20 24];
settings.hour_slices = [0 3 8 16 24];

% annotations file (to display annotations on time-based plots)
%opts.annotations_file = 'annotations.csv';

%% run the plotter
vibPlots(settings);
