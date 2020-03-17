clearvars
close all

%load('C:\Users\mca67379\OneDrive - Diamond Light Source Ltd\VibLogger\20200210_R79_FloorToSextupole\20200210_113014.mat');
%run('C:\Users\mca67379\OneDrive - Diamond Light Source Ltd\VibLogger\20200210_R79_FloorToSextupole\config.m');


fsamp = 2000;
t_samp = 10;%s
t = linspace(0,t_samp,t_samp*fsamp);


in = sin(2*pi*110.*t) + sin(2*pi*150.*t)+ sin(2*pi*250.*t);
out = 30*sin(2*pi*110.*t) + 10*sin(2*pi*150.*t)+ sin(2*pi*250.*t);

out = out + 0.2*rand(length(out),1)';

nrwindows = 10;



winlen = length(in)/nrwindows;


[frf, f, coh] = modalfrf(in',out',fsamp,winlen,'Sensor','dis');

%%
figure();
subplot(2,1,1);
plot(t, in);
ylabel('input');
subplot(2,1,2);
plot(t,out);
ylabel('output');


%% replot from Matlab's version

ang = rad2deg(angle(frf));


y_data = {abs(frf), ang, coh};

y_labels = {'Transmissibility ratio', 'Phase (deg)','Coherence'};

figure();
for i=1:3
    subplot(3,1,i);
    if(i==1)
        loglog(f,y_data{i});
    else
        semilogx(f, y_data{i});
    end
    hold on;
    if(i==1); plot([1 1000],[1 1],'--r'); end
    ylabel(y_labels{i});
    xlim([10 1000])
end


%% see how it changes with different window lengths


