function CCEP_allrun_stimresponsepair_analysis
%% addpaths
addpath('/projects/b1134/tools/eeganalysis/STIM')

%% find all processed CCEP runs
files = dir(fullfile('/projects/b1134/processed/eegproc', 'BNI','**', '**', 'STIM*', '**', '**', 'sub*.mat'));

FolderList = cell(height(files),1);
for i = 1:height(files) %convert from structure to cell array of folder names
    FolderList{i} = files(i).folder;
end
FolderList = unique(FolderList); %remove duplicates

%Excluded Patients
FolderList(cellfun(@(x) contains(x, {'OAUOBH','ATHUAT','DVYZVK'}), FolderList)) = [];

%sham runs
FolderList(cellfun(@(x) contains(x, 'sham'), FolderList)) = [];

%discovery data runs
DiscoveryDataRuns = {'/projects/b1134/processed/eegproc/BNI/ATHUAT/EMU0018/STIM01/AC10-AC11/5mA',...
    '/projects/b1134/processed/eegproc/BNI/ATHUAT/EMU0018/STIM01/D7-D8/5mA',...
    '/projects/b1134/processed/eegproc/BNI/ATHUAT/EMU0018/STIM01/O11-O12/5mA',...
    '/projects/b1134/processed/eegproc/BNI/ATHUAT/EMU0018/STIM01/U10-U11/5mA',...
    '/projects/b1134/processed/eegproc/BNI/ATHUAT/EMU0018/STIM01/W7-W8/5mA',...
    '/projects/b1134/processed/eegproc/BNI/DQTAWH/EMU0036/STIM01/R10-R11/5mA',...
    '/projects/b1134/processed/eegproc/BNI/DQTAWH/EMU0036/STIM01/H11-H12/5mA',...
    '/projects/b1134/processed/eegproc/BNI/DQTAWH/EMU0036/STIM01/G6-G7/5mA',...
    '/projects/b1134/processed/eegproc/BNI/DQTAWH/EMU0036/STIM01/G2-G3/5mA',...
    '/projects/b1134/processed/eegproc/BNI/XVFXFI/NWB/STIM01/B10-B9/3mA_retest'};
FolderList(cellfun(@(x) matches(x, DiscoveryDataRuns), FolderList)) = [];

%runs with not enough trials
FolderList(cellfun(@(x) contains(x, {'LC10-LC11', 'LD10-LD11', 'RC10-RC11', ...
    'RD9-RD10'}), FolderList)) = [];


%% Calculate stimulation and response metrics for each run
structheight = 100000;
DataTable = struct('SubjectID', cell(structheight,1), 'StimSite', cell(structheight,1),...
    'StimSiteType', cell(structheight,1), 'ChannelID', cell(structheight,1),...
    'CurrentIntensity', cell(structheight,1), 'PulseWidth', cell(structheight,1),...
    'Stim_Confidence',cell(structheight,1),'Stim_YeoConfidence',cell(structheight,1),...
    'Stim_Gaussian',cell(structheight,1),'Stim_Vertices',cell(structheight,1),...
    'Stim_DNA_Percentage', cell(structheight,1), 'Stim_DNB_Percentage', cell(structheight,1),...
    'Stim_FPNA_Percentage', cell(structheight,1), 'Stim_FPNB_Percentage', cell(structheight,1),...
    'Stim_dATNA_Percentage',cell(structheight,1), 'Stim_dATNB_Percentage', cell(structheight,1),...
    'Stim_SAL_Percentage', cell(structheight,1), 'Stim_LANG_Percentage', cell(structheight,1),...
    'Stim_UNI_Percentage', cell(structheight,1),...
    'Stim_Yeo5_Percentage', cell(structheight,1), 'Stim_Yeo6_Percentage', cell(structheight,1),...
    'Stim_Yeo7_Percentage', cell(structheight,1), 'Stim_Yeo8_Percentage', cell(structheight,1),...
    'Stim_Yeo11_Percentage', cell(structheight,1), 'Stim_Yeo12_Percentage', cell(structheight,1),...
    'Stim_Yeo13_Percentage', cell(structheight,1), 'Stim_Yeo14_Percentage', cell(structheight,1),...
    'Stim_Yeo15_Percentage', cell(structheight,1), 'Stim_Yeo16_Percentage', cell(structheight,1),...
    'Stim_Yeo17_Percentage', cell(structheight,1), 'Stim_YeoUNI_Percentage', cell(structheight,1),...
    'DistancetoStim', cell(structheight,1),'Response_BOLDFC', cell(structheight,1),...
    'Response_Confidence', cell(structheight,1),'Response_YeoConfidence', cell(structheight,1),...
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
    'Response_Magnitude', cell(structheight,1),'Response_Latency', cell(structheight,1));    
counter = 1;
for i = 1:length(FolderList)

    %calculate response metrics 
    ResponseMetrics = CCEP_responsemetrics(FolderList{i});
    %calculate stimulation parameters
    StimParameters = CCEP_stimparameters(FolderList{i}); 
    
    %populate table
    for j = 1:height(ResponseMetrics)
        DataTable(counter).ChannelID = ResponseMetrics(j).ChannelID; 
        DataTable(counter).DistancetoStim = ResponseMetrics(j).DistancetoStim;
        DataTable(counter).Response_BOLDFC = ResponseMetrics(j).Response_BOLDFC;
        DataTable(counter).Response_Vertices = ResponseMetrics(j).Response_Vertices;
        DataTable(counter).Response_Gaussian = ResponseMetrics(j).Response_Gaussian; 
        DataTable(counter).Response_Confidence = ResponseMetrics(j).Response_Confidence;
        DataTable(counter).Response_YeoConfidence = ResponseMetrics(j).Response_YeoConfidence;
        DataTable(counter).Response_DNA_Percentage = ResponseMetrics(j).Response_DNA_Percentage; 
        DataTable(counter).Response_DNB_Percentage = ResponseMetrics(j).Response_DNB_Percentage; 
        DataTable(counter).Response_FPNA_Percentage = ResponseMetrics(j).Response_FPNA_Percentage;        
        DataTable(counter).Response_FPNB_Percentage = ResponseMetrics(j).Response_FPNB_Percentage;        
        DataTable(counter).Response_dATNA_Percentage = ResponseMetrics(j).Response_dATNA_Percentage;         
        DataTable(counter).Response_dATNB_Percentage = ResponseMetrics(j).Response_dATNB_Percentage;      
        DataTable(counter).Response_SAL_Percentage = ResponseMetrics(j).Response_SAL_Percentage;      
        DataTable(counter).Response_LANG_Percentage = ResponseMetrics(j).Response_LANG_Percentage;   
        DataTable(counter).Response_UNI_Percentage = ResponseMetrics(j).Response_UNI_Percentage; 
        DataTable(counter).Response_Yeo5_Percentage = ResponseMetrics(j).Response_Yeo5_Percentage; 
        DataTable(counter).Response_Yeo6_Percentage = ResponseMetrics(j).Response_Yeo6_Percentage;       
        DataTable(counter).Response_Yeo7_Percentage = ResponseMetrics(j).Response_Yeo7_Percentage;      
        DataTable(counter).Response_Yeo8_Percentage = ResponseMetrics(j).Response_Yeo8_Percentage;     
        DataTable(counter).Response_Yeo11_Percentage = ResponseMetrics(j).Response_Yeo11_Percentage;         
        DataTable(counter).Response_Yeo12_Percentage = ResponseMetrics(j).Response_Yeo12_Percentage;       
        DataTable(counter).Response_Yeo13_Percentage = ResponseMetrics(j).Response_Yeo13_Percentage;       
        DataTable(counter).Response_Yeo14_Percentage = ResponseMetrics(j).Response_Yeo14_Percentage;
        DataTable(counter).Response_Yeo15_Percentage = ResponseMetrics(j).Response_Yeo15_Percentage;      
        DataTable(counter).Response_Yeo16_Percentage = ResponseMetrics(j).Response_Yeo16_Percentage;     
        DataTable(counter).Response_Yeo17_Percentage = ResponseMetrics(j).Response_Yeo17_Percentage;            
        DataTable(counter).Response_YeoUNI_Percentage = ResponseMetrics(j).Response_YeoUNI_Percentage;
        DataTable(counter).Response_Magnitude = ResponseMetrics(j).Response_Magnitude;
        DataTable(counter).Response_Latency = ResponseMetrics(j).Response_Latency; 
        
        DataTable(counter).SubjectID = StimParameters.SubjectID;
        DataTable(counter).StimSite = StimParameters.StimSite;
        DataTable(counter).StimSiteType = StimParameters.SiteType;       
        DataTable(counter).CurrentIntensity = StimParameters.CurrentIntensity;
        DataTable(counter).PulseWidth = StimParameters.PulseWidth;
        DataTable(counter).Stim_Vertices = StimParameters.Stim_Vertices;
        DataTable(counter).Stim_Gaussian = StimParameters.Stim_Gaussian; 
        DataTable(counter).Stim_Confidence = StimParameters.Stim_Confidence;
        DataTable(counter).Stim_YeoConfidence = StimParameters.Stim_YeoConfidence;
        DataTable(counter).Stim_DNA_Percentage = StimParameters.Stim_DNA_Percentage; 
        DataTable(counter).Stim_DNB_Percentage = StimParameters.Stim_DNB_Percentage; 
        DataTable(counter).Stim_FPNA_Percentage = StimParameters.Stim_FPNA_Percentage;        
        DataTable(counter).Stim_FPNB_Percentage = StimParameters.Stim_FPNB_Percentage;        
        DataTable(counter).Stim_dATNA_Percentage = StimParameters.Stim_dATNA_Percentage;         
        DataTable(counter).Stim_dATNB_Percentage = StimParameters.Stim_dATNB_Percentage;      
        DataTable(counter).Stim_SAL_Percentage = StimParameters.Stim_SAL_Percentage;      
        DataTable(counter).Stim_LANG_Percentage = StimParameters.Stim_LANG_Percentage;   
        DataTable(counter).Stim_UNI_Percentage = StimParameters.Stim_UNI_Percentage; 
        DataTable(counter).Stim_Yeo5_Percentage = StimParameters.Stim_Yeo5_Percentage; 
        DataTable(counter).Stim_Yeo6_Percentage = StimParameters.Stim_Yeo6_Percentage;       
        DataTable(counter).Stim_Yeo7_Percentage = StimParameters.Stim_Yeo7_Percentage;      
        DataTable(counter).Stim_Yeo8_Percentage = StimParameters.Stim_Yeo8_Percentage;     
        DataTable(counter).Stim_Yeo11_Percentage = StimParameters.Stim_Yeo11_Percentage;         
        DataTable(counter).Stim_Yeo12_Percentage = StimParameters.Stim_Yeo12_Percentage;       
        DataTable(counter).Stim_Yeo13_Percentage = StimParameters.Stim_Yeo13_Percentage;       
        DataTable(counter).Stim_Yeo14_Percentage = StimParameters.Stim_Yeo14_Percentage;
        DataTable(counter).Stim_Yeo15_Percentage = StimParameters.Stim_Yeo15_Percentage;      
        DataTable(counter).Stim_Yeo16_Percentage = StimParameters.Stim_Yeo16_Percentage;     
        DataTable(counter).Stim_Yeo17_Percentage = StimParameters.Stim_Yeo17_Percentage;            
        DataTable(counter).Stim_YeoUNI_Percentage = StimParameters.Stim_YeoUNI_Percentage;     
        counter = counter + 1;
    end
end
%remove empty rows
DataTable = struct2table(DataTable);
DataTable = DataTable(~cellfun(@isempty, DataTable{:,1}),:);

%% Save Table to file
filename = '/projects/b1134/analysis/ccyr/StimProject/StimResponsePairInfoTable.xlsx';
if isfile(filename)
    delete(filename)
end
writetable(DataTable, '/projects/b1134/analysis/ccyr/StimProject/StimResponsePairInfoTable.xlsx')


