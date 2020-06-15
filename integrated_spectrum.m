function [integr, freq, spec] = integrated_spectrum(data, fsamp)
%INTEGRATED SPECTRUM calculates the... integrated spectrum... of the input
%data... sorry
%
%   [integr, freq, spec] = INTEGRATED_SPECTRUM(data, fsamp)
%   
%       integr: integrated spectrum, 
%       freq: frequency bins
%       spec: one-sided Fourier power spectrum
%


%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   v0.1 20191029 - initial release
%   

    L = size(data,1);
    Y = fft(data)/L;
    
    spec = 2*abs(Y(2:floor(L/2),:));
    freq = fsamp*(1:(floor(L/2)-1))/L;

    integr = sqrt(cumsum(0.5*spec.^2));

end

