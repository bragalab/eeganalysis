function ListeningZone_run(SubjectID)
%% add paths
addpath('/projects/b1134/tools/electrode_visualization')
addpath('/projects/b1134/tools/eeganalysis/STIM')

%% find all processed CCEP runs
files = dir(fullfile('/projects/b1134/processed/eegproc', 'BNI', SubjectID, '**', 'STIM*', '**', '**', 'sub*.mat'));

FolderList = cell(height(files),1);
for i = 1:height(files) %convert from structure to cell array of folder names
    FolderList{i} = files(i).folder;
end
FolderList = unique(FolderList); %remove duplicates

% Remove excluded runs
% omitted code due to subject identifiers


RunList = FolderList(cellfun(@(x) contains(x, SubjectID), FolderList));

%% Create List of Data

Results = [];
for i = 1:length(RunList)
    % load run
    runinfo = split(RunList{i},'/');
    ProjectID = runinfo{end-5};
    SubjectID = runinfo{end-4};
    SessionID = runinfo{end-3};
    TaskID = runinfo{end-2};
    StimSite = runinfo{end-1};
    CurrentIntensity = runinfo{end};
    load([RunList{i},'/sub-',SubjectID,'_ses-',SessionID,'_task-',TaskID,'_acq-',StimSite,'-',...
        replace(CurrentIntensity,'_','-'),'_ds_qcx_epoch_trialsx_bpref_z_flip.mat'],...
        'channel_IDs','Z_flip','white_channels')
    
    load([RunList{i},'/sub-',SubjectID,'_ses-',SessionID,'_task-',TaskID,'_acq-',StimSite,'-',...
        replace(CurrentIntensity,'_','-'),'_ds_qcx_epoch_trialsx_bpref_z_flip_avg.mat'],...
        'Z_avg_flip')
    load([RunList{i}, '/bipolar_distances.mat'], 'distances');
    distancetostim = distances;
    clear distances
    
    fid = fopen(sprintf('/projects/b1134/processed/fs/%s/%s/elec_recon/brainmask_coords_0_wlabels.txt', SubjectID, SubjectID));
    fileinfo = textscan(fid, '%s %f %f %f');
    fclose(fid);
    ElectrodeCoordinates = [fileinfo{1,1} num2cell(fileinfo{1,2}) num2cell(fileinfo{1,3}) num2cell(fileinfo{1,4})];

    %exclude contacts near stim, but keep white matter channels
    toremove = false(height(Z_flip),1);
    for j = 1:height(Z_flip)
        channels = split(channel_IDs(j,1), '-');
        if sum(matches(channels, white_channels)) > 1 %exclude WM-WM contacts
            toremove(j) = 1; 
        elseif sum(isnan(Z_avg_flip(j,:))) > 0 %exclude contacts thrown out during QC/preprocessing
            toremove(j) = 1; 
        elseif distancetostim{j,2} <= 20 %exclude contacts near stim
            toremove(j) = 1; 
        end
    end
    Z_flip(toremove,:,:) = [];
    channel_IDs(toremove,:) = [];
    Responses = Z_flip(:,510:1000,:);
    
   
    % calculate correlations and distances for each electrode pair
    Pair_info = cell(height(channel_IDs)^2,4);
    Pair_info(:,1:2) = {' '};
    counter = 1;
    for j = 1:size(Responses,1) %for each channel
        for k = 1:size(Responses,1) %with each other channel    
            %check if its a new unique pair
            if ~sum(matches(Pair_info(:,1),channel_IDs(j,1)) & matches(Pair_info(:,2),channel_IDs(k,1))) > 0 &&...
                   ~sum(matches(Pair_info(:,1),channel_IDs(k,1)) & matches(Pair_info(:,2),channel_IDs(j,1))) > 0 
                %pair identity
                Pair_info(counter,1) = channel_IDs(j,1);
                Pair_info(counter,2) = channel_IDs(k,1);
                
                %calculate distance 
                channels = split(channel_IDs(j,1), '-');
                CenterContact1index = find(strcmp(ElectrodeCoordinates(:,1),channels{1}));
                CenterContact2index = find(strcmp(ElectrodeCoordinates(:,1),channels{2}));
                CenterX = (ElectrodeCoordinates{CenterContact1index,2} + ElectrodeCoordinates{CenterContact2index,2})/2;
                CenterY = (ElectrodeCoordinates{CenterContact1index,3} + ElectrodeCoordinates{CenterContact2index,3})/2;
                CenterZ = (ElectrodeCoordinates{CenterContact1index,4} + ElectrodeCoordinates{CenterContact2index,4})/2;
                channels = split(channel_IDs(k,1), '-');
                Othercontact1_index = matches(ElectrodeCoordinates(:,1), channels{1});
                Othercontact2_index = matches(ElectrodeCoordinates(:,1), channels{2});       
                Otherx = (ElectrodeCoordinates{Othercontact1_index,2} + ElectrodeCoordinates{Othercontact2_index,2})/2;
                Othery = (ElectrodeCoordinates{Othercontact1_index,3} + ElectrodeCoordinates{Othercontact2_index,3})/2;
                Otherz = (ElectrodeCoordinates{Othercontact1_index,4} + ElectrodeCoordinates{Othercontact2_index,4})/2;
                Pair_info{counter,3} = sqrt((Otherx-CenterX)^2 + (Othery-CenterY)^2 + (Otherz-CenterZ)^2);
              
                %calculate correlation
                Correlations = zeros(size(Responses,3),1);
                for l = 1:size(Responses,3)  %for each trial
                    R = corrcoef(Responses(j,:,l),Responses(k,:,l));
                    Correlations(l) = R(1,2);
                end
                Pair_info{counter,4} = abs(mean(Correlations, 'omitnan'));  
                counter = counter + 1;
            end
        end
    end
    Pair_info(cellfun(@isempty,Pair_info(:,3)),:) = [];
    
    % calculate FWHM
    fprintf('Results for %s \n', RunList{i})
    Distances = cell2mat(Pair_info(cell2mat(Pair_info(:,3))<30,3));
    Correlations = cell2mat(Pair_info(cell2mat(Pair_info(:,3))<30,4));
    [modelobj, gof, ~] = fit(Distances, Correlations, fittype('(1-a)^x'), 'StartPoint', 0.1);
    Rsquared = gof.rsquare;
    fprintf('R squared: %1.4f \n', gof.rsquare)
    DecayFactor = coeffvalues(modelobj);
    fprintf('Decay Factor: %1.4f \n', DecayFactor)
    FWHM = 2 * (log10(0.5)/log10(1-DecayFactor));
    fprintf('FWHM: %1.4f \n', FWHM)    



    Results(i).DecayFactor = DecayFactor;
    Results(i).FWHM = FWHM;
    Results(i).Rsquared = Rsquared;
    Results(i).Data = Pair_info;

end
%% save data
save(sprintf('/projects/b1134/processed/eegproc/%s/%s/%s_FWHM_Results_run.mat',...
    ProjectID, SubjectID, SubjectID), 'Results')
end
