function live_transmissibility(data,settings)
%LIVE_TRANSMISSIBILITY Summary of this function goes here
%   Detailed explanation goes here
    sens = sensors_db(settings.sensorIDs);
    data = (data-mean(data)) ./ sens;
    
	transmiss,transmiss_freq,coher = transmissibility(settings,data);
    
    figure(transmiss_fg)
    %transmiss_fg = plot_transmissibility(
   
    
end

