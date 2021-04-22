function [rms_fft, all_fft, freq] = fast_rms(data, fsamp, nr_integr);
%FAST_RMS uses FFT to calculate the RMS of a signal
%   [rms_accel_fft, accel_fft, f] = fast_rms(accel, fsamp);
%       returns the RMS of the acceleration input signal sampled at fsamp
%   
%   [...] = fast_rms(accel, fsamp, 2) integrates twice to obtain
%       displacement and returns the RMS and FFT of the displacement signal
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%   see also: VIBPLOTS, VIBLOGGER
%

if(~exist('nr_integr','var')); nr_integr = 0; end;

% calculate the FFT so that I^2_RMS=I^2_0+∑1/2 I^2_i

nsamp = size(data,1);
all_fft = abs(fft(data,[],1))./nsamp;
all_fft = all_fft(1:floor(nsamp/2)+1,:);

% remove DC offset
all_fft = 2*all_fft(2:end,:);

freq = fsamp*(1:floor(nsamp/2))/nsamp;
freq = freq';

% integration
all_fft = all_fft./((2*pi.*freq).^(nr_integr));

%RMS from FFT
rms_fft = sqrt(sum(0.5*(all_fft.^2)));


end

