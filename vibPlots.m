%   VIBPLOTS(settings) plots data processed by vibAnalyzer
%
%   settings.
%     processed_file (string): where the processed data was saved by vibAnalyzer
%     ? datetime_range (cell of string): start and end date to plot
%     SAVE_PLOTS (bool): whether to save all plots in .pdf and .png form
%     SAVE_PDF (bool): if set to false, will only save a .png
%     SAVE_FIG (bool): whether to save a Matlab .fig figure file
%     fg_output_folder (string): where to save the plot files
%
%     plots (cell of strings): which plots to show (see below)
%
%     integrated_direction (string): direction for integrated displacement plot. 'increasing' or 'decreasing'
%
%	  // probability plot params
%     prob_chart_distribution (string): probability chart distribution. 'none', 'LogNormal', ...
%     prob_threshold (float): probability threshold for calculating %prob values
%
%     freq_band_slice (array of float): sets bands for band-passed RMS plots
%
%     hour_slices (array of float, 0 to 24): hours slices for by-hour statistics plots
%
%     // transmissibility
%     transmiss_range (2x1 array): frequency range for limiting transmissibility plots
%     coherence_filter (float 0-1): value at which to filter coherence for
%     highlighting in transmissibility plots
%
%     // display
%     vc_mode: 'Area' or 'Lines' ('Area' shades the area between the mean-max lines);
%
%   Available plots:
%     all: all available plots
%     time: RMS and P2P of displacement vs time, with distributions
%     distributions: probability distributions with distribution charts
%     spectrograms: spectrograms of RMS displacement and acceleration
%     psd: displacement and acceleration PSD plots
%     integrated: integrated displacement
%     vc_curves: VC curves / third octave plots
%     vc_peak: peak velocity of VC curve over the file timebase
%     band_rms: RMS by frequency band
%     distributions_hourly: distribution by hour band of the day set (hour_slices)
%     distributions_weekday: distributions by week day
%     transmissibility: transmissibility ratio plots
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger
%
%   see also VIBLOGGER, VIBANALYZER, SENSORS_DB


function vibPlots(opts, cached_data)

addpath(strcat(fileparts(which(mfilename)),filesep,'plots'));
addpath(strcat(fileparts(which(mfilename)),filesep,'utils'));

%% variable prep and config
if(~exist('cached_data','var'))
    load(opts.processed_file);
else
    fn = fieldnames(cached_data);
    for k=1:length(fn)
        eval([fn{k} '=cached_data.',fn{k},';']);
    end
end

nrchans = size(rms_disp,1);

% if we're looking for a specific datetime range, at the moment the best
% option is to just chop the data before & after...
% (only supports a single range as of now)
if(isfield(opts,'datetime_range'))
    start_time = find(acq_times >= opts.datetime_range{1},1);
    start_time_file = find(acq_times_file >= opts.datetime_range{1},1);
    end_time = find(acq_times < opts.datetime_range{2},1,'last');
    end_time_file = find(acq_times_file < opts.datetime_range{2},1,'last');

    acq_times = acq_times(start_time:end_time);
    acq_times_file = acq_times_file(start_time_file:end_time_file);

    p2p_disp = p2p_disp(:,start_time:end_time);
    rms_disp = rms_disp(:,start_time:end_time);

    psd_vib = psd_vib(:,:,start_time_file:end_time_file);
    psd_vib_disp = psd_vib_disp(:,:,start_time_file:end_time_file);
    integr_disp = integr_disp(:,:,start_time_file:end_time_file);

    velo_octave_spec = velo_octave_spec(:,:,start_time_file:end_time_file);
end

% are these needed at all?
%fupper = third_oct_bands_ctr * fd;
%flower = third_oct_bands_ctr / fd;

figures = containers.Map;

if(any(strcmp(opts.plots,'all')))
    plot_all = true;
else
    plot_all = false;
end

%% creates / prepares the figures output directory

if(isfield(opts,'SAVE_PLOTS'))
    if(opts.SAVE_PLOTS)
        if(isfield(opts,'datetime_range'))
            opts.fg_output_folder = strcat(opts.fg_output_folder, ...
                datestr(opts.datetime_range{1},'yyyymmdd'), '_',...
                datestr(opts.datetime_range{2},'yyyymmdd'),filesep);
        end

        if(isfield(opts,'fg_output_folder'))
            if(~isfolder(opts.fg_output_folder) && opts.SAVE_PLOTS)
                mkdir(opts.fg_output_folder);
            end
        end
    end
end



%% sets the "diary" file so that the output from some functions can be saved
if(isfield(opts,'SAVE_PLOTS'))
    if(opts.SAVE_PLOTS)
        diary_file = [opts.fg_output_folder,'stats.txt'];
        if(exist(diary_file,'file'))
            delete(diary_file);
        end
        diary(diary_file);
        diary on
    end
end

%% 'time': time driven data

if(any(strcmp(opts.plots,'time')) || plot_all)
    figures('rms_t') = plot_timeseries_hist(acq_times, rms_disp, ...
        'FigureName','RMS of vibration over time',...
        'YLabel','RMS [nm] from FFT',...
        'Legend',channel_names);

    figures('p2p_t') = plot_timeseries_hist(acq_times, p2p_disp, ...
        'FigureName','P2P of vibration over time',...
        'YLabel','Peak to peak [nm]',...
        'Legend',channel_names);
end


%% 'distributions': stats & distributions
if(any(strcmp(opts.plots,'distributions')) || plot_all)
    figures('distributions_RMS') = plot_prob_distribution(rms_disp, ...
        'FigureName', 'RMS distribution', ...
        'YLabel', 'RMS displacement [nm]', ...
        'Legend', channel_names, ...
        'ProbChart', opts.prob_chart_distribution, ...
        'ProbThreshold', opts.prob_threshold);

    figures('distributions_P2P') = plot_prob_distribution(p2p_disp, ...
        'FigureName', 'P2P distribution', ...
        'YLabel', 'P2P displacement [nm]', ...
        'Legend', channel_names, ...
        'ProbChart', opts.prob_chart_distribution, ...
        'ProbThreshold', opts.prob_threshold);
end

%% 'spectrograms': spectrogram of acceleration & displacement

if(any(strcmp(opts.plots,'spectrograms')) || plot_all)
    for ch=1:nrchans
        figures(sprintf('PSD_accel_ch%d',ch)) = plot_spectrogram(acq_times, rms_disp(ch,:),...
            acq_times_file,freq,squeeze(10*log10(psd_vib(ch,:,:))), ...
            'FigureName', sprintf('PSD of acceleration, channel %s',channel_names{ch}),...
            'YLabel','Displacement RMS (nm)',...
            'Clabel','Acceleration (dB/Hz)',...
            'Legend',channel_names{ch});
    end

    for ch=1:nrchans
        figures(sprintf('PSD_disp_ch%d',ch)) = plot_spectrogram(acq_times, rms_disp(ch,:),...
            acq_times_file,ff,squeeze(10*log10(psd_vib_disp(ch,:,:))), ...
            'FigureName', sprintf('PSD of displacement, channel %s',channel_names{ch}),...
            'YLabel','Displacement RMS (nm)',...
            'Clabel','Displacement (dB/Hz)',...
            'Legend',channel_names{ch});
    end
end

%% 'psd': mean PSD - accel and displacement

if(any(strcmp(opts.plots,'psd')) || plot_all)
    figures('mean_accel_PSD') = plot_psd(freq, squeeze(mean(psd_vib,3)),...
        'FigureName','mean_accel_PSD',...
        'YLabel','Acceleration power ((nm/s^2)^2 /Hz)',...
        'Legend',channel_names);


    figures('mean_disp_PSD') = plot_psd(ff, squeeze(mean(psd_vib_disp,3)),...
        'FigureName','mean_disp_PSD',...
        'YLabel','Displacement PSD (nm^2/Hz)',...
        'Legend',channel_names);
end



%% 'integrated': integrated displacement

if(any(strcmp(opts.plots,'integrated')) || plot_all)
    figures('integrated_disp') = plot_integrated(ff, integr_disp, ...
        'FigureName','integrated_disp',...
        'YLabel','Integrated displacement (nm), peak',...
        'Legend',channel_names, ...
        'Direction',opts.integrated_direction);
end


%% 'vc_curves': VC curves / third octave plots

if(any(strcmp(opts.plots,'vc_curves')) || plot_all)
    vc_mode = 'Lines';
    if(isfield(opts,'vc_mode'))
        vc_mode = opts.vc_mode;
    end
    perc = 0.99;
    if(isfield(opts,'prob_threshold'))
        perc = opts.prob_threshold;
    end
    figures('VC_curves') = plot_vc_curves(cf, velo_octave_spec, ...
        'FigureName','VC_curves',...
        'YLabel','1/3 octave RMS velocity (um/s)',...
        'Legend',channel_names,...
        'Mode',vc_mode,...
        'Percentile',perc);
end

%% 'vc_peak': VC curve peak over time slice
if(any(strcmp(opts.plots,'vc_peak')) || plot_all)
    figures('VC_peak') = plot_vc_peak(cf, velo_octave_spec, acq_times_file, ...
        'FigureName','VC_peak',...
        'YLabel','1/3 octave peak RMS velocity (um/s)',...
        'Legend',channel_names);
end


%% 'band_rms': "band pass" plots

if(any(strcmp(opts.plots,'band_rms')) || plot_all)
    for chan = 1:nrchans
        for fbin = 1:(length(opts.freq_band_slice)-1)
            bin_idxs = ff>=opts.freq_band_slice(fbin) & ff<(opts.freq_band_slice(fbin+1));
            integrable_fft = diff(integr_disp,1,2);
            freq_slice(chan,fbin,:) = sum(integrable_fft(chan,bin_idxs,:));
            freq_slice_legend{fbin} = sprintf('%dHz - %dHz',opts.freq_band_slice(fbin),...
                opts.freq_band_slice(fbin+1));
        end

        fig_name = sprintf('band_RMS_ch%d',chan);
        figures(fig_name) = plot_timeseries_hist(...
            acq_times_file, squeeze(freq_slice(chan,:,:)),...
            'FigureName',fig_name,...
            'YLabel',['Band-passed RMS displacement (nm), ',channel_names{chan}],...
            'YScale','log',...
            'Legend',freq_slice_legend);
    end
    
    fprintf('\n== RMS by band (average, nm) ==\n');
    fprintf('Freq band');
    fprintf('\t%s',channel_names{:});
    fprintf('\n');
    avgs = mean(freq_slice,3);
    for fbin = 1:(length(opts.freq_band_slice)-1)
        fprintf('%s',freq_slice_legend{fbin});
        for chan = 1:nrchans
            fprintf('\t%.2f',avgs(chan,fbin));
        end
        fprintf('\n');
    end
    fprintf('\n');
end

%% 'distributions_hourly': by hour of day

if(any(strcmp(opts.plots,'distributions_hourly')) || plot_all)
    hourOfDay = hour(acq_times);
    for ch=1:nrchans
        for hh=1:(length(opts.hour_slices)-1)
            b = [opts.hour_slices(hh),opts.hour_slices(hh+1)]; %[start, end] of desired time bounds (24 hr format)
            selectedTimes = hourOfDay >= b(1) & hourOfDay < b(2);
            rms_bt = rms_disp(ch,:);
            rms_bt(~selectedTimes) = NaN;
            rms_bytime{hh} = rms_bt';

            hours_legend{hh} = sprintf('%d-%d hours (nm)',b(1),b(2));
        end

        fig_name = sprintf('RMS_by_time_ch%d',ch);
        figures(fig_name) = plot_prob_distribution(cell2mat(rms_bytime),...
            'FigureName',fig_name,...
            'YLabel',sprintf('RMS displacement  %s (nm)',channel_names{ch}),...
            'Legend', hours_legend);
    end
end


%% 'distributions_weekday': by weekday

if(any(strcmp(opts.plots,'distributions_weekday')) || plot_all)
    dayOfWeek = weekday(acq_times);
    for ch=1:nrchans
        for dd=1:7
            selectedTimes = dayOfWeek == dd;
            ld = acq_times(selectedTimes);
            if(~isempty(ld))
                [~,dname] = weekday(ld(1));
            else
                dname = 'n/a';
            end

            rms_bd = rms_disp(ch,:);
            rms_bd(~selectedTimes) = NaN;
            rms_byday{dd} = rms_bd';

            days_legend{dd} = dname;%sprintf('%d-%d hours (nm)',b(1),b(2));
        end

        fig_name = sprintf('RMS_by_weekday_ch%d',ch);
        figures(fig_name) = plot_prob_distribution(cell2mat(rms_byday),...
            'FigureName',fig_name,...
            'YLabel',sprintf('RMS displacement  %s (nm)',channel_names{ch}),...
            'Legend', days_legend);
    end
end

%% transmissibility ratio plots if variables are set

if(any(strcmp(opts.plots,'transmissibility')) || plot_all)
    if(exist('inputs','var'))
        for in=1:length(inputs)
            fig_name = sprintf('transmiss_%.0d_%.0d',inputs(in),outputs(in));
            fig_title = sprintf('Transmissibility ratio, %s vs %s', ...
                channel_names{inputs(in)},channel_names{outputs(in)});

            if(isfield(opts,'transmiss_range'))
                transmiss_range = opts.transmiss_range;
            else
                transmiss_range = [-Inf Inf];
            end
            figures(fig_name) = plot_transmissibility(transmiss_freq, ...
                transmiss(in,:,:), coher(in,:,:), ...
                'FigureName',fig_name, ...
                'FigureTitle',fig_title,...
                'CoherenceFilter',opts.coherence_filter, ...
                'FreqRange',transmiss_range);
        end
    end
end

%% figure setup and printing
fg_names = figures.keys;

% add figure label with the filename
for fg=1:length(figures)
    fgr = figure(figures(fg_names{fg}));
    annotation('textbox', [0,0,0,0], 'string', opts.output_file, ...
        'FitBoxToText', 'on', 'verticalalignment', 'bottom',...
        'Interpreter', 'none', 'LineStyle', 'none');
end

if(isfield(opts,'SAVE_PLOTS'))
    if(opts.SAVE_PLOTS)
        if(~exist(opts.fg_output_folder,'dir'))
            mkdir(opts.fg_output_folder);
        end

        for fg=1:length(figures)
            fgr = figure(figures(fg_names{fg}));
            fgr.WindowState = 'maximized';
            fgr.Position = [10 10 1200 600];

            for chi = 1:length(fgr.Children)
                axe = fgr.Children(chi);
                set(axe,'FontSize',10);
            end

            pause(1);
            set(fgr,'Units','Inches');
            pos = get(fgr,'Position');
            set(fgr,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
            if(opts.SAVE_PDF)
                print(strcat(opts.fg_output_folder,fg_names{fg}),'-dpdf','-r0');
            end
            if(opts.SAVE_FIG)
                savefig(fgr,strcat(opts.fg_output_folder,fg_names{fg}),'compact');
            end
            print(strcat(opts.fg_output_folder,fg_names{fg}),'-dpng','-r600');

        end

        diary off
    end
end

end
