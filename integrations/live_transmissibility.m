function live_transmissibility(ts, data, settings)
%LIVE_TRANSMISSIBILITY Summary of this function goes here
%   Detailed explanation goes here
    sens = sensors_db(settings.sensorIDs);
    data = (data-mean(data)) ./ sens;
    
	[transmiss,transmiss_freq,coher] = transmissibility(settings,data);
    
    global trans_fg
    
    if(~isgraphics(trans_fg))
        trans_fg = figure();
    else
        figure(trans_fg);
    end
    
    
    plot_transmissibility(transmiss_freq, transmiss, coher,...
        'FigureVar', trans_fg);
    
    %trz = abs(transmiss);
    %ang = rad2deg(unwrap(angle(transmiss))); 
    
    %loglog(transmiss_freq,trz);
    
    disp('1');
end

