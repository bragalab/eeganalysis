#load packages
if(!require("readxl")) {install.packages("readxl"); require("readxl")}
if(!require("stringr")) {install.packages("stringr"); require("stringr")}
if(!require("ggplot2")) {install.packages("ggplot2"); require("ggplot2")}
if(!require("ggdist")) {install.packages("ggdist"); require("ggdist")}
if(!require("ggpubr")) {install.packages("ggpubr"); require("ggpubr")}
if(!require("gridExtra")) {install.packages("gridExtra"); require("gridExtra")}
if(!require("tidyverse")) {install.packages("tidyverse"); require("tidyverse")}
if(!require("openxlsx")) {install.packages("openxlsx"); require("openxlsx")}
if(!require("lme4")) {install.packages("lme4"); require("lme4")}
if(!require("ggtext")) {install.packages("ggtext"); require("ggtext")}  
if(!require("gghalves")) {install.packages("gghalves"); require("gghalves")}
if(!require("hash")) {install.packages("hash"); require("hash")}
if(!require("RColorBrewer")) {install.packages("RColorBrewer"); require("RColorBrewer")}
if(!require("grid")) {install.packages("grid"); require("grid")}
if(!require("pracma")) {install.packages("pracma"); require("pracma")}
if(!require("dplyr")) {install.packages("dplyr"); require("dplyr")}
if(!require("reshape")) {install.packages("reshape"); require("reshape")}
if(!require("DescTools")) {install.packages("DescTools"); require("DescTools")}
source('/Users/cce3182/Desktop/b1134/tools/eeganalysis/STIM/CCEP_LoadData_MSHBM.R')
source('/Users/cce3182/Desktop/b1134/tools/eeganalysis/STIM/CCEP_CaseList_MSHBM.R')
source('/Users/cce3182/Desktop/b1134/tools/eeganalysis/STIM/CCEP_SiteList_MSHBM.R')
source('/Users/cce3182/Desktop/b1134/tools/eeganalysis/STIM/CCEP_BuildTable_MSHBM.R')
source('/Users/cce3182/Desktop/b1134/tools/eeganalysis/FUNC_MAPPING/FunctionalMapping_LoadData.R')
source('/Users/cce3182/Desktop/b1134/tools/eeganalysis/FUNC_MAPPING/FunctionalMapping_Summary.R')
source('/Users/cce3182/Desktop/b1134/tools/eeganalysis/FUNC_MAPPING/FunctionalMapping_BuildTable_MSHBM.R')
############################################## load functional mapping data
InfoTable <- FunctionalMapping_LoadData()
SiteSummary <- FunctionalMapping_Summary(InfoTable)
FM_Data <- FunctionalMapping_BuildTable_MSHBM(SiteSummary)

################## Plot FM Stim Site Network Coverage
Plot_info <- FM_Data[FM_Data$StimulationResult != 'Not Stimulated' & !FM_Data$TissueType %in% c('Subcortical','Out of Brain'),] %>%
  group_by(Network) %>% count()
Plot_info$Network <- factor(Plot_info$Network,levels=c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG',
                                                       'CONA','CONB','SMOTA','SMOTB','SMOTC','AUD','VISP','Unknown'))
Plot_info <- Plot_info[order(Plot_info$Network),]
Plot_info <- rbind(data.frame(Network = c('N_Sub'), n = c(length(unique(FM_Data$SubjectID)))),
                   data.frame(Network = c('N_Sites'), n = c(dim(FM_Data[FM_Data$StimulationResult != 'Not Stimulated' & !FM_Data$TissueType %in% c('Subcortical','Out of Brain'),])[1])),
                   Plot_info)
t1 <- tableGrob(t(Plot_info)[,c(1:8)],rows = NULL, theme = ttheme_default(base_size=12))
t2 <- tableGrob(t(Plot_info)[,c(9:17)],rows = NULL, theme = ttheme_default(base_size=12))
Plot_info <- FM_Data[FM_Data$StimulationResult != 'Not Stimulated' & !FM_Data$TissueType %in% c('Subcortical','Out of Brain'),]
Plot_info <- pivot_longer(Plot_info,
                          cols=c('DisttoDNA','DisttoDNB','DisttoFPN','DisttodATNA',
                                 'DisttodATNB','DisttoSALPMN','DisttoLANG','DisttoCONA',
                                 'DisttoCONB','DisttoSMOTA','DisttoSMOTB','DisttoSMOTC',
                                 'DisttoAUD','DisttoVISP'),
                          names_pattern = "Distto(.*)",
                          names_to = 'name', values_to = 'Distance')
Plot_info$name <- factor(Plot_info$name, levels=c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG',
                                                  'CONA','CONB','SMOTA','SMOTB','SMOTC','AUD','VISP'))
g <- ggplotGrob(ggplot(Plot_info, aes(x=as.numeric(Distance), fill = name)) +
                  geom_histogram(bins=21,position='identity', show.legend = FALSE)  +
                  scale_fill_manual(values=c(rgb(187,55,56,maxColorValue=255),rgb(254,147,134,maxColorValue=255),rgb(64,130,163,maxColorValue=255),
                                             rgb(202,225,160,maxColorValue=255),rgb(11,119,60,maxColorValue=255),rgb(36,56,118,maxColorValue=255),
                                             rgb(253,222,113,maxColorValue=255),rgb(121,86,163,maxColorValue=255),rgb(250,0,250,maxColorValue=255),
                                             rgb(250,130,180,maxColorValue=255),rgb(167,87,120,maxColorValue=255),rgb(83,43,60,maxColorValue=255),
                                             rgb(255,250,208,maxColorValue=255),rgb(253,213,230,maxColorValue=255))) +
                  scale_x_continuous(breaks=c(5,10,15,20),labels=c('5','10','15','20')) +
                  scale_y_continuous(limits=c(0,125)) +
                  facet_wrap(~name, nrow=3) +
                  labs(y = '# of Sites', x = 'Distance to Network (mm)') +
                  theme_bw() +
                  theme(text = element_text(size=12)))

f <- grid.arrange(t1,t2,g,nrow = 3,top = 'HFS Stimulation Sites',
                  heights=c(0.75,0.75,9))  
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/HFS_Stim_NetworkCoverage_MSHBM.png',
       plot = f,width = 7.5,height = 10.5,units = 'in', dpi = 300)
############################################## load CCEP stim site data
AverageInfo_Table <- CCEP_LoadData_MSHBM()
#determine outcome of stimulation for each stimulation case
case_list <- unique(AverageInfo_Table[,c(1,2,3,5,6)])
case_list$Targeted_network <- NA
for (i in 1:dim(case_list)[1]){
  ### determine result using individual parcellations
  #isolate CCEPs for a given stim case
  current_indices <- AverageInfo_Table$SubjectID==case_list$SubjectID[i] & 
    AverageInfo_Table$StimSite==case_list$StimSite[i] &
    AverageInfo_Table$CurrentIntensity==case_list$CurrentIntensity[i]
  
  current_data <- AverageInfo_Table[current_indices,]
  case_list$Targeted_network[i] <- unique(as.character(current_data$Stim_Network))
}
site_list <- unique(case_list[,c('SubjectID','StimSite','StimSiteType','Targeted_network')])
sub_list <- unique(site_list$SubjectID)
All_info <- data.frame(SubjectID=character(),Session=character(),ChannelID=character(),Coords_x=double(),Coords_y=double(),Coords_z=double(),
                       CoordsBipol_1_x=double(),CoordsBipol_1_y=double(),CoordsBipol_1_z=double(),CoordsBipol_2_x=double(),
                       CoordsBipol_2_y=double(),CoordsBipol_2_z=double(),InterElectrodeDistance=double(),DisttoWMBoundary=double(),Orientation=double(),
                       TissueType=character(),BrainRegion=character(), DisttoDNANetwork=double(), DisttoDNBNetwork=double(),
                       DisttoFPNA=double(), DisttoFPNB=double(), DisttodATNA=double(), DisttodATNB=double(),
                       DisttoSAL=double(), DisttoLANG=double(), DisttoUNI=double())
for (SubjectID in sub_list){ 
  elec_recon_dir <- paste0('/Users/cce3182/Desktop/b1134/processed/fs/',SubjectID,'/',SubjectID, '/elec_recon')
  Electrode_info <- read_excel(paste0(elec_recon_dir,'/',SubjectID,'_','SiteInfoTable_bipolar_appended_MSHBM.xlsx'))
  Electrode_info$SubjectID <- SubjectID
  All_info <- rbind(All_info, Electrode_info)
}
Electrode_info <- All_info
rm(All_info)

#add information about stimulation results
Electrode_info$Network <- NA
Electrode_info$StimulationResult <- NA
for (i in 1:dim(Electrode_info)[1]){
  #find stim site within all electrode info table
  MirroredChannelID <- paste0(unlist(str_split(Electrode_info$ChannelID[i],'-'))[2],'-',unlist(str_split(Electrode_info$ChannelID[i],'-'))[1])
  index <- (site_list$StimSite==Electrode_info$ChannelID[i] | site_list$StimSite==MirroredChannelID)  & 
    site_list$SubjectID==Electrode_info$SubjectID[i]
  
  #add additional stim site info to all electrode table
  if (sum(index) == 1){ #stimulated
    Electrode_info$Network[i] <- site_list$Targeted_network[index]
    Electrode_info$StimulationResult[i] <- 'Stimulated'
  } else {
    Electrode_info$StimulationResult[i] <- 'Not Stimulated'
  }
}
Electrode_info <- Electrode_info[,!colnames(Electrode_info) %in% c("Coords_x","Coords_y","Coords_z",
                                                                   "CoordsBipol_1_x","CoordsBipol_1_y","CoordsBipol_1_z","CoordsBipol_2_x",
                                                                   "CoordsBipol_2_y","CoordsBipol_2_z","InterElectrodeDistance","Orientation")]
CCEP_Data <- Electrode_info
rm(Electrode_info)
################## Plot SPES Stim Site Network Coverage
Plot_info <- CCEP_Data[CCEP_Data$StimulationResult != 'Not Stimulated' & !CCEP_Data$TissueType %in% c('Subcortical','Out of Brain'),]
Plot_info$Network <- factor(Plot_info$Network,levels=c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG',
                                                       'CONA','CONB','SMOTA','SMOTB','SMOTC','AUD','VISP','Unknown'))
Plot_info <- Plot_info %>%
  group_by(Network) %>%
  summarise(n=n(), .groups = 'drop') %>% 
  complete(Network, fill = list(n = 0))

Plot_info <- Plot_info[order(Plot_info$Network),]
Plot_info <- rbind(data.frame(Network = c('N_Sub'), n = c(length(unique(CCEP_Data$SubjectID)))),
                   data.frame(Network = c('N_Sites'), n = c(dim(CCEP_Data[CCEP_Data$StimulationResult != 'Not Stimulated' & !CCEP_Data$TissueType %in% c('Subcortical','Out of Brain'),])[1])),
                   Plot_info)
t1 <- tableGrob(t(Plot_info)[,c(1:8)],rows = NULL, theme = ttheme_default(base_size=12))
t2 <- tableGrob(t(Plot_info)[,c(9:17)],rows = NULL, theme = ttheme_default(base_size=12))

Plot_info <- CCEP_Data[CCEP_Data$StimulationResult != 'Not Stimulated' & !CCEP_Data$TissueType %in% c('Subcortical','Out of Brain'),]
Plot_info <- pivot_longer(Plot_info,
                          cols=c('DisttoDNA','DisttoDNB','DisttoFPN','DisttodATNA',
                                 'DisttodATNB','DisttoSALPMN','DisttoLANG','DisttoCONA',
                                 'DisttoCONB','DisttoSMOTA','DisttoSMOTB','DisttoSMOTC',
                                 'DisttoAUD','DisttoVISP'),
                          names_pattern = "Distto(.*)",
                          names_to = 'name', values_to = 'Distance')
Plot_info$name <- factor(Plot_info$name, levels=c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG',
                                                  'CONA','CONB','SMOTA','SMOTB','SMOTC','AUD','VISP'))
g <- ggplotGrob(ggplot(Plot_info, aes(x=as.numeric(Distance), fill = name)) +
                  geom_histogram(bins=21,position='identity', show.legend = FALSE)  +
                  scale_fill_manual(values=c(rgb(187,55,56,maxColorValue=255),rgb(254,147,134,maxColorValue=255),rgb(64,130,163,maxColorValue=255),
                                             rgb(202,225,160,maxColorValue=255),rgb(11,119,60,maxColorValue=255),rgb(36,56,118,maxColorValue=255),
                                             rgb(253,222,113,maxColorValue=255),rgb(121,86,163,maxColorValue=255),rgb(250,0,250,maxColorValue=255),
                                             rgb(250,130,180,maxColorValue=255),rgb(167,87,120,maxColorValue=255),rgb(83,43,60,maxColorValue=255),
                                             rgb(255,250,208,maxColorValue=255),rgb(253,213,230,maxColorValue=255))) +
                  scale_x_continuous(breaks=c(5,10,15,20),labels=c('5','10','15','20')) +
                  scale_y_continuous(limits=c(0,125)) +
                  facet_wrap(~name, nrow=3) +
                  labs(y = '# of Sites', x = 'Distance to Network (mm)') +
                  theme_bw() +
                  theme(text = element_text(size=12)))

f <- grid.arrange(t1,t2,g,nrow = 3,top = 'SPES Stimulation Sites',
                  heights=c(0.75,0.75,9))  
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/SPES_Stim_NetworkCoverage_MSHBM.png',
       plot = f,width = 7.5,height = 10.5,units = 'in', dpi = 300)
############################################## load CCEP response site data
#determine outcome of stimulation for each stimulation case
site_list <- unique(AverageInfo_Table[,c(1,4,44)])
sub_list <- unique(site_list$SubjectID)
All_info <- data.frame(SubjectID=character(),Session=character(),ChannelID=character(),Coords_x=double(),Coords_y=double(),Coords_z=double(),
                       CoordsBipol_1_x=double(),CoordsBipol_1_y=double(),CoordsBipol_1_z=double(),CoordsBipol_2_x=double(),
                       CoordsBipol_2_y=double(),CoordsBipol_2_z=double(),InterElectrodeDistance=double(),DisttoWMBoundary=double(),Orientation=double(),
                       TissueType=character(),BrainRegion=character(), DisttoDNANetwork=double(), DisttoDNBNetwork=double(),
                       DisttoFPNA=double(), DisttoFPNB=double(), DisttodATNA=double(), DisttodATNB=double(),
                       DisttoSAL=double(), DisttoLANG=double(), DisttoUNI=double())
for (SubjectID in sub_list){ 
  elec_recon_dir <- paste0('/Users/cce3182/Desktop/b1134/processed/fs/',SubjectID,'/',SubjectID, '/elec_recon')
  Electrode_info <- read_excel(paste0(elec_recon_dir,'/',SubjectID,'_','SiteInfoTable_bipolar_appended_MSHBM.xlsx'))
  Electrode_info$SubjectID <- SubjectID
  All_info <- rbind(All_info, Electrode_info)
}
Electrode_info <- All_info
rm(All_info)

#add information about stimulation results
Electrode_info$Network <- NA
Electrode_info$RecordingResult <- NA
for (i in 1:dim(Electrode_info)[1]){
  #find stim site within all electrode info table
  MirroredChannelID <- paste0(unlist(str_split(Electrode_info$ChannelID[i],'-'))[2],'-',unlist(str_split(Electrode_info$ChannelID[i],'-'))[1])
  index <- (site_list$ChannelID==Electrode_info$ChannelID[i] | site_list$ChannelID==MirroredChannelID)  & 
    site_list$SubjectID==Electrode_info$SubjectID[i]
  
  #add additional stim site info to all electrode table
  if (sum(index) == 1){ #stimulated
    Electrode_info$Network[i] <- site_list$Response_Network[index]
    Electrode_info$RecordingResult[i] <- 'Recorded'
  } else {
    Electrode_info$RecordingResult[i] <- 'Not Recorded'
  }
}
Electrode_info <- Electrode_info[,!colnames(Electrode_info) %in% c("Coords_x","Coords_y","Coords_z",
                                                                   "CoordsBipol_1_x","CoordsBipol_1_y","CoordsBipol_1_z","CoordsBipol_2_x",
                                                                   "CoordsBipol_2_y","CoordsBipol_2_z","InterElectrodeDistance","Orientation")]
CCEP_Data <- Electrode_info
rm(Electrode_info)
################## Plot SPES Response Site Network Coverage
Plot_info <- CCEP_Data[CCEP_Data$RecordingResult != 'Not Recorded' & !CCEP_Data$TissueType %in% c('Subcortical','Out of Brain'),]
Plot_info$Network <- factor(Plot_info$Network,levels=c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG',
                                                       'CONA','CONB','SMOTA','SMOTB','SMOTC','AUD','VISP','Unknown'))
Plot_info <- Plot_info %>%
  group_by(Network) %>%
  summarise(n=n(), .groups = 'drop') %>% 
  complete(Network, fill = list(n = 0))
Plot_info <- Plot_info[order(Plot_info$Network),]
Plot_info <- rbind(data.frame(Network = c('N_Sub'), n = c(length(unique(CCEP_Data$SubjectID)))),
                   data.frame(Network = c('N_Sites'), n = c(dim(CCEP_Data[CCEP_Data$RecordingResult != 'Not Recorded' & !CCEP_Data$TissueType %in% c('Subcortical','Out of Brain'),])[1])),
                   Plot_info)
t1 <- tableGrob(t(Plot_info)[,c(1:8)],rows = NULL, theme = ttheme_default(base_size=12))
t2 <- tableGrob(t(Plot_info)[,c(9:17)],rows = NULL, theme = ttheme_default(base_size=12))

Plot_info <- CCEP_Data[CCEP_Data$RecordingResult != 'Not Recorded' & !CCEP_Data$TissueType %in% c('Subcortical','Out of Brain'),]
Plot_info <- pivot_longer(Plot_info,
                          cols=c('DisttoDNA','DisttoDNB','DisttoFPN','DisttodATNA',
                                 'DisttodATNB','DisttoSALPMN','DisttoLANG','DisttoCONA',
                                 'DisttoCONB','DisttoSMOTA','DisttoSMOTB','DisttoSMOTC',
                                 'DisttoAUD','DisttoVISP'),
                          names_pattern = "Distto(.*)",
                          names_to = 'name', values_to = 'Distance')
Plot_info$name <- factor(Plot_info$name, levels=c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG',
                                                  'CONA','CONB','SMOTA','SMOTB','SMOTC','AUD','VISP'))
g <- ggplotGrob(ggplot(Plot_info, aes(x=as.numeric(Distance), fill = name)) +
                  geom_histogram(bins=21,position='identity', show.legend = FALSE)  +
                  scale_fill_manual(values=c(rgb(187,55,56,maxColorValue=255),rgb(254,147,134,maxColorValue=255),rgb(64,130,163,maxColorValue=255),
                                             rgb(202,225,160,maxColorValue=255),rgb(11,119,60,maxColorValue=255),rgb(36,56,118,maxColorValue=255),
                                             rgb(253,222,113,maxColorValue=255),rgb(121,86,163,maxColorValue=255),rgb(250,0,250,maxColorValue=255),
                                             rgb(250,130,180,maxColorValue=255),rgb(167,87,120,maxColorValue=255),rgb(83,43,60,maxColorValue=255),
                                             rgb(255,250,208,maxColorValue=255),rgb(253,213,230,maxColorValue=255))) +
                  scale_x_continuous(breaks=c(5,10,15,20),labels=c('5','10','15','20')) +
                  scale_y_continuous(limits=c(0,125)) +
                  facet_wrap(~name, nrow=3) +
                  labs(y = '# of Sites', x = 'Distance to Network (mm)') +
                  theme_bw() +
                  theme(text = element_text(size=12)))

f <- grid.arrange(t1,t2,g,nrow = 3,top = 'SPES Recording Sites',
                  heights=c(0.75,0.75,9))  
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/SPES_Recording_NetworkCoverage_MSHBM.png',
       plot = f,width = 7.5,height = 10.5,units = 'in', dpi = 300)

