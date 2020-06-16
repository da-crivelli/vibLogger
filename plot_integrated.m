function fig = plot_integrated(f, integr_disp, varargin)
%PLOT_INTEGRATED plots the integrated displacement plot from
%integrated displacement data.
%   PLOT_INTEGRATED(f, psd) calculates and plots the integrated
%   displacement from the integr_disp (as input).
%   the PSD matrix is a CxFxN matrix (channels, frequency, set) and is
%   averaged along the N dimension.
%
%   fig = PLOT_INTEGRATED(f, integr_disp) returns the generated figure object.
%
%   PLOT_INTEGRATED(f, integr_disp, 'Parameter', 'Value', ...) accepts the
%   following optional parameter/value pairs:
%       'FigureName': 'figure name'
%       'YLabel': 'Y label'
%       'Legend': {'chan 1', 'chan 2'...} (channel names)
%       'Direction': 'increasing' (default) or 'decreasing'
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%   see also: VIBPLOTS, VIBLOGGER

p = inputParser;

addParameter(p,'FigureName','Figure',@ischar);
addParameter(p,'YLabel','Y',@ischar);
addParameter(p,'Legend',{''});
addParameter(p,'Direction','increasing',@(x) any(strcmp({'increasing','decreasing'},x)) );

parse(p,varargin{:});
opts = p.Results;

if(strcmp(opts.Direction, 'decreasing'))
    error('Not supported yet');
else
    integr_avg = mean(integr_disp,3);
    integr_max = max(integr_disp,[],3);
    integr_min = min(integr_disp,[],3);
end

nr_chans = size(integr_disp,1);

fig = figure('name',opts.FigureName);

if(strcmp(opts.Direction, 'increasing'))
    loc = 'SouthEast';
else
    loc = 'NorthEast';
end

for ch=1:nr_chans
    subplot(1,nr_chans,ch);
    h = semilogx(f,integr_avg(ch,:),'linewidth',2);
    hold on;
    semilogx(f,integr_max(ch,:),'--','Color',get(h,'color'));
    semilogx(f,integr_min(ch,:),':','Color',get(h,'color'));
    title(opts.Legend{ch});
    xlabel('Frequency (Hz)');
    if(ch==1); ylabel(opts.YLabel); end
    grid on;
        
    legend({'Mean','Max','Min'}, 'EdgeColor','white','Color','white','Location',loc);
    
    yl(ch,:) = ylim();
end

% equalise Y limits
for ch=1:nr_chans
    subplot(1, nr_chans, ch);
    ylim([min(yl(:,1)),max(yl(:,2))]);
end

end