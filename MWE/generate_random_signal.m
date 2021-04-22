function [accel_signal, time, disp_ideal] = generate_random_signal(rms_vals, freq_vals, noise_rms, len, fsamp)
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

accel_signal = zeros(1,len);
disp_ideal = zeros(1,len+2);

time = [0:(len+1)] ./ fsamp;

for i=1:length(rms_vals)
    disp_ideal = disp_ideal + rms_vals(i)*sqrt(2).*sin(2*pi*freq_vals(i).*time);
end

disp_ideal = disp_ideal + (2*rand(1,len+2)-1).*noise_rms*sqrt(2);

accel_signal = diff(diff(disp_ideal))./((1/fsamp).^2);


% check FFT of signal...
L = size(accel_signal',1);

% calculate FFT of acceleration
Y = fft(accel_signal');

spec = 2*abs(Y(2:floor(L/2),:)/L);
freq = fsamp*(1:(floor(L/2)-1))/L;

% calculate FFT of acceleration
Y1 = fft(disp_ideal');

disp_spec = 2*abs(Y1(2:floor(L/2),:)/L);
%freq = fsamp*(1:(floor(L/2)-1))/L;


figure();
subplot(2,1,1);
loglog(freq,spec);
ylabel('FFT of accel');
subplot(2,1,2);
loglog(freq,disp_spec);
ylabel('FFT of displacement');

time = time(1:end-2);

end