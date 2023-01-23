% test script for vibAnalyzer
clearvars
close all

% find where we are... if running from command line or from the file itself
viblogger_dir = fileparts(pwd())

addpath(viblogger_dir);
addpath([viblogger_dir,'/plots']);


test_dir = strcat(viblogger_dir, filesep,'tests');

processed_file = [test_dir, filesep,'_processed/processed.mat'];

test_threshold = 0.02;


cprintf_green = '*[0,0.5,0.07]';
cprintf_red = '*[0.7,0.04,0]';
cprintf_yellow = '*[0.82,0.49,0.15]';




%% loading and prepping
test_data = load(processed_file);
run([test_dir,filesep,'test_data_config.m']);

cprintf('text','\n\nRunning tests on viblogger output files...\n');
cprintf('text','Threshold set to %d%% \n\n',test_threshold*100);

%% theoretical RMS values
% RMS of displacement is stored in rms_disp (nchans x duration / nrchunks)

% there will be some tolerance but the median should be quite close to the
% ideal value
% for a single tone: let acceleration = A*cos(2*pi*f0) 
% displacement = s * A/((2*pi*f0)^2)*cos(2*pi*f0) = s*A_d * cos(...)
% RMS = sqrt(2)/2 A_d 
% s = sensor sensitivity in V/m/s2

rms_calc = zeros(size(tone_freqs));
rms_accel_calc = zeros(size(tone_freqs));
sens = sensors_db(test_data.sensor_ids);


for ch=1:size(tone_freqs,1)
    for f=1:size(tone_freqs,2)
        for fa=[tone_freqs(ch,f); tone_amps(ch,f)]
            rms_calc(ch,f) = rms_calc(ch,f) + (sqrt(2)/2)*sens(ch).*fa(2)/((2*pi*fa(1))^2);
            rms_accel_calc(ch,f) = rms_calc(ch,f) + (sqrt(2)/2)*sens(ch).*fa(2);
        end
    end
end

integrated_disp_calc = sqrt(cumsum(rms_calc.^2,2));
rms_disp_calc = integrated_disp_calc(:,end);
rms_accel_calc = rms_accel_calc.^2;

%% RMS over time

% test for rms_calc to be within test_threshold% of the median of each signal
rms_test = median(test_data.rms_disp,2);

cprintf('text','1. rms displacement ... \t');
assert_between(rms_test,rms_disp_calc,test_threshold);


%% integrated displacement
integrated_disp_test = mean(test_data.integr_disp,3);

% find test_data cusum at just above test frequencies
cs_vals = zeros(size(tone_freqs));
for ch=1:size(tone_freqs,1)
    for ff=1:size(tone_freqs,2)
        fq=find(test_data.ff >=tone_freqs(ch,ff)*1.1,1);
        cs_vals(ch,ff) = integrated_disp_test(ch,fq);
    end
end


cprintf('text','2. integrated motion ... \t');
assert_between(cs_vals, integrated_disp_calc, test_threshold)


%% p2p of displacement
cprintf('text','3. peak to peak motion ... \t')
cprintf(cprintf_yellow,'NOT TESTED\n');

%% PSD of acceleration (psd_vib)

% find the position of peaks (expecting a number consistent to the
% generator)
psd_accel = mean(test_data.psd_vib,3);

[peak_int_accel, peak_freqs, peak_vals] = findpeaks_integrate(tone_freqs, psd_accel, test_data.freq);

cprintf('text','4.1 PSD of accel - val ... \t')
assert_between(peak_int_accel, rms_accel_calc, test_threshold);
cprintf('text','4.2 PSD of accel - freq ...\t')
assert_between(peak_freqs, tone_freqs, test_threshold);


%% PSD of displacement (psd_vib_disp)

psd_disp = mean(test_data.psd_vib_disp, 3);
[peak_int_disp, peak_freq_disp, peak_vals_disp] = findpeaks_integrate(tone_freqs, psd_disp, test_data.freq);


cprintf('text','5.1 PSD of disp - val ... \t')
assert_between(peak_int_disp, rms_calc.^2, test_threshold);
cprintf('text','5.2 PSD of disp - freq ...\t')
assert_between(peak_freq_disp, tone_freqs, test_threshold);

%% VC curves (velo_octave_spec)
cprintf('text','6. VC curves ... ... ... \t')

vc_avg = mean(test_data.velo_octave_spec,3);


% this needs to be the RMS velocity, amplitude/sqrt(2)
% ... and it needs to be in um/s
rms_velo_spec_ideal = zeros([size(tone_freqs,1),size(test_data.cf,1)]);
for ch=1:size(tone_freqs,1)
    for ff=1:size(tone_freqs,2)
        rms_velo_ideal(ch,ff) = tone_amps(ch,ff)./(2*pi.*tone_freqs(ch,ff))./sqrt(2)/1e3;
    end
    [counts,idx] = histc(tone_freqs(ch,:),test_data.cf);
    rms_velo_spec_ideal(ch,:) = accumarray(idx, rms_velo_ideal(ch,:), [size(test_data.cf,1),1]);
end

figure();
loglog(test_data.cf,vc_avg');
hold on;
loglog(test_data.cf,rms_velo_spec_ideal,'ok');


cprintf(cprintf_yellow,'NOT TESTED -- CHECK PLOT\n');




%% Transmissibility
cprintf('text','7. Transmissibility ... \t')

plot_transmissibility(test_data.transmiss_freq, test_data.transmiss, test_data.coher);

sz = size(test_data.transmiss);
trz = mean(abs(reshape(test_data.transmiss,[sz(2:end) 1])),1);
cohz = mean(reshape(test_data.coher,[sz(2:end) 1]),1);
ang = mean(reshape(rad2deg(unwrap(angle(test_data.transmiss),[],3)),[sz(2:end) 1]),1); 


for ch=1:size(tone_freqs,1)
    for fq=1:size(tone_freqs,2)
        tx_meas(ch,fq) = trz(1,find(test_data.transmiss_freq == tone_freqs(fq),1));
        tx_ang(ch,fq) = ang(1,find(test_data.transmiss_freq == tone_freqs(fq),1));
    end
end


cprintf(cprintf_yellow,'NOT TESTED\n');




%% run a bunch of plots

%% function def
function assert_between(data, theor_data, tolerance)
% checks that data is between theor_data*1-tolerance and theor_data and
% 1+tolerance
    cprintf_green = '*[0,0.5,0.07]';
    cprintf_red = '*[0.5,0.07,0]';
    cprintf_yellow = '*[0.82,0.49,0.15]';

    try
        assert(all((theor_data.*(1-tolerance) < data) & ...
            (theor_data.*(1+tolerance) > data),'all'));
        cprintf(cprintf_green,['PASS ','\xD83D\xDE0E','\n']);
    catch e
        cprintf(cprintf_red,'FAIL \xD83D\xDCA9 \n');
        cprintf('text','theoretical / actual:')
        theor_data./data
    end
end


function [peak_int, peak_freqs, peak_vals] = findpeaks_integrate(tone_freqs, psd_in, freq_in)
    peak_vals = zeros(size(tone_freqs));
    peak_freqs = peak_vals;
    for ch=1:size(tone_freqs,1)
        [peak_vals(ch,:),peak_locs] = findpeaks(psd_in(ch,:),'SortStr','descend','NPeaks',size(tone_freqs,2),'MinPeakWidth',1);
        [pl,pid] = sort(peak_locs);
        peak_freqs(ch,:) = freq_in(pl);
        peak_vals(ch,:) = peak_vals(ch,pid);
    
        f_res = freq_in(2)-freq_in(1);
        % integrate around the peaks
        for pk=1:length(pl)
            peak_int(ch,pk) = sum(psd_in(ch,pl(pk)-5:pl(pk)+5).*f_res);
        end
    end
end