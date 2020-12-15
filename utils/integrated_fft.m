function [integr, freq] = integrated_fft(signal_fft, freq, varargin)
%INTEGRATED_FFT returns the integrated spectrum of the input fft
%   WARNING: only works with evenly spaced frequency bins
%
%   [integrated, frequency] = integrated_fft(input_fft, input_frequency)
%       returns the integrated fft over the whole spectrum, in "original"
%       units (e.g. nm, -> nm). The RMS value is max(integrated). The
%       relative amplitudes are NOT comparable.
%
%   [...] = integrated_fft([...], 'flimit',[f_lower, f_upper] ) limits the
%       integration between f_lower and f_upper. Default: [0 Inf].
%
%   [...] = integrated_fft([...], 'mode', int_mode) lets you switch between
%       different integration modes:
%     - 'amplitude' (default): returns integrated spectrum preserving
%       units. max(integrated) = rms of the input signal. The relative
%       amplitudes are NOT preserved.
%     - 'power': returns integrated power (units^2). 
%       max(integrated) = variance of the input signal. The relative
%       amplitudes are preserved.
%
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%   see also: VIBPLOTS, VIBLOGGER
%

    p = inputParser;

    addParameter(p,'flimit',[0 Inf],@isnumeric);
    addParameter(p,'mode','amplitude',@isstr);

    parse(p,varargin{:});
    opts = p.Results;

    % cut data by frequency (regardless of whether it's asked for, as default works)
    f_range = find(freq>=opts.flimit(1) & freq<=opts.flimit(2));
    freq = freq(f_range);
    
    switch(opts.mode)
        case 'amplitude'
            integr = sqrt(0.5*cumsum(signal_fft(f_range).^2));
        case 'power'
            integr = 0.5*cumsum(signal_fft(f_range).^2);
        otherwise
            error('Mode not recognised. Must be one of ''amplitude'',''power''');
    end

end

