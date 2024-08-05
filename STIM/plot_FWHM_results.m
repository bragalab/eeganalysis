
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

%%

subjectlist = {'DQTAWH','PHPKQJ','SSYQZJ','XVFXFI','YKBYHS','CEWLLT','TTHMMI', 'XBSGST', 'ZWLWDL'};
All_Results = cell2table(cell(height(FolderList), 4));
All_Results.Properties.VariableNames = {'SubjectID', 'CurrentIntensity', 'FWHM', 'Rsquared'};
counter = 1;
for i = 1:length(subjectlist)
    RunList = FolderList(cellfun(@(x) contains(x, subjectlist{i}), FolderList));
    runinfo = split(RunList,'/');
    load(sprintf('/projects/b1134/processed/eegproc/BNI/%s/%s_FWHM_Results_run.mat',...
            subjectlist{i},subjectlist{i}))
    Run_Results = Results;
    clear Results

    for j = 1:length(Run_Results)
        All_Results.FWHM{counter+j-1} = Run_Results(j).FWHM;
        All_Results.Rsquared{counter+j-1} = Run_Results(j).Rsquared;
        All_Results.SubjectID{counter+j-1} = runinfo{j,7};
        All_Results.CurrentIntensity{counter+j-1} = runinfo{j,11};
    end
    counter = counter + length(RunList);
    
end
writetable(All_Results, '/projects/b1134/analysis/ccyr/StimProject/AllSubjects_FWHM_Results.xlsx')
%%
figure
subplot(1,3,1)
hold on
for i = 1:length(subjectlist)
    index = contains(All_Results.SubjectID, subjectlist{i});
    scatter(cell2mat(All_Results.FWHM(index)),cell2mat(All_Results.Rsquared(index)),...
        'filled', 'MarkerEdgeColor', 'k');
end
ylim([0 1])
ylabel('R Squared Value')
xlim([0 40])
xlabel('FWHM (mm)')
legend(subjectlist)

subplot(1,3,2)
hold on

legendinfo = {};
legend_handles = [];
for i = 1:8
    index = contains(All_Results.CurrentIntensity, sprintf('%imA', i));
    legend_handles(i) = scatter(cell2mat(All_Results.FWHM(index)),cell2mat(All_Results.Rsquared(index)),...
        'filled', 'MarkerEdgeColor', 'k');
    legend_info{i} = sprintf('%imA', i);
end

ylim([0 1])
ylabel('R Squared Value')
xlim([0 40])
xlabel('FWHM (mm)')
legend(legend_handles, legend_info)

subplot(1,3,3)
hold on
swarmchart(ones(size(All_Results.FWHM)).*(1+(rand(size(All_Results.FWHM))-0.5)/10),...
    cell2mat(All_Results.FWHM), 'filled', 'MarkerEdgeColor', 'k')
xlim([0.75 1.25])
xticks([])
ylim([0 40])
ylabel('FWHM')

