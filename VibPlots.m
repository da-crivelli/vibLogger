%   VibPlots
%
%   plots data logged by VibLogger and processed by VibAnalyzer
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   v0.1 20200211 - initial release
%   

clearvars
close all
close all hidden

addpath('C:\Users\mca67379\OneDrive - Diamond Light Source Ltd\Matlab');


fname = '20200311_Mirror_I19_NoTMD';

processed_file = ['Processed\',fname,'.mat'];
    
fg_output_folder = ['Plots\',fname,'\'];

rms_probplot_cutoff = 100000;  %cutoff value for probability plot, nm
p2p_probplot_cutoff = 1000000;


third_oct_bands_ctr = 10.^(0.1:0.1:2);   % BS ISO 266-1997
fd = 10^0.05;


%freq_band_slice = [0:50:500];
freq_band_slice = [0:5:50];
freq_band_slice(1) = 1;

vc_curves = [0.78 0.39 0.195 0.097 0.048 0.024 0.012];
vc_labels = {'VC-G','VC-H','VC-I','VC-J','VC-K','VC-L','VC-M'};


hour_slices = [0 3 4 7 16 20 24];

SAVE_PLOTS = false;




%% variable prep and config
load(processed_file);
nrchans = size(rms_disp,1);

fupper = third_oct_bands_ctr * fd;
flower = third_oct_bands_ctr / fd;

figures = containers.Map;

%% time driven data
figures('rms_t') = figure('name','RMS of vibration over time');
for k=0:1
    subplot(2,3,(k*3+1):(k*3+2));
    plot(acq_times,rms_disp');
    
    if k==1; ylim([0 50]); end;
    
    grid on
    ylabel('RMS [nm] from FFT (over 1s)');
    xlabel('Dataset');
      
    legend(channel_names)
    
    yl = ylim();
    
    subplot(2,3,(k+1)*3)
    for c=1:nrchans
        histogram(rms_disp(c,:),'Normalization','pdf','Orientation','horizontal','EdgeColor','none');
        hold on;
        grid on
    end
    ylim(yl);
    xlabel('Probability density');
    ylabel('RMS [nm] from FFT (over 1s)');
    
end


figures('p2p_t') = figure('name','P2P of vibration over time');
for k=0:1
    subplot(2,3,(k*3+1):(k*3+2));
    plot(acq_times,p2p_disp');
    
    if k==1; ylim([0 150]); end;
    
    grid on;
    ylabel('Peak to peak [nm]');
    xlabel('Dataset');
    
    legend(channel_names)
    
    yl = ylim();
    
    subplot(2,3,(k+1)*3)
    for c=1:nrchans
        histogram(p2p_disp(c,:),'Normalization','probability','Orientation','horizontal','EdgeColor','none');
        hold on;
        grid on
    end
    ylim(yl);
    xlabel('Probability');
    ylabel('Peak to peak [nm]');
end
    

%% stats & distributions
figures('distributions') = figure();
subplot(1,2,1);


fprintf('\n== Stats ==\n');
for c=1:nrchans
    h(c) = histogram(rms_disp(c,:),'Normalization','probability');
    hold on;
    cv = find(cumsum(h(c).Values)>0.99,1);
    rms_prob(c) = h(c).BinEdges(cv);
    fprintf('RMS 99 percent prob, %s = %2.2f\n',channel_names{c},rms_prob(c));
end

xl_rms = round(max(rms_prob)/5)*5;
xlim([0 xl_rms]);
xlabel('RMS displacement [nm]')
ylabel('Probability');
legend(channel_names)



subplot(1,2,2);
for c=1:nrchans
    h(c) = histogram(p2p_disp(c,:),'Normalization','probability');
    hold on;
    cv = find(cumsum(h(c).Values)>0.99,1);
    p2p_prob(c) = h(c).BinEdges(cv);
    fprintf('P2P 99 percent prob, %s = %2.2f\n',channel_names{c},p2p_prob(c));
end

xl_p2p = round(max(p2p_prob)/5)*5;

xlabel('P2P displacement [nm]')
ylabel('Probability');
legend(channel_names)
xlim([0 xl_p2p]);



%% probability charts 
pdist = fitdist(-[rms_disp(1,rms_disp(1,:)<rms_probplot_cutoff)]','extreme value');
ci = paramci(pdist);
ev_up = evpdf(-[0:0.1:100],ci(1,1),ci(2,1));

figure();
probplot('extreme value',-[rms_disp(1,rms_disp(1,:)<rms_probplot_cutoff)]);
hold on;
probplot('extreme value',-ev_up);

%% PSD of acceleration

for ch=1:nrchans
    figures(sprintf('PSD_accel_ch%d',ch)) = figure('name',sprintf('PSD of accel, channel %s',channel_names{ch}));
    subplot(3,1,1);
    title(sprintf('Channel %.0d',ch));
    plot(acq_times,rms_disp(ch,:));
    legend(channel_names{ch});
    ylabel('Displacement RMS (nm)');
    subplot(3,1,2:3);
    %imagesc((1:length(psd_vib))./60,freq,squeeze(10*log10(psd_vib(ch,:,:))))
    surf(acq_times_file,freq,squeeze(10*log10(psd_vib(ch,:,:))),'EdgeColor','none');
    view(0,90);
    colormap(flipud(gray))
    cbar = colorbar('east');
    cbar.Label.String = 'Acceleration (dB/Hz)';
    xlabel('Hours');
    ylabel('Freq (Hz)')
    ax=gca();
end


%% PSD of displacement

%psd_vib_disp
%psd_vib_v2

for ch=1:nrchans
    figures(sprintf('PSD_accel_ch%d',ch)) = figure('name',sprintf('PSD of displacement, channel %s',channel_names{ch}));
    subplot(3,1,1);
    title(sprintf('Channel %.0d',ch));
    plot(acq_times,rms_disp(ch,:));
    legend(channel_names{ch});
    ylabel('Displacement RMS (nm)');
    subplot(3,1,2:3);
    %imagesc((1:length(psd_vib))./60,freq,squeeze(10*log10(psd_vib(ch,:,:))))
    surf(acq_times_file,ff,squeeze(10*log10(psd_vib_disp(ch,:,:))),'EdgeColor','none');
    %surf(acq_times_file,ff,squeeze(psd_vib_v2(ch,:,:)),'EdgeColor','none');
    view(0,90);
    ylim([0 250]);
    colormap(flipud(gray))
    cbar = colorbar('east');
    cbar.Label.String = 'Displacement (dB/Hz)';
    xlabel('Hours');
    ylabel('Freq (Hz)')
    ax=gca();
end



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

xlim([-Inf freq_band_slice(end)])

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
    %xlim([-Inf freq_band_slice(end)]);
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
    for cvc = 1:length(vc_curves)
        plot(xx,[10*log10(vc_curves(cvc)) 10*log10(vc_curves(cvc))],'--','HandleVisibility','off');
        text(xx(2),10*log10(vc_curves(cvc)),vc_labels{cvc});
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
    
    for fbin = 1:(length(freq_band_slice)-1)
        bin_idxs = ff>=freq_band_slice(fbin) & ff<(freq_band_slice(fbin+1));
        freq_slice(chan,fbin,:) = sum(psd_vib_disp(chan,bin_idxs,:),2);
        freq_slice_legend{fbin} = sprintf('%dHz - %dHz',freq_band_slice(fbin), freq_band_slice(fbin+1));
        
    end
     
    semilogy(acq_times_file,squeeze(freq_slice(chan,:,:)));
    ylabel(['Band-passed RMS displacement (nm), ',channel_names{chan}]);
    legend(freq_slice_legend,'Location','NorthEastOutside');
    grid on;
end

%% "band pass" histograms

for chan = 1:nrchans
    figures(sprintf('band_hist_ch%d',chan)) = figure('name',sprintf('band_hist_ch%d',chan));
    
    for fbin = 1:(length(freq_band_slice)-1)
        [n,edges] = histcounts(freq_slice(chan,fbin,:));
        
        patch([edges(1) edges(1:end-1) edges(end)], ...
            repmat(freq_band_slice(fbin),length(edges(1:end-1))+2,1), ...
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

for hh=1:(length(hour_slices)-1)
    subplot(length(hour_slices)-1,1,hh)
    b = [hour_slices(hh),hour_slices(hh+1)]; %[start, end] of desired time bounds (24 hr format)
    selectedTimes = hourOfDay >= b(1) & hourOfDay <= b(2); 
    % isolate all rows of timetable between desired time bounds
    for ch=1:nrchans
        histogram(rms_disp(ch,selectedTimes),'Normalization','pdf');
        hold on;
    end
    
    a = ylim;
    text(10,a(2)*0.85,sprintf('between %d-%d hours (nm)',b(1),b(2)),'HorizontalAlignment','center')
    
    if(hh==(length(hour_slices)-1)); xlabel('RMS displacement'); end;
    if(hh==2); ylabel('Probability density'); end;
    xlim([0 xl_rms]);
    if(hh==1); legend(channel_names); end;
    
    if(hh < (length(hour_slices)-1)); set(gca,'XTick',[]); end;
    
    pos = get(gca, 'Position');
    %pos(1) = 0.055;
    pos(4) = 1/((length(hour_slices)-1))-0.03;
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
            
            if(i==1); plot(minmax(freq_band_slice),[1 1],'--r'); end
            ylabel(y_labels{i});
            xlim(minmax(freq_band_slice))
            
            if(i==3); xlabel('Frequency (Hz)'); end
        end           
            
    end
end

%% figure setup and printing
if(SAVE_PLOTS)
    fg_names = figures.keys;
    
    if(~exist(fg_output_folder,'dir'))
        mkdir(fg_output_folder);
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
        print(strcat(fg_output_folder,fg_names{fg}),'-dpdf','-r0');
        print(strcat(fg_output_folder,fg_names{fg}),'-dpng','-r600');
    end

    fid = fopen([fg_output_folder,'stats.txt'],'w');
    for ch=1:nrchans
        fprintf(fid,'RMS 99 percent prob, %s \t %.2d\n',channel_names{ch},rms_prob(ch));
        fprintf(fid,'P2P 99 percent prob, %s \t %.2d\n',channel_names{ch},p2p_prob(ch));
    end
    fclose(fid);

end
    
    