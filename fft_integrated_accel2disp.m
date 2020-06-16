function [integr, freq, spec_disp, rms_disp] = fft_integrated_accel2disp(data, fsamp, mode, direction)
%FFT_INTEGRATED_ACCEL2DISP converts acceleration input data into displacement FFT
%   [integr, freq, spec, rms_disp] = FFT_INTEGRATED_ACCEL2DISP(accel_data) returns the integrated
%   displacement fft from acceleration data, for each channel.
%       integr: integrated displacement
%       freq:   vector of frequencies
%       spec:   FFT spectrum of displacement
%       rms_disp: RMS of displacement calculated from integrating the FFT
%               of the displacement
%
%   [integr, freq, spec] = FFT_INTEGRATED_ACCEL2DISP(accel_data, fsamp) specifies the
%   sampling frequency (assumes 1 otherwise)
%
%   [integr, freq, spec] = FFT_INTEGRATED_ACCEL2DISP(accel_data, fsamp, 'velocity') specifies the
%   sampling frequency (assumes 1 otherwise)
%
%   Note: this function is useful when 1/f noise is a concern. With ideal
%   test signals it reaches a ~4dB improvement at low frequency.
%
%   Also note: the displacement DC component is removed as it can't be directly
%   calculated by dividing the FFT by 0.
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   v0.1 20200206 - initial release
%

    if(~exist('direction','var'))
        direction = 'forward';
    end
    
    L = size(data,1);
    %data = data - mean(data);

    % calculate FFT of acceleration
    Y = fft(data);
   
    spec = 2*abs(Y(2:floor(L/2),:)/L);
    freq = fsamp*(1:(floor(L/2)-1))/L;

    % convert acceleration to displacement (or velocity to displacement)
    if(exist('mode','var'))
        if(mode == 'velocity')
            spec_disp = spec' ./ (2*pi.*freq);
        else
            error('Mode not recognised');
        end
    else
        spec_disp = spec' ./ ((2*pi.*freq).^2);
    end
    
    % integrate the displacement
    integr = sqrt( cumsum( 0.5 .* ( spec_disp ).^2 ,2,direction) );
 
    % RMS is the total sum of integrated displacement (or, end point)
    rms_disp = integr(:,end);
    
end
