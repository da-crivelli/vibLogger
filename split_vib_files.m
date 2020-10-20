%   SPLIT_VIB_FILES(directory, nrsplit) splits vibration files for more granular
%   analysis
%
%   directory: the path where all vibration files are stored
%   nrsplit: number of files to split each file into
%
%   Davide Crivelli
%   davide.crivelli@diamond.ac.uk
%
%   For details and usage see https://gitlab.diamond.ac.uk/mca67379/viblogger 
%
%   see also VIBLOGGER, VIBANALYZER, SENSORS_DB

function split_vib_files(directory, nrsplit)
    files_list = dir(strcat(directory,filesep,'*.mat'));
    mkdir(strcat(directory,filesep,'split'));
    copyfile(strcat(directory,filesep,'config.m'),strcat(directory,filesep,'split',filesep,'config.m'));
    
    for f=1:length(files_list)
        
        data_old = load(strcat(directory,filesep,files_list(f).name));
        if(f==1)
            acq_start = data_old.acq_date;
        end
        
        % check if the file is actually splittable...
        nrsamp = size(data_old.data,1)/nrsplit;
        
        if(mod(nrsamp,1) ~= 0)
            error(sprintf('Number of samples is not divisible by %d',nrsplit));
        end
        fprintf('. load data %s\n',strcat(directory,filesep,files_list(f).name));    
        for n=0:(nrsplit-1)
            samp_slice = [(n*nrsamp+1):(n+1)*nrsamp];
            time = data_old.time(samp_slice,1)-data_old.time(samp_slice(1),1);
            data = data_old.data(samp_slice,:);
            settings = data_old.settings;
            acq_date = acq_start + seconds(data_old.time(samp_slice(1),1));
            fsamp = data_old.fsamp;
            recording_time = data_old.recording_time / nrsplit;
            
            save_filename = strcat(directory, filesep, 'split', ...
                filesep, datestr(acq_date,'yyyymmdd_HHMMss'),'.mat');
            
            save(save_filename,'data','time','settings','acq_date','fsamp','recording_time');
            fprintf(' ... saved data %s\n',save_filename);     
        end
        
    end
    
    
end