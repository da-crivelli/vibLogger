function viblogger_to_epics(data)
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
    rms(data,1)
end

