function [sens] = sensors_db(in, csv_name)
%SENSORS_DB returns the sensitivity values as a 1xN array for the sensors
% specified
%   cal = SENSORS_DB({'sn1','sn2'}) returns sensitivity values for sensors
%   'sn1' and 'sn2'
%
%   SENSORS_DB('list') prints a list of all available sensors and serial
%   numbers
%
%   SENSORS_DB('csv') prints a csv-formatted list of all available sensors and serial
%   numbers
%   SENSORS_DB('csv', 'file.csv') saves a csv-formatted list of all available sensors and serial
%   numbers
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%  For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger
%
%  see also: VIBANALYZER, VIBPLOTS, VIBLOGGER
    arguments
        in
        csv_name string = ""
    end

    sensors = containers.Map;

    % if the input is a cell, it's a list of sensors. Prepare and return a
    % list of sensitivities.

    csv_to_sensors_cell();

    if(iscell(in))
        sens = [];
        for k=in
            sens(end+1) = sensors(k{1}).sens;
        end
    else
    % if the input is a string, it's a command
        switch(in)
            case 'list'
                fprintf('MAKE\tMODEL\tSENSIT.\t\tID\n');
                for k=sensors.keys
                    fprintf('%s\t\t%s\t%.3d\t%s\n',sensors(k{1}).make, ...
                        sensors(k{1}).model,sensors(k{1}).sens,k{1});
                end
            case 'all'
                sens = sensors;
            case 'gui'
                for k=sensors.keys
                    if(isfield(sensors(k{1}),'gui_hide'))
                        if(sensors(k{1}).gui_hide)
                            remove(sensors, k);
                        end
                    end
                end
                sens = sensors;
            case 'csv'
                sensors_cell_to_csv(sensors, csv_name);
            otherwise
                error('Error. \nOption ''%s'' not recognised',in);
        end
    end

end

function sensors_cell_to_csv(sensors, csv_name)
    arguments
        sensors 
        csv_name string = ""
    end

    if(csv_name ~= "")
        fprintf("%s\n",["printing to csv: ", csv_name]);
        f = fopen(csv_name,'w');
    else
        f = 1;
    end

    fprintf(f, 'MAKE,MODEL,ID,SENS(V/nm/s^2),GUI_HIDE,REMOVED_DATE\n');
    for k=sensors.keys
        gui_hide = 0;
        removed_date = 0;
        if(isfield(sensors(k{1}),'gui_hide')); gui_hide = sensors(k{1}).gui_hide; end
        if(isfield(sensors(k{1}),'removed_date')); removed_date = sensors(k{1}).removed_date; end

        fprintf(f, '%s,%s,%s,%e,%i,%i\n',sensors(k{1}).make, ...
            sensors(k{1}).model,k{1},sensors(k{1}).sens,gui_hide,removed_date);
    end

    if(csv_name ~= "")
        fclose(f);
    end

end

function csv_to_sensors_cell(csv_name)
    arguments 
        csv_name string = "db\sensors.csv"
    end


end