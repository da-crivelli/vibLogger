function fig = plot_vc_stats(cf, velo_octave_spec, acq_times_file, varargin)
%PLOT_VC_STATS plots the cumulative % time spent at peak of velocity curves
%   PLOT_VC_STATS(cf, velo_octave_spec) plots VC curves using cf frequency
%   bands and velo_octave_spec octave band velocity values
%
%   fig = PLOT_VC_STATS(...) returns the generated figure object.
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
%   see also: VIBPLOTS, VIBLOGGER, PLOT_VC_CURVES, PLOT_VC_PEAK

% VC levels for VC curves (should not need changing)
vc_curves = [3.12 1.56 0.78 0.39 0.195 0.097 0.048 0.024 0.012];
vc_labels = {'VC-E','VC-F','VC-G','VC-H','VC-I','VC-J','VC-K','VC-L','VC-M'};

p = inputParser;

addParameter(p,'FigureName','Figure',@ischar);
addParameter(p,'Legend',{''});


parse(p,varargin{:});
opts = p.Results;
nr_chans = size(velo_octave_spec,1);

velo_octave_max = max(velo_octave_spec,[],2);
velo_octave_max = squeeze(velo_octave_max)';


fig = figure('name',opts.FigureName);
% compute & plot the empyrical cumulate CDF
vc_level_times = duration();

for c=1:nr_chans
    [f,x] = ecdf(velo_octave_max(:,c));
    f = f.*(acq_times_file(end)-acq_times_file(1));
    semilogx(x,f);
    hold on;
    
    % find ecdf at VC levels
    for l=1:length(vc_curves)
        vc_times_idx = find( x>= vc_curves(l), 1);
        if(isempty(vc_times_idx))
            vc_times = f(end);
        elseif vc_times_idx > 1
            vc_times = f(vc_times_idx-1);
        else
            vc_times = f(vc_times_idx);
        end
        vc_level_times(l,c) = vc_times;
    end
    
end


%%

legend(opts.Legend);

xlabel('1/3 octave peak RMS velocity (um/s)');
ylabel('Time spent at or below level')
title('Velocity peak cumulatives');

hold on;
    
yy = ylim();
for cvc = 1:length(vc_curves)
    semilogy([vc_curves(cvc) vc_curves(cvc)],yy,'--','color',[0.5 0.5 0.5],'HandleVisibility','off');
    t = text(vc_curves(cvc),yy(1)+0.1,vc_labels{cvc});
    %t.BackgroundColor = [1 1 1];
    t.VerticalAlignment = 'bottom';
end

xlim([1e-2, 1e1]);
ylim([0 acq_times_file(end)-acq_times_file(1)]);
grid on;


% store residual
for c=1:nr_chans
    vc_exceedance(c) = acq_times_file(end)-acq_times_file(1) - vc_level_times(1,c);
end


%% VC_LEVEL_TIMES PRINTING CODE.

vc_exc_table = array2table(vc_exceedance, ...
    'VariableNames', opts.Legend, ...
    'RowNames', "> " + vc_labels(1) );

vc_level_table = array2table(vc_level_times, ...
    'VariableNames', opts.Legend, ...
    'RowNames', "<=" + vc_labels);

[vc_exc_table;  vc_level_table]


end
