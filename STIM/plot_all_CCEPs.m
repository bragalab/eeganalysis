function plot_all_CCEPs(OUTPATH)
%% load EEG data
file = dir(sprintf('%s/*_ds_qcx_epoch_trialsx_bpref_z_flip.mat', OUTPATH)); %find preprocessed file
file.name(end-3:end) = []; %remove .mat
load(sprintf('%s/%s.mat', OUTPATH, file.name))

fileinfo = split(OUTPATH,'/');
SubjectID = fileinfo{end-4};
SessionID = fileinfo{end-3};    
TaskID = fileinfo{end-2};    
StimID = fileinfo{end-1}; 
CurrentID = fileinfo{end};  

%% find electrode shaft edges
edges = zeros(30,1);
last_shaft = '';
j = 1;
for i = 1:length(channel_IDs) %from the list of all electrode names
    if strcmp(channel_IDs{i, 1}(1),'s')
        current_shaft = 's';
    else    
        current_shaft = channel_IDs{i,1}(isletter(channel_IDs{i,1}));
    end    
    if ~strcmp(current_shaft, last_shaft)
        edges(j) = i;
        if strcmp(channel_IDs{i, 2}, 'G')
            for k = 1:str2double(channel_IDs{i, 4})-1
                j = j + 1;
                edges(j) = i + k*str2double(channel_IDs{i, 3});
            end
        end    
        j = j + 1;
    end
    last_shaft = current_shaft;
end

edges = nonzeros(edges);
edges = [edges;length(channel_IDs)];
edges(end) = edges(end)+1; %allows last channel of last shaft to be plotted

 %% Cleaned ERPs
numRows = 17;
numColumns = 20;
fig1 = figure;
fig1.Units = 'inches';
fig1.Position = [10.2083    4.8438   7.5  10.5];
fig1.PaperPosition = [10.2083    4.8438   7.5  10.5];
fig1.PaperPositionMode = 'manual';
t1 = tiledlayout(fig1,numRows,numColumns,'Padding','none',...
    'TileSpacing','none');

fig2 = figure;    
fig2.Units = 'inches';
fig2.Position = [10.2083    4.8438    7.5  10.5];
fig2.PaperPosition = [10.2083    4.8438   7.5  10.5];
fig2.PaperPositionMode = 'manual';   
t2 = tiledlayout(fig2,numRows,numColumns,'Padding','none',...
    'TileSpacing','none');

fig3 = figure;    
fig3.Units = 'inches';
fig3.Position = [10.2083    4.8438    7.5  10.5];
fig3.PaperPosition = [10.2083    4.8438   7.5  10.5];
fig3.PaperPositionMode = 'manual';
t3 = tiledlayout(fig3,numRows,numColumns,'Padding','none',...
    'TileSpacing','none');

fig4 = figure;    
fig4.Units = 'inches';
fig4.Position = [10.2083    4.8438    7.5  10.5];
fig4.PaperPosition = [10.2083    4.8438   7.5  10.5];
fig4.PaperPositionMode = 'manual';
t4 = tiledlayout(fig4,numRows,numColumns,'Padding','none',...
    'TileSpacing','none');

fig5 = figure;    
fig5.Units = 'inches';
fig5.Position = [10.2083    4.8438    7.5  10.5];
fig5.PaperPosition = [10.2083    4.8438   7.5  10.5];
fig5.PaperPositionMode = 'manual';
t5 = tiledlayout(fig5,numRows,numColumns,'Padding','none',...
    'TileSpacing','none');

fig6 = figure;    
fig6.Units = 'inches';
fig6.Position = [10.2083    4.8438    7.5  10.5];
fig6.PaperPosition = [10.2083    4.8438   7.5  10.5];
fig6.PaperPositionMode = 'manual';
t6 = tiledlayout(fig6,numRows,numColumns,'Padding','none',...
    'TileSpacing','none');    

currentfig = t1;
tile = 1;
moveon = 0;
firstcolumn = 1:+numColumns:numColumns*numRows+1;
secondcolumn = 6:+numColumns:numColumns*numRows+7;
thirdcolumn = 11:+numColumns:numColumns*numRows+13;
fourthcolumn = 16:+numColumns:numColumns*numRows+19;
    
time_x = -50:499; 
window_x = 450:999;
lowy = -5;
highy = 5;

for i = 1:length(edges)-1 % for each shaft
    for j = edges(i):edges(i+1)-1 %for each channel              

        %plot CCEP
        nexttile(currentfig, tile, [1 5]);
        hold on
        avg_waveform = mean(Z_flip(j,window_x,:), 3, 'omitnan');    
        upperSE = avg_waveform + ...
            std(Z_flip(j,window_x,:), 0, 3, 'omitnan')/sqrt(sum(~isnan(Z_flip(j,1,:))));
        lowerSE = avg_waveform - ...
            std(Z_flip(j,window_x,:), 0, 3, 'omitnan')/sqrt(sum(~isnan(Z_flip(j,1,:))));
        %plot standard error ribbon
        fill([time_x fliplr(time_x)], [upperSE fliplr(lowerSE)], [0.8 0.8 0.8]...
          , 'EdgeColor', 'none')

        %plot average signal
        plot(time_x, avg_waveform, 'k')
        xlim([time_x(1) time_x(end)])
        xticks([0 100 200 300 400])
        xticklabels({})
        ylim([lowy highy])
        yticks([-5 0 5])
        yticklabels({})
        text(time_x(1), 3, channel_IDs{j,1}, 'FontSize', 7);   
        box on
        tile = tile + numColumns;

    end

    if ismember(tile, firstcolumn)
        tile = 6; %move to second column
    elseif ismember(tile, secondcolumn)          
        tile = 11;     %move to second 
    elseif ismember(tile, thirdcolumn)           
        tile = 16;  %move to third column
    elseif ismember(tile, fourthcolumn)           
        tile = 1;  %move to next page
        if moveon == 0
            moveon = 1;
            currentfig = t2;
        elseif moveon == 1
            moveon = 2;
            currentfig = t3;
        elseif moveon == 2
            currentfig = t4; 
            moveon = 3;
        elseif moveon == 3
            currentfig = t5;  
            moveon = 4;
        elseif moveon == 4
            currentfig = t6;                 
        end
    end 
end        

sgtitle(fig1, sprintf('%s - %s - %s - %s - %s', SubjectID, SessionID, TaskID, StimID, CurrentID), 'Interpreter', 'none')
sgtitle(fig2, sprintf('%s - %s - %s - %s - %s', SubjectID, SessionID, TaskID, StimID, CurrentID), 'Interpreter', 'none')
sgtitle(fig3, sprintf('%s - %s - %s - %s - %s', SubjectID, SessionID, TaskID, StimID, CurrentID), 'Interpreter', 'none')
sgtitle(fig4, sprintf('%s - %s - %s - %s - %s', SubjectID, SessionID, TaskID, StimID, CurrentID), 'Interpreter', 'none')    
sgtitle(fig5, sprintf('%s - %s - %s - %s - %s', SubjectID, SessionID, TaskID, StimID, CurrentID), 'Interpreter', 'none')    
sgtitle(fig6, sprintf('%s - %s - %s - %s - %s', SubjectID, SessionID, TaskID, StimID, CurrentID), 'Interpreter', 'none')   

%% save data  
print(fig1,sprintf('%s/CCEPs1', OUTPATH), '-dpng', '-r300')
print(fig2,sprintf('%s/CCEPs2', OUTPATH), '-dpng', '-r300')
print(fig3,sprintf('%s/CCEPs3', OUTPATH), '-dpng', '-r300')
print(fig4,sprintf('%s/CCEPs4', OUTPATH), '-dpng', '-r300')
print(fig5,sprintf('%s/CCEPs5', OUTPATH), '-dpng', '-r300')    
print(fig6,sprintf('%s/CCEPs6', OUTPATH), '-dpng', '-r300')    
close all

end
