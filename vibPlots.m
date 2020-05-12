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
%	  // probability plot params
%     prob_chart_distribution (string): probability chart distribution. 'none', 'LogNormal', ...
%     prob_threshold (float): probability threshold for calculating %prob values
%     
%     freq_band_slice (array of float): sets bands for band-passed RMS plots
%
%     // VC levels for VC curves (should not need changing)
%     vc_curves (array of int)
%     vc_labels (cell array of strings)
%   
%     hour_slices (array of float, 0 to 24): hours slices for by-hour statistics plots
%
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

%% time driven data

figures('rms_t') = plot_timeseries_hist(acq_times, rms_disp, ...
    'FigureName','RMS of vibration over time',...
    'YLabel','RMS [nm] from FFT',...
    'Legend',channel_names);

figures('p2p_t') = plot_timeseries_hist(acq_times, p2p_disp, ...
    'FigureName','P2P of vibration over time',...
    'YLabel','Peak to peak [nm]',...
    'Legend',channel_names);


%% stats & distributions

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

%% PSD of acceleration

for ch=1:nrchans
    figures(sprintf('PSD_accel_ch%d',ch)) = plot_spectrogram(acq_times, rms_disp(ch,:),...
        acq_times_file,freq,squeeze(10*log10(psd_vib(ch,:,:))), ...
        'FigureName', sprintf('PSD of acceleration, channel %s',channel_names{ch}),...
        'YLabel','Displacement RMS (nm)',...
        'Clabel','Acceleration (dB/Hz)',...
        'Legend',channel_names{ch});
end


%% PSD of displacement

for ch=1:nrchans
    figures(sprintf('PSD_disp_ch%d',ch)) = plot_spectrogram(acq_times, rms_disp(ch,:),...
        acq_times_file,ff,squeeze(10*log10(psd_vib_disp(ch,:,:))), ...
        'FigureName', sprintf('PSD of displacement, channel %s',channel_names{ch}),...
        'YLabel','Displacement RMS (nm)',...
        'Clabel','Displacement (dB/Hz)',...
        'Legend',channel_names{ch});
end


die

%% mean PSD

figures('mean_accel_PSD') = figure();

for chan=1:nrchans
    loglog(freq,mean(squeeze(psd_vib(chan,:,:)),2))
    hold on
end

legend(channel_names)


xlabel('Frequency [Hz]');
ylabel('Accel. power (eu)');
grid on;

%% Displacement PSD

%f_spc_noise = 1:300;
%amp_spc_noise = 3E03 ./ (4*pi^2 .*(ff.^2))';


figures('mean_disp_PSD') = figure();
for chan=1:nrchans
    loglog(ff,mean(squeeze(psd_vib_disp(chan,:,:)),2))
    hold on;
end

%x
%semilogy(ff,amp_spc_noise,':k');
%legend([channel_names,{'Noise floor'}]);
legend(channel_names);

xlim([-Inf settings.freq_band_slice(end)])

xlabel('Frequency [Hz]');
ylabel('Displacement/freq (nm/Hz)');
grid on



%% integrated displacement
figures('integrated_disp') = figure('name','Integrated displacement');

% mean plots
for chan=1:nrchans
    subplot(1,nrchans,chan);
    idd = mean(squeeze(integr_disp(chan,:,:)),2);
    h = semilogx(ff,idd,'linewidth',2);
    hold on;
    col(chan,:) = get(h,'color');
    
    
    % label at the end with RMS value
    text(ff(end),idd(end),sprintf('\\leftarrow RMS\n %.2f',idd(end)));
    
end

% max & min
for chan=1:nrchans
    subplot(1,nrchans,chan);
    line_color = col(chan,:);
    
    semilogx(ff,mean(squeeze(integr_disp(chan,:,:)),2)+std(squeeze(integr_disp(chan,:,:))')','--r');
    semilogx(ff,max(squeeze(integr_disp(chan,:,:))'),'--','Color',line_color);
    semilogx(ff,min(squeeze(integr_disp(chan,:,:))'),':','Color',line_color);
    
    yl1(chan,:) = ylim();
end

for chan=1:nrchans
    subplot(1,nrchans,chan);
    %xlim([-Inf settings.freq_band_slice(end)]);
    xlabel('Frequency [Hz]');
    if(chan==1); ylabel('Integrated displacement (nm)'); end;
    title(channel_names{chan});
    grid on
    legend({'mean','+1\sigma','max','min'},'location','best');
    ylim([min(yl1(:,1)),max(yl1(:,2))]);
end



%% Third octave plots

figures('VC_curves') = figure('name','VC curves and velocity third octave bands');

velo_octave_spec_mean = mean(velo_octave_spec,3);
velo_octave_spec_std = std(velo_octave_spec,0,3);
velo_octave_spec_max = max(velo_octave_spec,[],3);

vm = 10*log10(velo_octave_spec_mean);
vu = 10*log10(velo_octave_spec_mean + velo_octave_spec_std);
vmax = 10*log10(velo_octave_spec_max);

yl = [Inf 0];

for ch=1:nrchans
    subplot(1,nrchans,ch);
    %semilogx(cf,squeeze(velo_octave_spec(ch,:,:)))
    
    semilogx(cf,vm(ch,:),'LineWidth',2);
    hold on;
    semilogx(cf,vu(ch,:));
    semilogx(cf,vmax(ch,:));
    
    
    legend({'Mean','+\sigma','max'},'location','best');
    
    xlabel('Frequency (Hz)');
    ylabel('RMS velocity (dB re 1 um/s)');
    title(channel_names{ch});
    
    hold on;
    xx = xlim();
    for cvc = 1:length(settings.vc_curves)
        plot(xx,[10*log10(settings.vc_curves(cvc)) 10*log10(settings.vc_curves(cvc))],'--','HandleVisibility','off');
        text(xx(2),10*log10(settings.vc_curves(cvc)),settings.vc_labels{cvc});
    end
    
    %equalising Y limit
    yll = ylim();
    yl(1) = min(yl(1),yll(1));
    yl(2) = max(yl(2),yll(2));
end

for(ch=1:nrchans)
    subplot(1,nrchans,ch);
    ylim(yl);
end




%% "band pass" plots

for chan = 1:nrchans
    figures(sprintf('band_RMS_ch%d',chan)) = figure('name',sprintf('band_RMS_ch%d',chan));
    
    for fbin = 1:(length(settings.freq_band_slice)-1)
        bin_idxs = ff>=settings.freq_band_slice(fbin) & ff<(settings.freq_band_slice(fbin+1));
        freq_slice(chan,fbin,:) = sum(psd_vib_disp(chan,bin_idxs,:),2);
        freq_slice_legend{fbin} = sprintf('%dHz - %dHz',settings.freq_band_slice(fbin), settings.freq_band_slice(fbin+1));
        
    end
     
    semilogy(acq_times_file,squeeze(freq_slice(chan,:,:)));
    ylabel(['Band-passed RMS displacement (nm), ',channel_names{chan}]);
    legend(freq_slice_legend,'Location','NorthEastOutside');
    grid on;
end

%% "band pass" histograms

for chan = 1:nrchans
    figures(sprintf('band_hist_ch%d',chan)) = figure('name',sprintf('band_hist_ch%d',chan));
    
    for fbin = 1:(length(settings.freq_band_slice)-1)
        [n,edges] = histcounts(freq_slice(chan,fbin,:));
        
        patch([edges(1) edges(1:end-1) edges(end)], ...
            repmat(settings.freq_band_slice(fbin),length(edges(1:end-1))+2,1), ...
            [0 n 0], fbin);
        hold on;
    end
    set(gca,'xscale','log')
    
    %semilogy(acq_times_file,squeeze(freq_slice(chan,:,:)));
    xlabel(['Band-passed RMS displacement (nm), ',channel_names{chan}]);
    ylabel('Frequency (Hz)');
    zlabel('Counts');    
    legend(freq_slice_legend);
    grid on;
    view(-5, 45);
    
end


%% by hour of day

hourOfDay = hour(acq_times); 
% Determine which time stamps are between each time slice

figures('RMS_by_time') = figure('name','RMS by hour of day');

for hh=1:(length(settings.hour_slices)-1)
    subplot(length(settings.hour_slices)-1,1,hh)
    b = [settings.hour_slices(hh),settings.hour_slices(hh+1)]; %[start, end] of desired time bounds (24 hr format)
    selectedTimes = hourOfDay >= b(1) & hourOfDay <= b(2); 
    % isolate all rows of timetable between desired time bounds
    for ch=1:nrchans
        histogram(rms_disp(ch,selectedTimes),'Normalization','pdf');
        hold on;
    end
    
    a = ylim;
    text(10,a(2)*0.85,sprintf('between %d-%d hours (nm)',b(1),b(2)),'HorizontalAlignment','center')
    
    if(hh==(length(settings.hour_slices)-1)); xlabel('RMS displacement'); end;
    if(hh==2); ylabel('Probability density'); end;
    xlim([0 xl_rms]);
    if(hh==1); legend(channel_names); end;
    
    if(hh < (length(settings.hour_slices)-1)); set(gca,'XTick',[]); end;
    
    pos = get(gca, 'Position');
    %pos(1) = 0.055;
    pos(4) = 1/((length(settings.hour_slices)-1))-0.03;
    set(gca, 'Position', pos)
    grid on
    
end


%% by weekday
dayOfWeek = weekday(acq_times); 
% Determine which time stamps are between each time slice

figures('RMS_by_weekday') = figure('name','RMS by day of week');

for dd=1:7
    subplot(7,1,dd)
    selectedTimes = dayOfWeek == dd;
    
    ld = acq_times(selectedTimes);
    if(~isempty(ld))
        [~,dname] = weekday(ld(1));
    else
        dname = 'n/a';
    end
    % isolate all rows of timetable between desired time bounds
    for ch=1:nrchans
        histogram(rms_disp(ch,selectedTimes),'Normalization','pdf');
        hold on;
    end
    if(dd==7); xlabel('RMS displacement (nm)'); end;
    if(dd==3); ylabel('Probability density'); end;
    xlim([0 xl_rms]);
    if(dd==1); legend(channel_names); end;
    
    if(dd < 7); set(gca,'XTick',[]); end;
    
    a = ylim;
    text(10,a(2)*0.85,sprintf('On %s',dname),'HorizontalAlignment','center')
    
    pos = get(gca, 'Position');
    %pos(1) = 0.055;
    pos(4) = 1/7-0.03;
    set(gca, 'Position', pos)
    grid on
    
end

%% transmissibility ratio plots if variables are set

%[transmiss_i, transmiss_freq, transmiss_coh] = modalfrf(data.data(:,inputs(iii)),data(:,outputs(iii)),data.fsamp,winlen);
%            transmiss(iii,f,:) = transmiss_i;
%            coher(iii,f,:) = transmiss_coh;

 

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