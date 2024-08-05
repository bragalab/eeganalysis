
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

%% load data
all_stim_data = NaN(length(FolderList)*150,2000);
all_CCEP_metrics = cell2table(cell(length(FolderList)*150,12));
all_CCEP_metrics.Properties.VariableNames = {'SubjectID','StimSite','ResponseSite',...
    'StimShaft', 'CurrentIntensity','DistancefromStim','N1Amplitude','N1Latency',...
    'N2Amplitude','N2Latency','MaxAmplitude','MaxLatency'};
counter = 1;
for i = 1:length(FolderList)
    %load run
    fileinfo = split(FolderList{i},'/');
    SubjectID = fileinfo{end-4};
    StimSite = fileinfo{end-1};
    CurrentIntensity = replace(fileinfo{end},'_retest','');
    stim_file = dir(sprintf('%s/*_ds_qcx_epoch_trialsx_bpref_z_flip_avg.mat', FolderList{i}));
    load([stim_file.folder,'/',stim_file.name], 'Z_avg_flip', 'channel_IDs',...
       'white_channels');
    load([stim_file.folder, '/bipolar_distances.mat'], 'distances');
    stim_data = Z_avg_flip;
    clear Z_avg_flip
    stim_file = dir(sprintf('%s/*_ds_qcx_epoch_trialsx_bpref_z_flip.mat', FolderList{i}));
    load([stim_file.folder,'/',stim_file.name], 'Z_flip');
    
    for j = 1:height(stim_data)
        channels = split(channel_IDs(j,1), '-');
        if sum(matches(channels, white_channels)) > 1 %exclude WM-WM contacts
            stim_data(j,:) = NaN;
        elseif sum(matches(channels,split(StimSite,'-'))) > 0 %exclude stimulation contacts
            stim_data(j,:) = NaN;
        elseif sum(isinf(stim_data(j,:))) > 0 %exclude contacts with infinites
            fprintf('Infinite Value Subject:%s StimSite:%s CurrentIntensity:%s ResponseSite:%s DistancetoStim:%3.2f N_BadTrials:%i\n',...
                SubjectID, StimSite, CurrentIntensity, channel_IDs{j,1}, distances{j,2}, sum(sum(isinf(Z_flip(j,:,:)),2) > 0))
            stim_data(j,:) = NaN;
        elseif sum(abs(stim_data(j,:)) > 1*10^12) > 0   
            fprintf('Mega Artifact Subject:%s StimSite:%s CurrentIntensity:%s ResponseSite:%s DistancetoStim:%3.2f N_BadTrials:%i\n',...
                SubjectID, StimSite, CurrentIntensity, channel_IDs{j,1}, distances{j,2}, sum(sum(isinf(Z_flip(j,:,:)),2) > 0))
            stim_data(j,:) = NaN;           
        end
    end
    
    %determine which contacts are on stimulating shaft
    Shafts = cell(height(channel_IDs),1);
    for j = 1:length(channel_IDs) %from the list of all electrode names
        contactinfo = split(channel_IDs{j, 1},'-');
        Shafts{j} = contactinfo{1}(1:find(isletter(contactinfo{1}), 1, 'last'));
    end
    Stiminfo = split(StimSite,'-');
    StimShaft = Stiminfo{1}(1:find(isletter(Stiminfo{1}), 1, 'last'));
    is_StimShaft = matches(Shafts,StimShaft);
    
    %remove excluded contacts
    nan_indices = sum(~isnan(stim_data),2) == 0;
    stim_data(nan_indices,:) = [];
    channel_IDs(nan_indices,:) = [];
    distances(nan_indices,:) = [];
    is_StimShaft(nan_indices) = [];
    
    %populate tables
    if contains(FolderList{i}, 'NWB') %clinical NU stim trials are shorter
        all_stim_data(counter:counter+height(stim_data)-1,1:1000) = stim_data;
    else    
        all_stim_data(counter:counter+height(stim_data)-1,:) = stim_data;
    end
    all_CCEP_metrics.SubjectID(counter:counter+height(stim_data)-1) = {SubjectID};
    all_CCEP_metrics.StimSite(counter:counter+height(stim_data)-1) = {StimSite};
    all_CCEP_metrics.ResponseSite(counter:counter+height(stim_data)-1) = channel_IDs(:,1);
    all_CCEP_metrics.StimShaft(counter:counter+height(stim_data)-1) = num2cell(is_StimShaft);
    all_CCEP_metrics.CurrentIntensity(counter:counter+height(stim_data)-1) = {CurrentIntensity};
    all_CCEP_metrics.DistancefromStim(counter:counter+height(stim_data)-1) = distances(:,2);
    counter = counter + height(stim_data);
end    

all_stim_data(cellfun(@isempty,all_CCEP_metrics.SubjectID),:) = [];
all_CCEP_metrics(cellfun(@isempty,all_CCEP_metrics.SubjectID),:) = [];

%% find peaks
window = -500:1499;
n1_window = 5:70;
n2_window = 70:300;
max_window = 10:400; 
for i = 1:height(all_stim_data) %for each channel
    %find max peak
    [max_peak, max_index, ~, ~] = findpeaks(all_stim_data(i, max_window - window(1)),...
         'NPeaks', 1, 'SortStr', 'descend');    
    if ~isempty(max_index) && max_peak > 0
        all_CCEP_metrics.MaxLatency{i} = max_index + max_window(1) - 1;
        all_CCEP_metrics.MaxAmplitude{i} = max_peak;
    else
        all_CCEP_metrics.MaxLatency{i} = NaN;
        all_CCEP_metrics.MaxAmplitude{i} = NaN;
    end 

    %find N1 peak
    [n1_peak, n1_index, ~, ~] = findpeaks(all_stim_data(i, n1_window - window(1)),...
         'NPeaks', 1, 'SortStr', 'descend', 'MinPeakWidth', 5);    
    if ~isempty(n1_index) && n1_peak > 0
        all_CCEP_metrics.N1Latency{i} = n1_index + n1_window(1) - 1;
        all_CCEP_metrics.N1Amplitude{i} = n1_peak;
    else
        all_CCEP_metrics.N1Latency{i} = NaN;
        all_CCEP_metrics.N1Amplitude{i} = NaN;
    end 

    %find N2 peak
    [n2_peak, n2_index, ~, ~] = findpeaks(all_stim_data(i, n2_window - window(1)),...
         'NPeaks', 1, 'SortStr', 'descend', 'MinPeakWidth', 5);    
    if ~isempty(n2_index) && n2_peak > 0
        all_CCEP_metrics.N2Latency{i} = n2_index + n2_window(1) - 1;
        all_CCEP_metrics.N2Amplitude{i} = n2_peak;
    else
        all_CCEP_metrics.N2Latency{i} = NaN;
        all_CCEP_metrics.N2Amplitude{i} = NaN;
    end 
end


%% calculate average waveforms
binned_CCEPs = zeros(11,1000);
binned_SEs = zeros(11,1000);
binned_Count = zeros(11,1);
distancebins = 110:-10:0;
for i = 1:length(distancebins)-1
    indices = cell2mat(all_CCEP_metrics.DistancefromStim) < distancebins(i) & ...
        cell2mat(all_CCEP_metrics.DistancefromStim) >= distancebins(i+1) &...
        cell2mat(all_CCEP_metrics.MaxAmplitude) >= 2;
    binned_Count(i) = sum(indices);
    binned_CCEPs(i,:) = mean(all_stim_data(indices,1:1000), 1);
    binned_SEs(i,:) = std(all_stim_data(indices,1:1000), 0, 1)...
                    /sqrt(sum(indices));
end

%% CCEP waveform vs distance
fig = figure;
fig.Units = 'inches';
fig.AutoResizeChildren = 'off';
fig.Position = [1 1 7.4 2.4];
t = tiledlayout(fig, 1,1,'TileSpacing','Compact','Padding','Compact');
nexttile
hold on
color = parula;
time_x = -500:499;
legendinfo = {};
legend_handles = [];
for i = 1:height(binned_CCEPs)
    if binned_Count(i) > 0
        SE_up = binned_CCEPs(i,:) + binned_SEs(i,:);
        SE_down = binned_CCEPs(i,:) - binned_SEs(i,:);
        fill([time_x fliplr(time_x)], [SE_up fliplr(SE_down)], ...
            color(i*23,:) ... 
            , 'EdgeColor', 'none', 'FaceAlpha', 0.25);
        legend_handles(i) = plot(time_x, binned_CCEPs(i,:), 'Color',color(i*17,:), 'LineWidth', 2);
        legendinfo{i} = sprintf('%i-%imm (%i)', distancebins(i+1), distancebins(i),...
            binned_Count(i));
    end
end
ylabel('Amplitude (Z)')
ylim([-2 10])
xlabel('Time (ms)')
set(gca,'FontSize',11)
l = legend(flip(legend_handles), flip(legendinfo), 'Location', 'northwest', 'NumColumns', 2, 'FontSize', 10);
l.ItemTokenSize(1) = 15;
legend('boxoff')
% save figure
print(fig,'/projects/b1134/analysis/ccyr/MATLAB_figures/CCEP_HFS_SuppFigure1a', ...
     '-dpng', '-r300')
 %% CCEP max amplitude  vs distance
fig = figure;
fig.Units = 'inches';
fig.AutoResizeChildren = 'off';
fig.Position = [1 1 3 2.4];
t = tiledlayout(fig, 1,1,'TileSpacing','Compact','Padding','Compact');
nexttile
hold on

indices = ~isnan(cell2mat(all_CCEP_metrics.MaxAmplitude));
Distances = cell2mat(all_CCEP_metrics.DistancefromStim(indices));
Amplitudes = cell2mat(all_CCEP_metrics.MaxAmplitude(indices));
StimShaft = cell2mat(all_CCEP_metrics.StimShaft(indices));
ModelFunction = @(b, x) b(1) + b(2) .* exp(b(3)./(x));
beta0 = [0 1 1];
mdl = fitnlm(Distances, Amplitudes, ModelFunction, beta0);
coefficients = mdl.Coefficients{:, 'Estimate'};
xFitted = linspace(min(Distances), max(Distances), 1920); 
yFitted = ModelFunction(coefficients, xFitted(:));
yFitted = max(0, yFitted);
a = scatter(Distances, Amplitudes, ...
    5, 'filled', 'MarkerEdgeColor', 'none');
b = scatter(Distances(StimShaft), Amplitudes(StimShaft), ...
    5, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'r');
%plot(xFitted, yFitted, 'k-', 'LineWidth', 2);
xline(20,'--k', 'LineWidth', 2)
xlim([0 150])
xticks(0:20:150)
ylim([0 50])
xlabel('Euclidean Distance (mm)')
ylabel('Max Amplitude (Z)')
legend([b], {'Stim Shafts'}, 'FontSize', 10)
legend('boxoff')
set(gca,'FontSize',11)
% save figure
print(fig,'/projects/b1134/analysis/ccyr/MATLAB_figures/CCEP_HFS_SuppFigure1b', ...
     '-dpng', '-r300')

%% plot all responses

fig = figure;
fig.Units = 'inches';
fig.Position = [0 0 12 7];
tiledlayout(2,3,'TileSpacing','compact','Padding','compact')

%n1 amplitude vs distance
nexttile(4, [1 1])
hold on
indices = ~isnan(cell2mat(all_CCEP_metrics.N1Amplitude));
Distances = cell2mat(all_CCEP_metrics.DistancefromStim(indices));
Amplitudes = cell2mat(all_CCEP_metrics.N1Amplitude(indices));
StimShaft = cell2mat(all_CCEP_metrics.StimShaft(indices));
ModelFunction = @(b, x) b(1) + b(2) .* exp(b(3)./(x));
beta0 = [0 1 1];
mdl = fitnlm(Distances, Amplitudes, ModelFunction, beta0);
coefficients = mdl.Coefficients{:, 'Estimate'};
xFitted = linspace(min(Distances), max(Distances), 1920); 
yFitted = ModelFunction(coefficients, xFitted(:));
yFitted = max(0, yFitted);
a = scatter(Distances, Amplitudes, ...
    5, 'filled', 'MarkerEdgeColor', 'none');
b = scatter(Distances(StimShaft), Amplitudes(StimShaft), ...
    5, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'r');
plot(xFitted, yFitted, 'k-', 'LineWidth', 2);
xlim([0 150])
xticks(0:20:150)
ylim([0 50])
xlabel('Euclidean Distance (mm)')
ylabel('N1 Amplitude (Z)')
legend([a b], {'All Data', 'Stim Shafts'})
set(gca,'FontSize',12)

%n2 amplitude vs distance
nexttile(5, [1 1])

hold on
indices = ~isnan(cell2mat(all_CCEP_metrics.N2Amplitude));
Distances = cell2mat(all_CCEP_metrics.DistancefromStim(indices));
Amplitudes = cell2mat(all_CCEP_metrics.N2Amplitude(indices));
StimShaft = cell2mat(all_CCEP_metrics.StimShaft(indices));
ModelFunction = @(b, x) b(1) + b(2) .* exp(b(3)./(x));
beta0 = [0 1 1];
mdl = fitnlm(Distances, Amplitudes, ModelFunction, beta0);
coefficients = mdl.Coefficients{:, 'Estimate'};
xFitted = linspace(min(Distances), max(Distances), 1920); 
yFitted = ModelFunction(coefficients, xFitted(:));
yFitted = max(0, yFitted);
a = scatter(Distances, Amplitudes, ...
    5, 'filled', 'MarkerEdgeColor', 'none');
b = scatter(Distances(StimShaft), Amplitudes(StimShaft), ...
    5, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'r');
plot(xFitted, yFitted, 'k-', 'LineWidth', 2);
xlim([0 150])
xticks(0:20:150)
ylim([0 50])
%xlabel('Euclidean Distance (mm)')
ylabel('N2 Amplitude (Z)')
%legend([a b], {'All Data', 'Stim Shafts'})
xlabel('')
legend off
set(gca,'FontSize',14)





%% plot all responses by subject
subjects = unique(all_CCEP_metrics.SubjectID);
fig = figure;
fig.Units = 'inches';
fig.Position = [0 0 8 6];
tiledlayout(2,5,'TileSpacing','compact','Padding','compact')


%max amplitude vs distance
for i = 1:length(subjects)
    
nexttile
    hold on
    indices = matches(all_CCEP_metrics.SubjectID, subjects{i});
    Distances = cell2mat(all_CCEP_metrics.DistancefromStim(indices));
    Amplitudes = cell2mat(all_CCEP_metrics.MaxAmplitude(indices));
    StimShaft = cell2mat(all_CCEP_metrics.StimShaft(indices));
    f = fit(Distances, Amplitudes, fittype('a*x^(-3)'), 'StartPoint', 1000000);
    a = scatter(Distances, Amplitudes, ...
        5, 'filled', 'MarkerEdgeColor', 'none');
    b = scatter(Distances(StimShaft), Amplitudes(StimShaft), ...
        5, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'r');
    c = plot(f, 'k');
    c.LineWidth = 2;
    xlim([0 150])
    xticks(0:40:150)
    ylim([0 50])
    xlabel('Euclidean Distance (mm)')
    ylabel('Max Amplitude (Z)')
    %legend([a b], {'All Data', 'Stim Shafts'})
    legend off
    title(subjects{i})
end

print(fig,'/projects/b1134/analysis/ccyr/MATLAB_figures/AllData_ResponseAmpliudevsDistance_perSubject', ...
     '-dpng', '-r0')

