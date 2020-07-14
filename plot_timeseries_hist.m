function fig = plot_timeseries_hist(x, y, varargin)
%PLOT_TIMESERIES_HIST plots timeseries data with a histogram as a subplot.
%   PLOT_TIMESERIES_HIST(x, y) plots x(time) vs y (values, N channels) and
%   associated histograms (as probability distributions)
%   
%   fig = PLOT_TIMESERIES_HIST(x, y) returns the generated figure object.
%
%   PLOT_TIMESERIES_HIST(x, y, 'Parameter', 'Value', ...) accepts the
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

p = inputParser;

addParameter(p,'FigureName','Figure',@ischar);
addParameter(p,'YLabel','Y',@ischar);
addParameter(p,'YScale','linear',@ischar);
addParameter(p,'Legend',{''});


parse(p,varargin{:});

% automagically roll Y axis around...
nr_pts = length(x);
[a,b] = size(y);
if(a == nr_pts)
    y = y';
    nr_chans = b;
else
    nr_chans = a;
end

opts = p.Results;

fig = figure('name',opts.FigureName);

% data plot
ax1 = subplot(1,3,1:2);
plot(x, y);
grid on
xlabel('Time');

ylabel(opts.YLabel);
%legend(opts.Legend, 'EdgeColor','white','Color','white';
    
% histogram plot
ax2 = subplot(1,3,3);
for c=1:nr_chans
    histogram(y(c,:),'Normalization','probability','Orientation','horizontal','EdgeColor','none');
    hold on;
    grid on
end

xlabel('Probability density');

%ylabel(opts.YLabel);
legend(opts.Legend, 'Location','NorthEast');

if(strcmp(opts.YScale,'log'))
    subplot(1,3,1:2);
    set(gca, 'YScale', 'log')
    
    subplot(1,3,3);
    set(gca, 'YScale', 'log')
end

linkaxes([ax1, ax2], 'y');
    
end

