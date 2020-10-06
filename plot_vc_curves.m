function fig = plot_vc_curves(cf, velo_octave_spec, varargin)
%PLOT_VC_CURVES plots velocity curves against BS ISO 266-1997 third octave bands.
%   PLOT_VC_CURVES(cf, velo_octave_spec) plots VC curves using cf frequency
%   bands and velo_octave_spec octave band velocity values
%   
%   fig = PLOT_VC_CURVES(...) returns the generated figure object.
%
%   PLOT_VC_CURVES(x, y, 'Parameter', 'Value', ...) accepts the
%   following optional parameter/value pairs:
%       'FigureName': 'figure name'
%       'YLabel': 'Y label'
%       'Legend': {'chan 1', 'chan 2'...} (channel names)
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%   see also: VIBPLOTS, VIBLOGGER

% VC levels for VC curves (should not need changing)
vc_curves = [3.12 1.56 0.78 0.39 0.195 0.097 0.048 0.024 0.012];
vc_labels = {'VC-E','VC-F','VC-G','VC-H','VC-I','VC-J','VC-K','VC-L','VC-M'};

p = inputParser;

addParameter(p,'FigureName','Figure',@ischar);
addParameter(p,'YLabel','Y',@ischar);
addParameter(p,'Legend',{''});
addParameter(p,'Mode','Lines', @ischar);

parse(p,varargin{:});
opts = p.Results;

nr_chans = size(velo_octave_spec,1);

velo_octave_spec_mean = mean(velo_octave_spec,3);
velo_octave_spec_std = std(velo_octave_spec,0,3);
velo_octave_spec_max = max(velo_octave_spec,[],3);

vm = 10*log10(velo_octave_spec_mean);
vu = 10*log10(velo_octave_spec_mean + velo_octave_spec_std);
vmax = 10*log10(velo_octave_spec_max);

yl = [Inf 0];

fig = figure('name',opts.FigureName);
for ch=1:nr_chans
    subplot(1,nr_chans,ch);
    
    if(strcmp(opts.Mode, 'Lines'))
        semilogx(cf,vm(ch,:),'LineWidth',2);
        hold on;
        semilogx(cf,vu(ch,:));
        semilogx(cf,vmax(ch,:));
    
        legend({'Mean','+\sigma','max'},'location','SouthWest','EdgeColor','white','Color','white');
    elseif(strcmp(opts.Mode,'Area'))
        fill([cf; flipud(cf)], [vmax(ch,:),fliplr(vm(ch,:))]',[0.3 0.3 0.3]);
        ax=gca();
        set(ax, 'XScale', 'log');
        legend({'Mean-Max'},'location','SouthWest','EdgeColor','white','Color','white');
    end
    
    xlabel('Frequency (Hz)');
    ylabel(opts.YLabel);
    title(opts.Legend{ch});
    
    hold on;
    xx = xlim();
    for cvc = 1:length(vc_curves)
        plot(xx,[10*log10(vc_curves(cvc)) 10*log10(vc_curves(cvc))],'--k','HandleVisibility','off');
        text(xx(2),10*log10(vc_curves(cvc)),vc_labels{cvc});
    end
    
    %equalising Y limit
    yll = ylim();
    yl(1) = min(yl(1),yll(1));
    yl(2) = max(yl(2),yll(2));
    
    grid on;
end

for(ch=1:nr_chans)
    subplot(1,nr_chans,ch);
    ylim(yl);
    
end



end

