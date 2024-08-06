function ResponseMetrics = CCEP_responsemetrics(datapath)
fprintf('Calculating Response Metrics for %s. \n', datapath)
%% load data
Folderinfo = split(datapath,'/');
SubjectID = Folderinfo{end-4};
SessionID = Folderinfo{end-3};
TaskID = Folderinfo{end-2};
StimSite = Folderinfo{end-1};
CurrentIntensity = Folderinfo{end};
stim_file = [datapath,'/sub-',SubjectID,'_ses-',SessionID,...
    '_task-',TaskID,'_acq-',StimSite,'-',...
    replace(CurrentIntensity,'_','-'),'_ds_qcx_epoch_trialsx_bpref_z_flip_avg.mat'];
load(stim_file, 'Z_avg_flip', 'channel_IDs','white_channels');
stim_data = Z_avg_flip;
clear Z_avg_flip
load([datapath, '/bipolar_distances.mat'], 'distances')

%exclude some channels
bad_indices = false(height(channel_IDs),1);
for i = 1:height(stim_data)
    channels = split(channel_IDs(i,1), '-');
    if sum(matches(channels, white_channels)) > 1 %exclude WM-WM contacts
        bad_indices(i) = true; 
    elseif sum(matches(channels, split(StimSite,'-'))) > 0 %exclude stim site contacts 
        bad_indices(i) = true;      
    elseif sum(~isnan(stim_data(i,:)) == 0) %excluded during QC/preproc
        bad_indices(i) = true;
   %elseif  distances{matches(distances(:,1),channel_IDs(i,1)),2} <= 20
   %     bad_indices(i) = true;  
    end
end  
channel_IDs(bad_indices,:) = [];
stim_data(bad_indices,:) = [];

%% load network info
% omitted due to subject identifiers

%load ranked network memberships for each electrode
% omitted due to subject identifiers

%load BOLD RSFC for each electrode
load(sprintf('%s/corr_mat_elecROI.mat',RSFC_path), 'corr_mat','bipolar_Lnames')

%% find peak amplitude and latency
window = -500:1499;
Magnitude = NaN(size(stim_data,1),1);%channel
Latency = NaN(size(stim_data,1),1);%channel
max_window = 10:400;
warning('off','all')
for channel = 1:size(stim_data,1) %for each channel
    %for trial = 1:size(stim_data,3) % for each trial
        %find amplitude of max peak
        Magnitude(channel) = max(stim_data(channel, max_window - window(1)));

        %find latency of first significant peak
        [~, max_index, ~, ~] = findpeaks(stim_data(channel, max_window - window(1)),...
             'NPeaks', 1, 'MinPeakWidth', 5, 'MinPeakHeight', 2);    
        if ~isempty(max_index)
            Latency(channel) = max_index + max_window(1) - 1;
        end 
    %end
end
 
%% Create response metrics table
structheight = size(stim_data,1);
ResponseMetrics = struct('ChannelID', cell(structheight,1),'DistancetoStim', cell(structheight,1),...
    'Response_Confidence', cell(structheight,1),'Response_BOLDFC', cell(structheight,1),...
    'Response_Gaussian',cell(structheight,1), 'Response_Vertices',cell(structheight,1),...
    'Response_DNA_Percentage', cell(structheight,1),'Response_DNB_Percentage', cell(structheight,1),...
    'Response_FPNA_Percentage', cell(structheight,1),'Response_FPNB_Percentage', cell(structheight,1),...
    'Response_dATNA_Percentage', cell(structheight,1),'Response_dATNB_Percentage', cell(structheight,1),...
    'Response_SAL_Percentage', cell(structheight,1),'Response_LANG_Percentage', cell(structheight,1),...
    'Response_UNI_Percentage', cell(structheight,1),...
    'Response_Yeo5_Percentage', cell(structheight,1), 'Response_Yeo6_Percentage', cell(structheight,1),...
    'Response_Yeo7_Percentage', cell(structheight,1), 'Response_Yeo8_Percentage', cell(structheight,1),...
    'Response_Yeo11_Percentage', cell(structheight,1), 'Response_Yeo12_Percentage', cell(structheight,1),...
    'Response_Yeo13_Percentage', cell(structheight,1), 'Response_Yeo14_Percentage', cell(structheight,1),...
    'Response_Yeo15_Percentage', cell(structheight,1), 'Response_Yeo16_Percentage', cell(structheight,1),...
    'Response_Yeo17_Percentage', cell(structheight,1), 'Response_YeoUNI_Percentage', cell(structheight,1),...
    'Response_Magnitude', cell(structheight,1),'Response_Latency', cell(structheight,1),...
    'Response_Waveform', cell(structheight,1));    
for channel = 1:size(stim_data,1) %for each channel
    ResponseMetrics(channel).ChannelID = channel_IDs{channel,1};
    ResponseMetrics(channel).DistancetoStim = distances{matches(distances(:,1),channel_IDs{channel,1}),2};  
    index = matches(Response_Networks.ChannelID, channel_IDs{channel,1});
    ResponseMetrics(channel).Response_Vertices = Response_Networks.TotalVertices(index);
    ResponseMetrics(channel).Response_Gaussian = Response_Networks.TotalGaussian(index);
    ResponseMetrics(channel).Response_Confidence = Response_Networks.Confidence(index);
    ResponseMetrics(channel).Response_YeoConfidence = Response_Networks.YeoConfidence(index);
    ResponseMetrics(channel).Response_DNA_Percentage = Response_Networks.DNA_Percentage(index);
    ResponseMetrics(channel).Response_DNB_Percentage = Response_Networks.DNB_Percentage(index);
    ResponseMetrics(channel).Response_FPNA_Percentage = Response_Networks.FPNA_Percentage(index);        
    ResponseMetrics(channel).Response_FPNB_Percentage = Response_Networks.FPNB_Percentage(index);        
    ResponseMetrics(channel).Response_dATNA_Percentage = Response_Networks.dATNA_Percentage(index);        
    ResponseMetrics(channel).Response_dATNB_Percentage = Response_Networks.dATNB_Percentage(index);       
    ResponseMetrics(channel).Response_SAL_Percentage = Response_Networks.SAL_Percentage(index);        
    ResponseMetrics(channel).Response_LANG_Percentage = Response_Networks.LANG_Percentage(index);       
    ResponseMetrics(channel).Response_UNI_Percentage = Response_Networks.UNI_Percentage (index); 
    ResponseMetrics(channel).Response_Yeo5_Percentage = Response_Networks.Yeo5_Percentage(index);
    ResponseMetrics(channel).Response_Yeo6_Percentage = Response_Networks.Yeo6_Percentage(index);        
    ResponseMetrics(channel).Response_Yeo7_Percentage = Response_Networks.Yeo7_Percentage(index);       
    ResponseMetrics(channel).Response_Yeo8_Percentage = Response_Networks.Yeo8_Percentage(index);        
    ResponseMetrics(channel).Response_Yeo11_Percentage = Response_Networks.Yeo11_Percentage(index);        
    ResponseMetrics(channel).Response_Yeo12_Percentage = Response_Networks.Yeo12_Percentage(index);        
    ResponseMetrics(channel).Response_Yeo13_Percentage = Response_Networks.Yeo13_Percentage(index);        
    ResponseMetrics(channel).Response_Yeo14_Percentage = Response_Networks.Yeo14_Percentage(index);
    ResponseMetrics(channel).Response_Yeo15_Percentage = Response_Networks.Yeo15_Percentage(index);        
    ResponseMetrics(channel).Response_Yeo16_Percentage = Response_Networks.Yeo16_Percentage(index);        
    ResponseMetrics(channel).Response_Yeo17_Percentage = Response_Networks.Yeo17_Percentage(index);              
    ResponseMetrics(channel).Response_YeoUNI_Percentage = Response_Networks.YeoUNI_Percentage(index);
    ResponseMetrics(channel).Response_Magnitude = Magnitude(channel);
    ResponseMetrics(channel).Response_Latency = Latency(channel);        
    ResponseMetrics(channel).Response_Waveform = stim_data(channel,:);    
    
    stiminfo = split(StimSite,'-');
    MirroredStimSite = [stiminfo{2} '-' stiminfo{1}];
    stimindex = matches(bipolar_Lnames,StimSite) | matches(bipolar_Lnames,MirroredStimSite);
    ResponseMetrics(channel).Response_BOLDFC = corr_mat(stimindex,...
                                                matches(bipolar_Lnames,channel_IDs{channel,1}));
end

end
