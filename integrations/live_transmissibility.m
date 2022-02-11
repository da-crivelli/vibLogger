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
    
    plot_transmissibility(transmiss_freq, transmiss, coher,...
        'FigureVar', trans_fg,...
        'FigureTitle', sprintf('%.0f s', ts(1)) );

end

