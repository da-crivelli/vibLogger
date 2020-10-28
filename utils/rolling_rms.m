function y = rolling_rms(signal, winlen, winoverlap)
%ROLLING_RMS(signal, winlen, winoverlap) calculates the rolling RMS of the
%input signal.
%
%   y = ROLLING_RMS(signal, winlen, winoverlap) calculates the rolling RMS
%   value of signal over a rectangular window of winlen samples using a
%   winoverlap fraction (0-1) window overlap. Assumes signal size is Nx1.
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger
%
%  see also: VIBLOGGER

N = length(signal);

winoverlap_samples = floor(winlen*winoverlap);
winoffset = winlen - winoverlap_samples;

nrwindows = floor(N / (winlen*(1-winoverlap)))-1;
y = zeros(nrwindows,1);

for i=0:(nrwindows-1)
    window_idxs = ( (i*winoffset)+1 ) : ( (i*winoffset)+winlen );
    y(i+1) = rms(signal(window_idxs));
end

end
