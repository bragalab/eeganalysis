function StimParameters = CCEP_stimparameters(datapath)
fprintf('Calculating Stimulation Parameters for %s. \n', datapath)
%% add paths
addpath('/projects/b1134/tools/electrode_visualization')

%% Determine parameters from filename
Folderinfo = split(datapath,'/');
SubjectID = Folderinfo{end-4};
SessionID = Folderinfo{end-3};
TaskID = Folderinfo{end-2};
StimSite = Folderinfo{end-1};
Contactinfo = split(Folderinfo{end-1}(~isletter(Folderinfo{end-1})),'-');
if sum(sort(str2double(Contactinfo)) == str2double(Contactinfo)) < 2 && abs(diff(str2double(Contactinfo))) == 1
    Orig_StimSite = Folderinfo{end-1};
    Contactinfo = split(Folderinfo{end-1},'-');
    StimSite = [Contactinfo{2}, '-', Contactinfo{1}];%for depth electrodes reorder the stim site contacts in ascending order if necessary
else
    Orig_StimSite = StimSite;
end
CurrentIntensity = str2double(replace(Folderinfo{end}, {'_retest', 'mA'}, ''));
if matches(SubjectID, {'',''})% omitted code due to subject identifiers
    PulseWidth = 200;
else
    PulseWidth = 300;
end

%% determine stim site network percentages
% load network info
% omitted code due to subject identifiers

%load ranked network memberships for each electrode
% omitted code due to subject identifiers

stim_channels = split(StimSite,'-');
MirroredStimSite = [stim_channels{2} '-' stim_channels{1}];
stim_index = matches(Stim_Networks.ChannelID, StimSite) |...
    matches(Stim_Networks.ChannelID, MirroredStimSite);

%% determine stimulation site properties
RASDirectory = ['/projects/b1134/processed/fs/',SubjectID,'/',SubjectID,'/elec_recon'];
fid = fopen(sprintf('%s/%s.electrodeNames', RASDirectory, SubjectID));
elecinfo = textscan(fid, '%s %s %s');
fclose(fid);
elecinfo = [elecinfo{1}, elecinfo{2}, elecinfo{3}];
elecinfo = elecinfo(3:end,:);
index = matches(elecinfo(:,1), stim_channels{1});
SiteType = elecinfo(index,2);

%% Create stimulation parameters table
StimParameters = struct('StimSite', StimSite, 'SubjectID', SubjectID, 'SiteType',SiteType,...
    'CurrentIntensity', CurrentIntensity, 'PulseWidth', PulseWidth,...
    'Stim_Confidence',Stim_Networks.Confidence(stim_index),'Stim_YeoConfidence',Stim_Networks.YeoConfidence(stim_index),...
    'Stim_Gaussian',Stim_Networks.TotalGaussian(stim_index),'Stim_Vertices',Stim_Networks.TotalVertices(stim_index),...
    'Stim_DNA_Percentage', Stim_Networks.DNA_Percentage(stim_index), 'Stim_DNB_Percentage', Stim_Networks.DNB_Percentage(stim_index),...
    'Stim_FPNA_Percentage', Stim_Networks.FPNA_Percentage(stim_index), 'Stim_FPNB_Percentage', Stim_Networks.FPNB_Percentage(stim_index),...
    'Stim_dATNA_Percentage',Stim_Networks.dATNA_Percentage(stim_index), 'Stim_dATNB_Percentage', Stim_Networks.dATNB_Percentage(stim_index),...
    'Stim_SAL_Percentage', Stim_Networks.SAL_Percentage(stim_index), 'Stim_LANG_Percentage', Stim_Networks.LANG_Percentage(stim_index),...
    'Stim_UNI_Percentage', Stim_Networks.UNI_Percentage(stim_index),...
    'Stim_Yeo5_Percentage', Stim_Networks.Yeo5_Percentage(stim_index), 'Stim_Yeo6_Percentage', Stim_Networks.Yeo6_Percentage(stim_index),...
    'Stim_Yeo7_Percentage', Stim_Networks.Yeo7_Percentage(stim_index), 'Stim_Yeo8_Percentage', Stim_Networks.Yeo8_Percentage(stim_index),...
    'Stim_Yeo11_Percentage', Stim_Networks.Yeo11_Percentage(stim_index), 'Stim_Yeo12_Percentage', Stim_Networks.Yeo12_Percentage(stim_index),...
    'Stim_Yeo13_Percentage', Stim_Networks.Yeo13_Percentage(stim_index), 'Stim_Yeo14_Percentage', Stim_Networks.Yeo14_Percentage(stim_index),...
    'Stim_Yeo15_Percentage', Stim_Networks.Yeo15_Percentage(stim_index), 'Stim_Yeo16_Percentage', Stim_Networks.Yeo16_Percentage(stim_index),...
    'Stim_Yeo17_Percentage', Stim_Networks.Yeo17_Percentage(stim_index), 'Stim_YeoUNI_Percentage', Stim_Networks.YeoUNI_Percentage(stim_index));

end
