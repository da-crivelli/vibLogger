clearvars
close all
close all hidden

addpath('C:\Users\mca67379\Documents\MATLAB\viblogger');

% configuration
settings = struct();

%where the processed data was saved by vibAnalyzer
switch_day = 3;
switch_hour = 12;
settings.processed_file = strcat('./processed_data/',weekstring(switch_day,switch_hour),'.mat');

% start and end times for plots. Format: '31-May-2020 03:49:48'
% if you omit the time, it assumes the very start of the day.
%settings.datetime_range = {'30-May-2020','31-May-2020'};

%where to save the figures (if SAVE_PLOTS is true)
settings.fg_output_folder = strcat('./plots/',weekstring(switch_day,switch_hour),'/');
settings.SAVE_PLOTS = true;
settings.SAVE_PDF = false;
settings.SAVE_FIG = true;

% probability plot params
settings.prob_chart_distribution = 'LogNormal';
settings.prob_threshold = 0.99;

settings.plots = {'time','vc_curves','band_rms'};
%settings.plots = {'integrated'};

settings.integrated_direction = 'increasing';

settings.coherence_filter = 0.2;

% sets bands for band-passed RMS plots
settings.freq_band_slice = 0:25:250;
settings.freq_band_slice(1) = 1;

% hours slices for by-hour statistics plots
%settings.hour_slices = [0 3 4 7 16 20 24];
settings.hour_slices = [0 3 8 16 24];

diary(strcat('./logs/',weekstring(switch_day,switch_hour),'_plotter.txt'));


%% run the plotter
try
    vibPlots(settings);
catch e
    fprintf(1,'The identifier was:\n%s',e.identifier);
    fprintf(1,'There was an error! The message was:\n%s',e.message);
end
