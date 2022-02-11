function [transmiss,transmiss_freq,coher] = transmissibility(settings,data)

%TRANSMISSIBILITY Summary of this function goes here
%   Detailed explanation goes here

    transmiss = [];
    transmiss_freq = [];
    coher = [];
    
    if(isfield(settings,'transmiss_inputs'))
        inputs = settings.transmiss_inputs;
        outputs = settings.transmiss_outputs;
    end
    
    if(isfield(settings,'winoverlap'))
        transm_overlap = settings.winoverlap;
    else
        transm_overlap = 0.5;
    end
    
    if(exist('inputs','var'))
        winlen = length(data(:,inputs(1)))/settings.nrwindows;
        winoverlap = floor(winlen*transm_overlap);
        for iii=1:length(inputs)
            [transmiss_i, transmiss_freq, transmiss_coh] = ...
                modalfrf(data(:,inputs(iii)),data(:,outputs(iii)),settings.fsamp,winlen,winoverlap,'Sensor','dis');
            transmiss(iii,:) = transmiss_i;
            coher(iii,:) = transmiss_coh;
        end
    end

end

