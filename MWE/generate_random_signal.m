function [signal, time, disp_ideal] = generate_random_signal(rms_vals, freq_vals, noise_rms, len, fsamp)
%GENERATE_RANDOM_SIGNAL generates a random signal for vibLogger testing
%
%  [signal, time] = generate_random_signal(rms_vals, freq_vals, noise_rms len, fsamp) 
%           generates a random signal of length len with [rms1, rms2...] RMS values
%           at [freq1, freq2...] frequencies, evaluated at sample frequency
%           fsamp, for DISPLACEMENT (before double integration).
%           It also superimposes a noise_rms white noise signal.
%
%
%  Davide Crivelli
%  davide.crivelli@diamond.ac.uk
%
%  For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%  see also: VIBANALYZER, VIBPLOTS, SENSORS_DB

signal = zeros(1,len);
disp_ideal = zeros(1,len);

time = [0:(len-1)] ./ fsamp;

for i=1:length(rms_vals)
    signal = signal + (rms_vals(i)*sqrt(2))*((2*pi*freq_vals(i))^2).*sin(2*pi*freq_vals(i).*time);
    disp_ideal = disp_ideal + sqrt(2)*rms_vals(i)*sin(2*pi*freq_vals(i).*time);
end

signal = signal + (2*rand(1,len)-1).*noise_rms*sqrt(2);


% check FFT of signal...
L = size(signal',1);

% calculate FFT of acceleration
Y = fft(signal');

spec = 2*abs(Y(2:floor(L/2),:)/L);
freq = fsamp*(1:(floor(L/2)-1))/L;

% calculate FFT of acceleration
Y1 = fft(disp_ideal');

disp_spec = 2*abs(Y(2:floor(L/2),:)/L);
freq = fsamp*(1:(floor(L/2)-1))/L;


figure();
subplot(2,1,1);
loglog(freq,spec' ./ ((2*pi*freq).^2));
subplot(2,1,2);
loglog(freq,disp_spec);

end