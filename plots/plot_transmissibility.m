function fig = plot_transmissibility(freq, transmiss, coher, varargin)
%PLOT_TRANSMISSIBILITY plots transmissibility ratio and coherence.
%   PLOT_TRANSMISSIBILITY(freq, transmiss, coher) plots transmissibility, phase
%   and coherence for the input data, taking the mean along the first
%   dimension (repeats).
%   
%   fig = PLOT_TRANSMISSIBILITY(...) returns the generated figure object.
%
%   PLOT_TRANSMISSIBILITY(..., 'Parameter', 'Value', ...) accepts the
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
addParameter(p,'FigureTitle','',@ischar);
addParameter(p,'CoherenceFilter',1,@isnumeric);
addParameter(p,'FreqRange',[-Inf Inf],@(x) validateattributes(x,{'numeric'},{'size',[1,2]}));

parse(p,varargin{:});
opts = p.Results;

sz = size(transmiss);

trz = mean(abs(reshape(transmiss,[sz(2:end) 1])),1);
cohz = mean(reshape(coher,[sz(2:end) 1]),1);
ang = mean(reshape(rad2deg(unwrap(angle(transmiss),[],3)),[sz(2:end) 1]),1); 

high_coh = cohz >= opts.CoherenceFilter;

f_hi = freq;
f_hi(~high_coh) = NaN;

trz_hi = trz;
trz_hi(~high_coh) = NaN;

ang_hi = ang;
ang_hi(~high_coh) = NaN;

fig = figure('name',opts.FigureName);

ax1 = subplot(3,1,1);
loglog(freq,trz,'Color',[0.65 0.65 0.65], 'DisplayName', opts.FigureTitle);
hold on;
loglog(f_hi,trz_hi,'Color','black', 'DisplayName', opts.FigureTitle);
ylabel('Transmissibility ratio')
grid on;
axis tight;

title(opts.FigureTitle);

ax2 = subplot(3,1,2);
semilogx(freq, ang,'Color',[0.65 0.65 0.65], 'DisplayName', opts.FigureTitle);
hold on;
semilogx(f_hi,ang_hi,'Color','black', 'DisplayName', opts.FigureTitle);
ylabel('Phase (deg)');
grid on;
axis tight;

ax3 = subplot(3,1,3);
semilogx(freq,cohz,'Color','black', 'DisplayName', opts.FigureTitle);
hold on;
ylabel('Coherence');
grid on;
axis tight;

xl = xlim();
semilogx(xl,[opts.CoherenceFilter,opts.CoherenceFilter],'--k');
xlabel('Frequency (Hz)');

linkaxes([ax1, ax2, ax3], 'x');
xlim(ax1,opts.FreqRange);

end