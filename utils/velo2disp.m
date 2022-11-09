function disp_data = velo2disp(velo_data, delta_t, varargin)
%VELO2DISP converts velocity input data into displacement
%   disp_data = VELO2DISP(velo_data) returns the integrated
%   displacement from velocity data, for each channel.
%
%   disp_data = VELO2DISP(velo_data, delta_t) specifies the
%   time step delta_t (assumes 1 otherwise)
%
%   disp_data = VELO2DISP(velo_data,'plot') plots all
%   channels for checking. Use carefully when dealing with lots of data...
%
%   The function assumes that vibration is around zero (no drift) and uses
%   trapz to integrate so be aware of error propagation / noise.
%

%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   v0.1 20191029 - initial release
%

    % setting up the input parser
    p = inputParser;
    validString = @(x) ischar(x);
    validNum = @(x) isnumeric(x);
    
    addOptional(p,'delta_t',1,validNum);
    addOptional(p,'plot',false,validString);
    
    parse(p,delta_t,varargin{:});
    params = p.Results;
    
    % take DCout of the velocity data
    velo_data = velo_data - mean(velo_data,'omitnan');
    
    % integration happens here
    nr_channels = size(velo_data,2);
    nr_samples = size(velo_data,1);
    t = (1:nr_samples).*params.delta_t;
    disp_data = cumtrapz(t,velo_data);
    
    % take DC out of displacement data
    disp_data = disp_data - mean(disp_data);
    %disp_data = disp_data - mean(disp_data);
    
    % plots data if requested
    if(params.plot)
        figure('name','velo2disp checker plot')
        for ch=1:(nr_channels)
            % velocity subplot
            subplot(nr_channels,2,1+(ch-1)*2);
            plot(t,velo_data(:,ch));
            
            %displacement subplot
            subplot(nr_channels,2,ch*2);
            plot(t,disp_data(:,ch));
        end
        
        % setting up plots & labels
        subplot(nr_channels,2,1);
        title('Velocity')
        subplot(nr_channels,2,2);
        title('Displacement')
    end

end

