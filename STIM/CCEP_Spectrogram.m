function CCEP_Spectrogram(datapath)
addpath('/projects/b1134/tools/eeganalysis/STIM')

%% load data 
ResponseMetrics = CCEP_responsemetrics(datapath);
ResponseMetrics = struct2table(ResponseMetrics);
Folderinfo = split(datapath,'/');
SubjectID = Folderinfo{end-4};
SessionID = Folderinfo{end-3};
TaskID = Folderinfo{end-2};
StimSite = Folderinfo{end-1};
CurrentIntensity = Folderinfo{end};
%network_colors = [0 0 0; 187 55 56; 254 147 134; 160 227 255; 64 130 163;...
%    202 225 160; 11 119 60; 121 86 163; 253 222 113; 250 130 180];
networks = {'DN-A','DN-B','FPN-A','CG-OP','LANG','UNI'};

%% Determine Network Identity
ResponseMetrics.NetworkIdentity = cell(height(ResponseMetrics),1);
for i = 1:height(ResponseMetrics)
    if sum(ResponseMetrics{i,[6:8,12:14] } > 0.10) > 0
        [~, idx] = max(ResponseMetrics{i,[6:8,12:14]});
        ResponseMetrics.NetworkIdentity(i) = networks(idx);
    else
        ResponseMetrics.NetworkIdentity(i) = {'None'};
    end
end
ResponseMetrics = ResponseMetrics(~matches(ResponseMetrics.NetworkIdentity,'None'),:);
sortindex = [find(matches(ResponseMetrics.NetworkIdentity,'DN-A'));...
    find(matches(ResponseMetrics.NetworkIdentity,'DN-B'));...
    find(matches(ResponseMetrics.NetworkIdentity,'LANG'));...
    find(matches(ResponseMetrics.NetworkIdentity,'FPN-A'));...
    find(matches(ResponseMetrics.NetworkIdentity,'CG-OP'));...
    find(matches(ResponseMetrics.NetworkIdentity,'UNI'))];
ResponseMetrics = ResponseMetrics(sortindex,:);

%% determine ticks between networks
ticks = 1;
for i = 1:height(ResponseMetrics)-1
    if ~strcmp(ResponseMetrics.NetworkIdentity{i}, ResponseMetrics.NetworkIdentity{i+1})
        ticks = [ticks; i];
    end
end

%% plot data
fig = figure;
fig.Units = 'inches';
fig.Position = [1 1 1.75 2.5];

imagesc(ResponseMetrics.Response_Waveform)
ax=gca;
yticks(ticks)
yticklabels('')
y = ylabel('Response Sites','Units','inches','FontSize',10);

xlim([0 1000])
xticks([1 500 1000])
xticklabels({'-500', '0', '500'})
x = xlabel('Time (ms)','Units','inches','FontSize',10);

cb = colorbar;
cb_y = ylabel(cb, 'Amplitude (Z)', 'Rotation', 270, 'VerticalAlignment', 'bottom','FontSize',10);
caxis([-2 2])
set(gca, 'FontSize', 10)
set(ax,'LineWidth',1.5,'TickLength',[0.025 0.025]);
cb.Position = [0.78 0.16 0.03 0.8];
cb_y.Position = [4 0 0];
ax.Position = [0.2 0.16 0.53 0.8];
x.Position = [0.5 -0.2 0];
y.Position = [-0.2 1 0];

outfile = sprintf('/projects/b1134/analysis/ccyr/MATLAB_figures/%s_%s_%s_%s_%s_CCEPspectrogram', ...
    SubjectID, SessionID, TaskID, StimSite, CurrentIntensity);
print(fig, outfile,'-dpng','-r600');


end