function fig = plot_integrated(f, psd, varargin)
%PLOT_INTEGRATED plots the integrated displacement plot from a
%displacement PSD.
%   PLOT_INTEGRATED(f, psd) calculates and plots the integrated
%   displacement from the psd (as input).
%   the PSD matrix is a CxFxN matrix (channels, frequency, set) and is
%   averaged along the N dimension.
%
%   fig = PLOT_INTEGRATED(f, psd) returns the generated figure object.
%
%   PLOT_INTEGRATED(f, psd, 'Parameter', 'Value', ...) accepts the
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

avg_psd = mean(psd,3);
max_psd = max(psd,[],3);
min_psd = min(psd,[],3);

if(strcmp(opts.Direction, 'decreasing'))
    integr_avg = calc_integrated(f,avg_psd,'reverse');
    integr_max = calc_integrated(f,max_psd,'reverse');
    integr_min = calc_integrated(f,min_psd,'reverse');
else
    integr_avg = calc_integrated(f,avg_psd,[]);
    integr_max = calc_integrated(f,max_psd,[]);
    integr_min = calc_integrated(f,min_psd,[]);
end

nr_chans = size(psd,1);

fig = figure('name',opts.FigureName);

if(strcmp(opts.Direction, 'increasing'))
    loc = 'SouthEast';
    %ff = f(2:end);
else
    loc = 'NorthEast';
    %ff = f(1:end-1);
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

%% integrated displacement calculation function (from PSD)
function integrated = calc_integrated(f, psd, direction)
    if(isempty(direction))
        cs = (cumsum(psd,2));
    else
        cs = (cumsum(psd,2,direction));
    end    
    integrated = cs;   
end

