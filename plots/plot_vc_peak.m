function fig = plot_vc_peak(cf, velo_octave_spec, acq_times_file, varargin)
%PLOT_VC_CURVES plots the peak of velocity curves using BS ISO 266-1997 third octave bands.
%   PLOT_VC_PEAK(cf, velo_octave_spec) plots VC curves using cf frequency
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
%   see also: VIBPLOTS, VIBLOGGER, PLOT_VC_CURVES

% VC levels for VC curves (should not need changing)
vc_curves = [3.12 1.56 0.78 0.39 0.195 0.097 0.048 0.024 0.012];
vc_labels = {'VC-E','VC-F','VC-G','VC-H','VC-I','VC-J','VC-K','VC-L','VC-M'};

p = inputParser;

addParameter(p,'FigureName','Figure',@ischar);
addParameter(p,'YLabel','Y',@ischar);
addParameter(p,'Legend',{''});
addParameter(p,'FigureHandle',[]);


parse(p,varargin{:});
opts = p.Results;
nr_chans = size(velo_octave_spec,1);

velo_octave_max = max(velo_octave_spec,[],2);
velo_octave_max = squeeze(velo_octave_max)';

if(isempty(opts.FigureHandle))
    fig = figure('name',opts.FigureName);
else
    fig = figure(opts.FigureHandle);
end

line_colors = colororder();

% fix if time is shorter than velo_octave max
trim = min(size(velo_octave_max,1),length(acq_times_file));

l = semilogy(acq_times_file(1:trim),velo_octave_max(1:trim,:));
for i=1:length(l)
    set(l(i), 'color', line_colors(mod(i-1,7)+1,:));
end
legend(opts.Legend);

ylabel(opts.YLabel);
title('Velocity peaks');

hold on;
    
xx = xlim();


for cvc = 1:length(vc_curves)
    semilogy(xx,[vc_curves(cvc) vc_curves(cvc)],'--','color',[0.5 0.5 0.5],'HandleVisibility','off');
    if(isempty(opts.FigureHandle))
        t = text(xx(1)+0.1,vc_curves(cvc),vc_labels{cvc});
        %t.BackgroundColor = [1 1 1];
        t.VerticalAlignment = 'bottom';
    end
end



grid on;




end
