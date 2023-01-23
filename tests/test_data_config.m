% sinewave frequencies and amplitudes

nr_files = 2;

% each row is a different channel
tone_freqs = [5 42 60; 5 50 70].*sqrt(2); % in Hz
tone_amps = [1 0.5 1; 0.5 0.2 0.1].*pi; % in V
tone_phase = [0 0 0; 90 0 0]; % in degrees

% try a signal which should give a certain displacement amplitude
%tone_freqs = [5; 15]; % in Hz
%tone_amps = [100; 40000].*(4*pi^2); % in V  ; should give 4 & 4
%tone_phase = [0; 0]; % in degrees

% simpler signal
tone_freqs = [45; 45]; % in Hz
tone_amps =  [1; 2]; % in V ->1nm/s
tone_phase = [0; 90]; % in degrees


noise_amp = 0.00;

fsamp = 2048; %in Hz
tone_length = 60;   % in s