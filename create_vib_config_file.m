function create_vib_config_file(filename,settings)
%CREATE_VIB_CONFIG_FILE(filename,settings) creates a .m configuration file for vibration data
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%   See also VIBLOGGER

cfg = fopen(filename,'w');
fprintf(cfg,'%s\n','% Automatically generated config file');
fprintf(cfg,'%% Generated on: %s\n\n',datestr(now,'yyyy/mm/dd HH:MM:ss'));

sensors_string = sprintf('''%s'',',settings.sensorIDs{:});
fprintf(cfg,'sensor_ids = {%s};\n',sensors_string(1:end-1));

channel_string = sprintf('''%s'',',settings.channel_names{:});
fprintf(cfg,'channel_names = {%s};\n',channel_string(1:end-1));

if(isfield(settings,'transmiss_inputs'))
    settings.transmiss_inputs(:)
    fprintf(cfg,'inputs = [%s];\n',strtrim(sprintf('%.0f ',settings.transmiss_inputs(:))));
    fprintf(cfg,'outputs = [%s];\n',strtrim(sprintf('%.0f ',settings.transmiss_outputs(:))));
end

fclose(cfg);


end

