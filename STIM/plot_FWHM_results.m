
%% find all processed CCEP runs
files = dir(fullfile('/projects/b1134/processed/eegproc', 'BNI','**', '**', 'STIM*', '**', '**', 'sub*.mat'));

FolderList = cell(height(files),1);
for i = 1:height(files) %convert from structure to cell array of folder names
    FolderList{i} = files(i).folder;
end
FolderList = unique(FolderList); %remove duplicates

% Remove excluded runs
% omitted code due to subject identifiers

subjectlist = {''};% omitted code due to subject identifiers
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
