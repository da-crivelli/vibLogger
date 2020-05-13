%   VIBPLOTS(settings) plots data processed by vibAnalyzer
%   
%   VIBANALYZER(settings) runs the analysis code with settings specified
%   in the settings structure. Parameters: (? denotes optional)
%
%   settings.
%     processed_file (string): where the processed data was saved by vibAnalyzer
%     SAVE_PLOTS (bool): whether to save all plots in .pdf and .png form
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
%
%   Available plots:
%     all: all available plots
%     time: RMS and P2P of displacement vs time, with distributions
%     distributions: probability distributions with distribution charts
%     spectrograms: spectrograms of RMS displacement and acceleration
%     psd: displacement and acceleration PSD plots
%     integrated: integrated displacement
%     vc_curves: VC curves / third octave plots
%     band_rms: RMS by frequency band
%     distributions_hourly: distribution by hour band of the day set (hour_slices)
%     distributions_weekday: distributions by week day
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%   see also VIBLOGGER, VIBANALYZER, SENSORS_DB


function vibPlots(settings)


%% variable prep and config
load(settings.processed_file);  
nrchans = size(rms_disp,1);

% are these needed at all?
%fupper = third_oct_bands_ctr * fd; 
%flower = third_oct_bands_ctr / fd;

figures = containers.Map;

if(any(strcmp(settings.plots,'all')))
    plot_all = true;
else
    plot_all = false;
end

%% 'time': time driven data

if(any(strcmp(settings.plots,'time')) || plot_all)
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
if(any(strcmp(settings.plots,'distributions')) || plot_all)
    figures('distributions_RMS') = plot_prob_distribution(rms_disp, ...
        'FigureName', 'RMS distribution', ...
        'YLabel', 'RMS displacement [nm]', ...
        'Legend', channel_names, ...
        'ProbChart', settings.prob_chart_distribution, ...
        'ProbThreshold', settings.prob_threshold);

    figures('distributions_P2P') = plot_prob_distribution(p2p_disp, ...
        'FigureName', 'P2P distribution', ...
        'YLabel', 'P2P displacement [nm]', ...
        'Legend', channel_names, ...
        'ProbChart', settings.prob_chart_distribution, ...
        'ProbThreshold', settings.prob_threshold);
end

%% 'spectrograms': spectrogram of acceleration & displacement

if(any(strcmp(settings.plots,'spectrograms')) || plot_all)
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

if(any(strcmp(settings.plots,'psd')) || plot_all)
    figures('mean_accel_PSD') = plot_psd(freq, squeeze(mean(psd_vib,3)),...
        'FigureName','mean_accel_PSD',...
        'YLabel','Acceleration power (eu)',...
        'Legend',channel_names);


    figures('mean_disp_PSD') = plot_psd(ff, squeeze(mean(psd_vib_disp,3)),...
        'FigureName','mean_disp_PSD',...
        'YLabel','Displacement/freq (nm/Hz)',...
        'Legend',channel_names);
end



%% 'integrated': integrated displacement

if(any(strcmp(settings.plots,'integrated')) || plot_all)
    figures('integrated_disp') = plot_integrated(ff, psd_vib_disp, ...
        'FigureName','integrated_disp',...
        'YLabel','Integrated displacement (nm)',...
        'Legend',channel_names, ...
        'Direction',settings.integrated_direction);
end


%% 'vc_curves': VC curves / third octave plots

if(any(strcmp(settings.plots,'vc_curves')) || plot_all)
    figures('VC_curves') = plot_vc_curves(cf, velo_octave_spec, ...
        'FigureName','VC_curves',...
        'YLabel','RMS velocity (dB re 1 um/s)',...
        'Legend',channel_names);
end




%% 'band_rms': "band pass" plots

if(any(strcmp(settings.plots,'band_rms')) || plot_all)
    for chan = 1:nrchans
        for fbin = 1:(length(settings.freq_band_slice)-1)
            bin_idxs = ff>=settings.freq_band_slice(fbin) & ff<(settings.freq_band_slice(fbin+1));
            freq_slice(chan,fbin,:) = sum(psd_vib_disp(chan,bin_idxs,:),2);
            freq_slice_legend{fbin} = sprintf('%dHz - %dHz',settings.freq_band_slice(fbin), settings.freq_band_slice(fbin+1));
        end
    
        fig_name = sprintf('band_RMS_ch%d',chan);
        figures(fig_name) = plot_timeseries_hist(...
            acq_times_file, squeeze(freq_slice(chan,:,:)),...
            'FigureName',fig_name,...
            'YLabel',['Band-passed RMS displacement (nm), ',channel_names{chan}],...
            'YScale','log',...
            'Legend',freq_slice_legend);
    end
end

%% 'distributions_hourly': by hour of day

if(any(strcmp(settings.plots,'distributions_hourly')) || plot_all)
    hourOfDay = hour(acq_times); 
    for ch=1:nrchans
        for hh=1:(length(settings.hour_slices)-1)
            b = [settings.hour_slices(hh),settings.hour_slices(hh+1)]; %[start, end] of desired time bounds (24 hr format)
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

if(any(strcmp(settings.plots,'distributions_weekday')) || plot_all)
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

%[transmiss_i, transmiss_freq, transmiss_coh] = modalfrf(data.data(:,inputs(iii)),data(:,outputs(iii)),data.fsamp,winlen);
%            transmiss(iii,f,:) = transmiss_i;
%            coher(iii,f,:) = transmiss_coh;

 
die
if(exist('inputs','var'))

    for in=1:length(inputs)
        ang = mean(squeeze(rad2deg(angle(transmiss(in,:,:))))); 

        
        
        cohz = mean(squeeze(coher(in,:,:)));
        trz = mean(abs(squeeze(transmiss(in,:,:))));
        
        coh_i = cohz > 0.2;
        
        trz(~coh_i)=NaN;
        ang(~coh_i)=NaN;
        cohz(~coh_i)=NaN;
        
        y_data = {trz, ang, cohz};

        
        
        y_labels = {'Transmissibility ratio', 'Phase (deg)','Coherence'};

        figures(sprintf('transmiss_%.0d_%.0d',inputs(in),outputs(in))) = ...
            figure('name',sprintf('Transmissibility, %s to %s',channel_names{inputs(in)},channel_names{outputs(in)}));

        for i=1:3
            subplot(3,1,i);
            if(i==1)
                loglog(transmiss_freq,y_data{i});
                fffg=gcf();
                title(fffg.Name);
            else
                semilogx(transmiss_freq, y_data{i});
            end
            hold on;
            grid on;
            
            if(i==1); plot(minmax(settings.freq_band_slice),[1 1],'--r'); end
            ylabel(y_labels{i});
            xlim(minmax(settings.freq_band_slice))
            
            if(i==3); xlabel('Frequency (Hz)'); end
        end           
            
    end
end

%% figure setup and printing
if(settings.SAVE_PLOTS)
    fg_names = figures.keys;
    
    if(~exist(settings.fg_output_folder,'dir'))
        mkdir(settings.fg_output_folder);
    end
    
    for fg=1:length(figures)
        fgr = figure(figures(fg_names{fg}));
        fgr.WindowState = 'maximized';
       
        for chi = 1:length(fgr.Children)
            axe = fgr.Children(chi);
            set(axe,'FontSize',14);
        end
        
        pause(1);
        set(fgr,'Units','Inches');
        pos = get(fgr,'Position');        
        set(fgr,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])        
        print(strcat(settings.fg_output_folder,fg_names{fg}),'-dpdf','-r0');
        print(strcat(settings.fg_output_folder,fg_names{fg}),'-dpng','-r600');
    end

    fid = fopen([settings.fg_output_folder,'stats.txt'],'w');
    for ch=1:nrchans
        fprintf(fid,'RMS 99 percent prob, %s \t %.2d\n',channel_names{ch},rms_prob(ch));
        fprintf(fid,'P2P 99 percent prob, %s \t %.2d\n',channel_names{ch},p2p_prob(ch));
    end
    fclose(fid);

end
    
    
end