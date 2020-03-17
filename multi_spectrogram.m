function figs = multi_spectrogram(data, fsamp)
%MULTI_SPECTROGRAM(data,fsamp) calculates spectrograms of data in data and plots "nice"
%spectrograms
%   data: NxM N samples, M channels
%   fsamp: sampling frequency

    % these should be configurable...
    spec_window = 500;
    spec_overlap = 400;
    spec_nfft = 400;
    
    figs = [];
    [nr_samples, nr_chans] = size(data);
    time = [1:nr_samples]./fsamp;
    
    for ch=1:nr_chans
        [~,f,t,ps] = spectrogram(data(:,ch),spec_window,spec_overlap,spec_nfft,fsamp,'yaxis'); 
        figs(ch) = figure('name',sprintf('Channel %0.0d', ch));
        subplot(3,1,1);
        plot(time,data(:,ch));
        xlabel('Time [sec]');
        ylabel('Amplitude');
        axis tight
        
        subplot(3,1,2:3)
        imagesc(t,f,10*log10(ps));
        set(gca,'YDir','normal')
        xlabel('Time [sec]');
        ylabel('Frequency [Hz]');
        %c = colorbar;
        %c.Label.String = 'Power/ frequency [dB/Hz]';
        colormap(bone)
        xlabel('Time [s]');
        ylabel('Frequency [Hz]');
    end

end

