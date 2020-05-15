function [integr, freq, spec_disp, rms_disp] = fft_integrated_accel2disp(data, fsamp, mode)
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

    L = size(data,1);
    data = data - mean(data);
    
    Y = fft(data);
    
    spec = 2*abs(Y(1:floor(L/2),:)/L);
    freq = fsamp*(0:(floor(L/2)-1))/L;

    if(exist('mode','var'))
        if(mode == 'velocity')
            spec_disp = spec' ./ (2*pi.*freq);
        else
            error('Mode not recognised');
        end
    else
        spec_disp = spec' ./ ((2*pi.*freq).^2);
    end
    
    spec_disp(:,1:2) = 0;
    %integr = sqrt((cumsum(spec_disp,2).^2));
    integr = cumsum(spec_disp,2);
    
     
    
	rms_disp = sqrt(sum((sqrt(2)/2*spec_disp').^2)); 
    
end

