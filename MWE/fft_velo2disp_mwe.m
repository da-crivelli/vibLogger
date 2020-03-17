% minimum working example and tests for fft_velo2disp

clearvars
close all

addpath('C:\Users\mca67379\OneDrive - Diamond Light Source Ltd\Matlab');

fsamp = 10000;

%amps = [0.05];
%freqs = [10 3 12 0.8 0.2];

amps = [1000 1000 1000];
freqs = [10 20 50];



noise = 0.0;

time = (0:1/fsamp:2);

%lowpass_f = 10;

%% generating the acceleration signal
accel_signal = zeros(size(time));

for i = 1:length(freqs)
    accel_signal = accel_signal + amps(i).*sin(2*pi*freqs(i).*time);
end

accel_signal = accel_signal + noise.*rand(size(time));
%accel_signal = lowpass(accel_signal,lowpass_f,fsamp);


%% generating the ideal displacement signal (no noise) & fft / integration
disp_signal_ideal = zeros(size(time));

for i = 1:length(freqs)
    disp_signal_ideal = disp_signal_ideal + (amps(i))/(4*pi^2*(freqs(i))^2).*sin(2*pi*freqs(i).*time + pi);
end

[integr_disp_ideal, freq_disp_ideal, spec_disp_ideal] = integrated_spectrum(disp_signal_ideal', fsamp);

%% calculated FFT and integrated FFT from acceleration signal
[integr_accel, freq_integr, spec_accel] = integrated_spectrum(accel_signal', fsamp);


%integrating twice acceleration to get displacement
velo_integr = velo2disp(accel_signal, 1/fsamp);
disp_integr = velo2disp(velo_integr, 1/fsamp);

% calculate spectrum from accel data
[integr_disp_integr, freq_disp_integr, spec_disp_integr] = integrated_spectrum(disp_integr', fsamp);

% direct calculation of displacement spectrum from time accel data
[integr_disp_fft, integr_disp_freq, integr_disp_fft_spec, rms_disp] = fft_integrated_accel2disp(accel_signal', fsamp);

%% plots
figure();
subplot(2,3,1);
plot(time, accel_signal);
xlabel('time (s)');
ylabel('Acceleration (m/s2)');


subplot(2,3,2);
loglog(freq_integr,spec_accel);
xlabel('Freq. (Hz)');
ylabel('Accel/freq');


subplot(2,3,3);
semilogx(freq_integr,integr_accel);
xlabel('Freq. (Hz)');
ylabel('Integrated accel. (m/s2)');


%% displacement plots
subplot(2,3,4);
plot(time, disp_signal_ideal, '-r');
hold on;
plot(time, disp_integr, '--b');

xlabel('time (s)');
ylabel('Displacement (m)');
legend({'Ideal','time domain integration'});


subplot(2,3,5);
loglog(freq_disp_ideal, spec_disp_ideal, '-r');
hold on;
loglog(freq_disp_integr, spec_disp_integr, '--b');
loglog(integr_disp_freq, integr_disp_fft_spec, '--k');

xlabel('Freq. (Hz)');
ylabel('Displacement/freq');
legend({'Ideal','time domain integration','FFT "integration"'});

subplot(2,3,6);
semilogx(freq_disp_ideal, integr_disp_ideal, '-r');
hold on;
semilogx(freq_disp_integr, integr_disp_integr, '--b');
semilogx(integr_disp_freq, integr_disp_fft, '--k');

xlabel('Freq. (Hz)');
ylabel('Integrated displacement (m)');
legend({'Ideal','time domain integration','FFT "integration"'});



%% RMS values
fprintf('%d \t IDEAL RMS\n',rms(disp_signal_ideal));
fprintf('%d \t RMS FROM NUM. INTEGR\n',rms(disp_integr));
fprintf('%d \t RMS FROM FFT\n\n',rms_disp);

fprintf('%d \t IDEAL P2P\n',peak2peak(disp_signal_ideal));
fprintf('%d \t P2P FROM NUM. INTEGR\n',peak2peak(disp_integr));
fprintf('%d \t P2P FROM FFT\n',2*max(integr_disp_fft));


%% third octave spectrum

octave_band = [3 200];
bpo = 3;
opts = {'FrequencyLimits',octave_band,'BandsPerOctave',bpo};

[p,cf] = poctave(accel_signal,fsamp,opts{:});

figure();
semilogy(cf,p);