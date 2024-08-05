function Create_MedialWall(SubjectID)
%% add paths
addpath('/projects/b1134/tools/electrode_modeling/CashLab')
addpath('/projects/b1134/tools/workbench/bin_rh_linux64')
addpath('/projects/b1134/tools/HCP_WB_Tutorial_1.0/fsaverage6')
addpath('/projects/b1134/tools/gifti-master')
wbpath='/projects/b1134/tools/workbench/bin_rh_linux64/wb_command';
currdirr = pwd;
cd('/projects/b1134/tools/iProc_archive/iProc/iProc_analysis'); 
matlab_setenv
cd(currdirr)

%% Load subject-specific network parcellation data
if strcmp(SubjectID, 'DQTAWH')
    kmeans_path = '/projects/b1134/analysis/surfFC/BNI/DQTAWH/REST_test_41k/2mm/vonmises_parcellations/17';
elseif strcmp(SubjectID, 'SSYQZJ')
    kmeans_path = '/projects/b1134/analysis/surfFC/BNI/SSYQZJ/REST_41k_test/2mm/vonmises_parcellations/14';
elseif strcmp(SubjectID, 'PHPKQJ')
    kmeans_path = '/projects/b1134/analysis/surfFC/BNI/PHPKQJ/REST_sm2/2mm/vonmises_parcellations/18';
elseif strcmp(SubjectID, 'KKYNWL')
    kmeans_path = '/projects/b1134/analysis/surfFC/BNI/KKYNWL/REST/2mm/vonmises_parcellations/17';    
elseif strcmp(SubjectID, 'XVFXFI')
    kmeans_path = '/projects/b1134/analysis/surfFC/BNI/XVFXFI/REST/2mm/vonmises_parcellations/14';              
elseif strcmp(SubjectID, 'ZWLWDL')
    kmeans_path = '/projects/b1134/analysis/surfFC/BNI/ZWLWDL/REST/2mm/vonmises_parcellations/17';             
elseif strcmp(SubjectID, 'DVYZVK')
    kmeans_path = '/projects/b1134/analysis/surfFC/BNI/DVYZVK/REST/2mm/vonmises_parcellations/20';    
elseif strcmp(SubjectID, 'PLLBNH')
    kmeans_path = '/projects/b1134/analysis/surfFC/BNI/PLLBNH/REST/2mm/vonmises_parcellations/??';    %change this
elseif strcmp(SubjectID, 'VPWMYH')
    kmeans_path = '/projects/b1134/analysis/surfFC/BNI/VPWMYH/REST_ALL/2mm/vonmises_parcellations/14';            
end
fileinfo = split(kmeans_path, '/');
k_number = str2double(fileinfo{end});
kmeans_file = sprintf('%s/%s_k%i_init100_roifsaverage3_vonmises_parcellation.dlabel.nii',...
    kmeans_path, SubjectID, k_number);
kmeans_data = ciftiopen(kmeans_file, wbpath, 1);

%% Create Medial Wall dlabel file
medial_wall = kmeans_data;
medial_wall.cdata = kmeans_data.cdata == 0;
medial_wall.cdata(medial_wall.cdata == 0) = NaN;
outname = sprintf('%s/MedialWall.dlabel.nii', kmeans_path);
ciftisavereset(medial_wall, outname, wbpath)

end