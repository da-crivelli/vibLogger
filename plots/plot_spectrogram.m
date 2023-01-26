function fig = plot_spectrogram(x, y, t, f, psd, varargin)
%PLOT_SPECTROGRAM generates a linked time series and spectrogram plot 
%
%   PLOT_SPECTROGRAM(x, y, t, f, psd): xy (time series), t f psd (time freq and PSD matrix)
%   
%   fig = PLOT_SPECTROGRAM(x, y, t, f, psd) returns the generated figure object.
%
%   PLOT_SPECTROGRAM(x, y, t, f, psd, 'Parameter', 'Value', ...) accepts the
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
addParameter(p,'CLabel','Amplitude (EU)',@ischar);
addParameter(p,'Legend',{''});

parse(p,varargin{:});
opts = p.Results;

fig = figure('name',opts.FigureName);

%% check if psd is a one-liner... if so, stop
if(size(psd,1) < 2)
    warning("Spectrograms cannot be produced with a single file");
    return
end

%% time-RMS plot
ax1 = subplot(3,1,1);
plot(x,y);
legend(opts.Legend, 'EdgeColor','white','Color','white');
ylabel(opts.YLabel);
grid on;

%% spectrogram

ax2 = subplot(3,1,2:3);

% extend the last data point so it can be shown on the image
t(end+1) = x(end);
psd(:,end+1) = psd(:,end);

try
surf(t,f,psd,'EdgeColor','none');
view(0,90);
colormap(flipud(gray))
cbar = colorbar('east');

cbar.Label.String = opts.CLabel;
xlabel('Time');
ylabel('Frequency (Hz)')

ylim([1 max(f)]);

linkaxes([ax1, ax2], 'x');
catch er
    disp('Error in spectrogram. Perhaps data was processed with an older version?')
    disp(er.message);
end