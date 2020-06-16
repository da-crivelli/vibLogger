function [sens] = sensors_db(in)
%SENSORS_DB returns the sensitivity values as a 1xN array for the sensors
% specified
%   cal = SENSORS_DB({'sn1','sn2'}) returns sensitivity values for sensors
%   'sn1' and 'sn2'
%
%   SENSORS_DB('list') prints a list of all available sensors and serial
%   numbers
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%  For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%  see also: VIBANALYZER, VIBPLOTS, VIBLOGGER

    % --- add new sensors to this area ---
    sensors = containers.Map;

    sensors('50887') = struct(  'sens',1.022e-9,...    %in V/nm/s2
                                'make','PCB',...
                                'model','393B31');
    
    sensors('50983') = struct(  'sens', 0.990e-9,...
                                'make', 'PCB',...
                                'model', '393B31');

    sensors('50984') = struct(  'sens', 0.981e-9,...  
                                'make', 'PCB',...
                                'model', '393B31');

    sensors('50985') = struct(  'sens', 0.999e-9,...
                                'make', 'PCB',...
                                'model', '393B31');
                            
    sensors('LW214478_X') = struct(  'sens', 0.0983e-9,...
                                'make', 'PCB',...
                                'model', '356B18');
    sensors('LW214478_Y') = struct(  'sens', 0.1033e-9,...
                                'make', 'PCB',...
                                'model', '356B18');                                                       
    sensors('LW214478_Z') = struct(  'sens', 0.1031e-9,...
                                'make', 'PCB',...
                                'model', '356B18');
                            
    sensors('velo') = struct(  'sens', 1e-9,...
        'make', 'Velocity sensor',...
        'model', 'directly converted in nm/s');
    
    sensors('unity') = struct(  'sens', 1,...
        'make', 'Unity sensor (for tests only)',...
        'model', 'n/a');
                        
    % --- end sensors DB ---

    % if the input is a cell, it's a list of sensors. Prepare and return a
    % list of sensitivities.
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
            otherwise
                error('Error. \nOption ''%s'' not recognised',in);
        end
    end
    
end


