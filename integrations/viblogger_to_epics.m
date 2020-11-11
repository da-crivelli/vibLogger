function viblogger_to_epics(data, settings)
%VIBLOGGER_TO_EPICS processes data and writes it as a PV into EPICS
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger
%
%   see also VIBLOGGER, VIBANALYZER, SENSORS_DB

    % calculate FFT in velo and disp
    % write EPICS PVs

    sens = sensors_db(settings.sensorIDs);
    data = (data-mean(data)) ./ sens;
    [~, ~, ~,rms_disp] = fft_integrated_accel2disp(data, settings.fsamp, settings.highpass);
    [~, ~, ~, rms_velo] = fft_integrated_accel2disp(data, settings.fsamp, settings.highpass, 'velocity');
    velo = velo2disp(data,1/settings.fsamp);
    [p,cf] = poctave(velo./1e03,settings.fsamp,settings.octave_opts{:});
   
    
end

