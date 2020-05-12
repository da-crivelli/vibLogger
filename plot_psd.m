function fig = plot_psd(f, psd, varargin)
%   PLOT_PSD(frequency, psd) plots the PSD as passed in the input
%   
%   fig = PLOT_PSD(frequency, psd) returns the generated figure object.
%
%   PLOT_TIMESERIES_HIST(frequency, psd, 'Parameter', 'Value', ...) accepts the
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
addParameter(p,'Legend',{''});

parse(p,varargin{:});
opts = p.Results;

fig = figure('name',opts.FigureName);
loglog(f,psd);
grid on;

legend(opts.Legend,'EdgeColor','white','Color','white');
xlabel('Frequency (Hz)');
ylabel(opts.YLabel);


end