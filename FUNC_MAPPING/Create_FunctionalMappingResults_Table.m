function Create_FunctionalMappingResults_Table
%% add paths


%% Load Data
filename = '/projects/b1134/analysis/ccyr/FunctionalMappingProject/FunctionalMappingResults.xlsx';
opts = detectImportOptions(filename);
opts.VariableTypes(:) = {'char'};
InfoTable = readtable('/projects/b1134/analysis/ccyr/FunctionalMappingProject/FunctionalMappingResults.xlsx',...
    opts);

%% Add Additional Info to Table
last_SubjectID = [];
last_Session = [];
last_StimulationSite = [];
for i = 1:height(InfoTable) %for each stim trial
    %if current stim trial is not from the same subject and surgery as the last stim trial
    if ~strcmp(InfoTable.SubjectID{i},last_SubjectID) || ~strcmp(InfoTable.Session{i},last_Session)        
        %load electrode type and coordinate information
        if length(unique(InfoTable.Session(matches(InfoTable.SubjectID,InfoTable.SubjectID{i})))) == 1 %for patients with one surgery
            RASDirectory = ['/projects/b1134/processed/fs/',InfoTable.SubjectID{i},'/',InfoTable.SubjectID{i},'/elec_recon'];
        else  
            RASDirectory = ['/projects/b1134/processed/fs/',InfoTable.SubjectID{i},'/',InfoTable.SubjectID{i},'/elec_recon_',...
                InfoTable.Session{i}];
        end
        fid = fopen(sprintf('%s/%s.electrodeNames', RASDirectory, InfoTable.SubjectID{i}));
        elecinfo = textscan(fid, '%s %s %s');
        fclose(fid);
        elecinfo = [elecinfo{1}, elecinfo{2}, elecinfo{3}];
        elecinfo = elecinfo(3:end,:);
    end
    
    %open current stim site ROI
    if ~strcmp(InfoTable.StimulationSite{i},last_StimulationSite)
        StimSiteInfo = split(InfoTable.StimulationSite{i}, '-');
        Contact1 = StimSiteInfo{1};
        Contact2 = StimSiteInfo{2};
        index1 = matches(elecinfo(:,1), Contact1);
    end
    
    %determine other stim parameters 
    InfoTable.SiteType(i) = elecinfo(index1,2);
    if strcmp(Contact2, 'Ref')
        InfoTable.StimulationType{i} = 'Monopolar';
    else
        InfoTable.StimulationType{i} = 'Bipolar';
    end
        
    last_SubjectID = InfoTable.SubjectID{i};
    last_Session = InfoTable.Session{i};
    last_StimulationSite = InfoTable.StimulationSite{i};
end

%% Save Data
outfile = '/projects/b1134/analysis/ccyr/FunctionalMappingProject/FunctionalMappingResults_appended.xlsx';
if exist(outfile, 'file')
    delete(outfile)
end
writetable(InfoTable, outfile);

end
