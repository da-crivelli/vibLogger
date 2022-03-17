function live_transmissibility(ts, data, settings)
%LIVE_TRANSMISSIBILITY Summary of this function goes here
%   Detailed explanation goes here
    sens = sensors_db(settings.sensorIDs);
    data = (data-mean(data)) ./ sens;
    
	[transmiss,transmiss_freq,coher] = transmissibility(settings,data);
    
    global trans_fg
    
    if(~any(isgraphics(trans_fg)))
        trans_fg = figure();
    else
        figure(trans_fg);
    end
    
    for i=1:length(settings.inputs)
    	ChannelLegend{i} = sprintf("%s \\rightarrow %s", ...
            settings.channel_names{settings.inputs(i)},...
            settings.channel_names{settings.outputs(i)}...
            );
    end

    
    plot_transmissibility(transmiss_freq, transmiss, coher,...
        'FigureVar', trans_fg, ...
        'FigureTitle', sprintf('%.0f s', ts(1)), ...
        'ChannelLegend', ChannelLegend);

end

