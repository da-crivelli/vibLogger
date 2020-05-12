function fig = plot_prob_distribution(y, varargin)
%PLOT_PROB_DISTRIBUTION plots probability distribution histograms and
%probability charts
%
%   PLOT_PROB_DISTRIBUTION(y) plots the probability
%   distribution of Y
%   
%   fig = PLOT_PROB_DISTRIBUTION(...) returns the generated figure object.
%
%   PLOT_PROB_DISTRIBUTION(y, 'Parameter', 'Value', ...) accepts the
%   following optional parameter/value pairs:
%
%       'FigureName': 'figure name'
%       'YLabel': 'Y label'
%       'Legend': {'chan 1', 'chan 2'...} (channel names)
%       'ProbChart': 'none' (default), or any distribution supported by FITDIST
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%	see also: VIBPLOTS, VIBLOGGER

p = inputParser;

addParameter(p,'FigureName','Figure',@ischar);
addParameter(p,'YLabel','Y',@ischar);
addParameter(p,'Legend',{''});
addParameter(p,'ProbChart','none');
addParameter(p,'ProbThreshold',0.99,@(x) (x>=0 & x<1));

parse(p,varargin{:});

% automagically roll Y axis around...
nr_pts = length(y);
[a,b] = size(y);
if(a == nr_pts)
    y = y';
    nr_chans = b;
else
    nr_chans = a;
end

opts = p.Results;

fig = figure('name',opts.FigureName);

if(~(strcmp(opts.ProbChart,'none')))
    subplot(2,nr_chans,1:2:nr_chans*2);
end

%% histograms

fprintf('\n== Stats for %s ==\n',opts.YLabel);
for c=1:nr_chans
    h(c) = histogram(y(c,:),'Normalization','probability','EdgeColor','none');
    hold on;
    
    % find the cumulate probability percent
    cv = find(cumsum(h(c).Values)>opts.ProbThreshold,1);
    prob(c) = h(c).BinEdges(cv);
    fprintf('%0.2f percent prob, %s = %2.2f\n', opts.ProbThreshold*100, opts.Legend{c}, prob(c));
    xl(c,:) = xlim();
end

xlim([0 max(prob)]);
grid on;

xlabel(opts.YLabel);
ylabel('Probability');
legend(opts.Legend,'EdgeColor','white','Color','white')

%% probability charts
if(~(strcmp(opts.ProbChart,'none')))
    
    pdist_x = [min(xl,[],'all'):0.1:max(xl,[],'all')];
    for c=1:nr_chans
        pdist{c} = fitdist(y(c,:)',opts.ProbChart);
        pdist_ev(c,:) = cdf(pdist{c},pdist_x);
    end
 
    for c=1:nr_chans
        subplot(2,nr_chans,2*c);
        probplot(pdist{c}, y(c,:));
        p = gca();
        p.Title.String = replace(p.Title.String,'Probability plot for','');
        p.Title.String = replace(p.Title.String,'distribution','');
        grid on;
        legend({opts.ProbChart,opts.Legend{c}},'Location','SouthEast',...
            'EdgeColor','white','Color','white');
    end
end

end

