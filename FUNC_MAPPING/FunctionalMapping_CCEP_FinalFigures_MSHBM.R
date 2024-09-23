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

############################################## load CCEP data
AverageInfo_Table <- CCEP_LoadData_MSHBM()
AverageInfo_Table <- AverageInfo_Table[AverageInfo_Table$Response_Network != 'Unknown',]
structure <- CCEP_CaseList_MSHBM(AverageInfo_Table)
AverageInfo_Table <- structure$AverageInfo_Table
case_list <- structure$case_list
rm(structure)
site_list <- CCEP_SiteList_MSHBM(case_list)
CCEP_Data <- CCEP_BuildTable_MSHBM(site_list)

############################## Figure 2
Plot_info <- CCEP_Data[!CCEP_Data$BrainRegion %in% c('MedialTemporalCortex') &
                       !CCEP_Data$TissueType %in% c('Subcortical') &
                         !(CCEP_Data$AmpResult %in% c("Miss + Nonspecific",'No In-Network Coverage',
                                                      "Hit + Nonspecific","Hit + Specific","Miss + Specific" ,  
                                                      "No Effect") & 
                             CCEP_Data$TissueType %in% c('Out of Brain')),]
Plot_info$AmpResult[Plot_info$Stimulated_networks_n == 0] <- 'No Activity'
Plot_info$AmpResult[Plot_info$Stimulated_networks_n > 0] <- 'Evoked Activity'
stats <- t.test(Plot_info$DisttoWMBoundary[Plot_info$AmpResult=='No Activity'], 
                Plot_info$DisttoWMBoundary[Plot_info$AmpResult=='Evoked Activity'],alternative='greater')
Plot_info$AmpResult <- factor(Plot_info$AmpResult, levels=c('Not Stimulated','No Activity','Evoked Activity'))
p1 <- ggplotGrob(ggplot(data = Plot_info, aes(x=as.numeric(AmpResult),y=DisttoWMBoundary, color = AmpResult)) +
                   annotate('rect',xmin=-Inf,xmax=Inf,ymin=0,ymax=Inf, fill='gray',alpha=0.5) +
                   geom_hline(yintercept = 0, linewidth=0.25) +
                   stat_halfeye(aes(fill=AmpResult, scale=0.5), .width=0, adjust=0.5, alpha = 0.5, normalize = 'all', show.legend = FALSE) +
                   geom_boxplot(width=0.2, outlier.shape = NA, show.legend = FALSE) +
                   gghalves::geom_half_point(side='l', alpha=0.5, size=1, transformation=position_jitter(width=0.05,height=0),show.legend = FALSE) +
                   geom_bracket( xmin = c(2), xmax = c(3), y.position = c(5) ,label.size = 4, label = 'p < 0.001',
                                 inherit.aes = FALSE, tip.length = c(0.02)) +
                   scale_y_continuous(limits=c(-13,11), breaks=seq(-12,10,by=2)) +
                   scale_x_continuous(limits=c(0.5,4), breaks=c(1:3), labels=c('Not Stimulated','No Activity','Evoked Activity')) +
                   coord_cartesian(xlim=c(0.5,3.5)) + 
                   scale_color_manual(values=c( "#E41A1C" ,"#377EB8", "#4DAF4A")) +
                   scale_fill_manual(values=c( "#E41A1C", "#377EB8", "#4DAF4A")) +
                   theme_bw() +
                   labs(y = 'White Matter Displacement (mm)') + ggtitle('Single Pulse Electrical Stimulation') +
                   theme(panel.grid.major.x = element_blank(),axis.title.x=element_blank(),
                         panel.grid.major.y = element_blank(),axis.text.x = element_text(angle = 0, vjust = 1, hjust=0.5),
                         panel.grid.minor = element_blank(),axis.title.y = element_text(vjust = 1, hjust = 0.95),
                         axis.ticks.x=element_blank(),plot.title = element_text(hjust = 0.5,size=12),
                         text = element_text(size=12)))

Plot_info <- FM_Data[!FM_Data$BrainRegion %in% c('MedialTemporalCortex') &
                       !FM_Data$TissueType %in% c('Subcortical') &
                       !(FM_Data$StimulationResult %in% c('No Effects','Behavioral Effects') &
                           FM_Data$TissueType %in% c('Out of Brain')) &
                       !FM_Data$StimulationResult %in% c('Inconclusive'),]
Plot_info$StimulationResult <- factor(as.character(Plot_info$StimulationResult), levels=c('Not Stimulated', 'No Effects', 'Behavioral Effects')) 
stats <- list(t.test(Plot_info$DisttoWMBoundary[Plot_info$StimulationResult=='No Effects'],
                     Plot_info$DisttoWMBoundary[Plot_info$StimulationResult=='Behavioral Effects'],alternative='greater'))
p2 <- ggplotGrob(ggplot(data = Plot_info, aes(x=as.numeric(StimulationResult),y=DisttoWMBoundary, color = StimulationResult)) +
                   annotate('rect',xmin=-Inf,xmax=Inf,ymin=0,ymax=Inf, fill='gray',alpha=0.5) +
                   geom_hline(yintercept = 0, linewidth=0.25) +
                   stat_halfeye(aes(fill=StimulationResult, scale=0.5), .width=0, adjust=0.5, alpha = 0.5, normalize = 'all', show.legend = FALSE) +
                   geom_boxplot(width=0.2, outlier.shape = NA, show.legend = FALSE) +
                   gghalves::geom_half_point(side='l', alpha=0.5, size=1, transformation=position_jitter(width=0.05,height=0),show.legend = FALSE) +
                   geom_bracket( xmin = c(2), xmax = c(3), y.position = c(5) ,label.size = 4, label = 'p = 0.003',
                                 inherit.aes = FALSE, tip.length = c(0.02)) +
                   scale_y_continuous(limits=c(-13,11), breaks=seq(-12,10,by=2)) +
                   scale_x_continuous(limits=c(0.5,4), breaks=c(1:3), labels=c('Not Stimulated','No Effects','Behavioral Effects')) +
                   coord_cartesian(xlim=c(0.5,3.5)) + 
                   scale_color_manual(values=c( "#E41A1C" ,"#377EB8", "#4DAF4A")) +
                   scale_fill_manual(values=c( "#E41A1C", "#377EB8", "#4DAF4A")) +
                   theme_bw() +
                   labs(y = 'White Matter Displacement (mm)') + ggtitle('50 Hz Electrical Stimulation') + 
                   theme(panel.grid.major.x = element_blank(),axis.title.x=element_blank(),
                         panel.grid.major.y = element_blank(),axis.text.x = element_text(angle = 0, vjust = 1, hjust=0.5),
                         panel.grid.minor = element_blank(),axis.title.y = element_text(vjust = 1, hjust = 0.95),
                         axis.ticks.x=element_blank(),plot.title = element_text(hjust = 0.5,size=12),
                         text = element_text(size=12)))
g <- grid.arrange(p1,p2,nrow=1, widths=c(3.75,3.75))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_2.png',
       plot = g,width = 7.5,height = 3,units = 'in', dpi = 300)

############################## Figure 3
Plot_info <- CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                         !CCEP_Data$BrainRegion %in% c('MedialTemporalCortex') &
                         !CCEP_Data$AmpResult %in% c('Not Stimulated','No Effect') &
                         !CCEP_Data$Targeted_network %in% c('Unknown'),]
Plot_info$AmpResult[Plot_info$Stimulated_networks_n == 1] <- 'Specific'
Plot_info$AmpResult[Plot_info$Stimulated_networks_n > 1] <- 'Nonspecific'
Plot_info$AmpResult <- factor(Plot_info$AmpResult, levels = c('Specific','Nonspecific'))
stats <- t.test(Plot_info$DisttoWMBoundary[Plot_info$AmpResult=='Specific'], 
                Plot_info$DisttoWMBoundary[Plot_info$AmpResult=='Nonspecific'],alternative='greater', var.equal=FALSE)
p1 <- ggplotGrob(ggplot(data = Plot_info, aes(x=as.numeric(AmpResult),y=DisttoWMBoundary, color = AmpResult)) +
                   annotate('rect',xmin=-Inf,xmax=Inf,ymin=0,ymax=Inf, fill='gray',alpha=0.5) +
                   geom_hline(yintercept = 0, linewidth=0.25) +
                   stat_halfeye(aes(fill=AmpResult, scale=0.5), .width=0, adjust=0.5, alpha = 0.5, normalize = 'all', show.legend = FALSE) +
                   geom_boxplot(width=0.2, outlier.shape = NA, show.legend = FALSE) +
                   gghalves::geom_half_point(side='l', alpha=0.5, size=1, transformation=position_jitter(width=0.05,height=0),show.legend = FALSE) +
                   geom_bracket( xmin = c(1), xmax = c(2), y.position = c(4.5) ,label.size = 4, label = 'p = 0.042',
                                 inherit.aes = FALSE, tip.length = c(0.02)) +
                   scale_y_continuous(limits=c(-4,5), breaks=seq(-4,5,by=2)) +
                   scale_x_continuous(limits=c(0.5,3), breaks=c(1:2), labels=c('Specific','Nonspecific')) +
                   coord_cartesian(xlim=c(0.5,2.5)) + 
                   theme_bw() +
                   labs(y = 'White Matter Displacement (mm)') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(),
                         panel.grid.minor = element_blank(),axis.title.x=element_blank(),
                         axis.ticks.x=element_blank(),
                         text = element_text(size=12)))

Plot_info <- CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                        !CCEP_Data$BrainRegion %in% c('MedialTemporalCortex') &
                        !CCEP_Data$AmpResult %in% c('No In-Network Coverage','No Effect') &
                        !CCEP_Data$Targeted_network %in% c('Unknown'),]
Plot_info$AmpResult[Plot_info$AmpResult %in% c('Hit + Specific','Hit + Nonspecific')] <- 'Hit'
Plot_info$AmpResult[Plot_info$AmpResult %in% c('Miss + Specific','Miss + Nonspecific')] <- 'Miss'
Plot_info$AmpResult <- factor(Plot_info$AmpResult, levels = c('Not Stimulated','Hit','Miss'))
stats <- t.test(Plot_info$NearNetworks[Plot_info$AmpResult=='Miss'], 
                Plot_info$NearNetworks[Plot_info$AmpResult=='Hit'],alternative='greater', var.equal=FALSE)
p2 <- ggplotGrob(ggplot(data = Plot_info, aes(x=as.numeric(AmpResult),y=NearNetworks, color = AmpResult)) +
                   stat_halfeye(aes(fill=AmpResult, scale=0.5), .width=0, adjust=0.5, alpha = 0.5, normalize = 'all', show.legend = FALSE) +
                   geom_boxplot(width=0.2, outlier.shape = NA, show.legend = FALSE) +
                   gghalves::geom_half_point(side='l', alpha=0.5, size=1, transformation=position_jitter(width=0.1,height=0),show.legend = FALSE) +
                   geom_bracket( xmin = c(2), xmax = c(3), y.position = c(10) ,label.size = 4, label = 'p = 0.1256',
                                 inherit.aes = FALSE, tip.length = c(0.02)) +
                   scale_y_continuous(limits=c(0,12), breaks=c(0:12)) +
                   scale_x_continuous(limits=c(0.5,4), breaks=c(1:3), labels=c('Not Stimulated','Hit','Miss')) +
                   scale_color_manual(values=c( '#595959','#F8766D','#00BFC4')) +
                   scale_fill_manual(values=c( '#595959','#F8766D','#00BFC4')) +
                   coord_cartesian(xlim=c(0.5,3.5)) + 
                   theme_bw() +
                   labs(y = '# of Nearby Networks') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(),
                         panel.grid.minor = element_blank(),
                         axis.ticks.x=element_blank(),axis.title.x=element_blank(),
                         text = element_text(size=12)))
g <- grid.arrange(p1,p2,nrow=1, bottom=textGrob('Evoked Activity Pattern'), widths=c(2,3))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_3bc.png',
       plot = g,width = 5,height = 3,units = 'in', dpi = 300)

Plot_info <- CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                         !CCEP_Data$BrainRegion %in% c('MedialTemporalCortex') &
                         !CCEP_Data$AmpResult %in% c('Not Stimulated','No In-Network Coverage','No Effect') &
                         !CCEP_Data$Targeted_network %in% c('Unknown'),]
Data_Table <- array(data=0, dim = c(13,13))
colnames(Data_Table) <- c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG','CONA','CONB','PMPPR','AUD','VIS','SMOT')
rownames(Data_Table) <- c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG','CONA','CONB','PMPPR','AUD','VIS','SMOT')
for (i in c(1:dim(Plot_info)[1])){
  row_index <- Plot_info$Targeted_network[i]
  col_index <- unlist(Plot_info$Stimulated_networks[i])
  Data_Table[row_index,col_index] <- Data_Table[row_index,col_index] + 1
}

npermut = 100000
perm_indices = matrix(data=NA, nrow=npermut, ncol=dim(Plot_info[1]))
for (i in c(1:dim(perm_indices)[1])){
  perm_indices[i,] = sample(c(1:dim(Plot_info)[1]),dim(Plot_info)[1])
}
perm_indices = unique(perm_indices)
if (dim(perm_indices)[1] != npermut){
  print('WARNING: Duplicate Permutations')
}

Permutted_Data_Table <- array(data=0, dim = c(13,13,npermut))
colnames(Permutted_Data_Table) <- c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG','CONA','CONB','PMPPR','AUD','VIS','SMOT')
rownames(Permutted_Data_Table) <- c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG','CONA','CONB','PMPPR','AUD','VIS','SMOT')
for (permut in c(1:npermut)){
  Permutted_Data <- Plot_info
  Permutted_Data$Stimulated_networks=Plot_info$Stimulated_networks[perm_indices[permut,]]
  for (i in c(1:dim(Permutted_Data)[1])){
    row_index <- Permutted_Data$Targeted_network[i]
    col_index <- unlist(Permutted_Data$Stimulated_networks[i])
    Permutted_Data_Table[row_index,col_index,permut] <- Permutted_Data_Table[row_index,col_index,permut] + 1
  }
}

Plot_info <- reshape2:::melt(Data_Table)
colnames(Plot_info) <- c("Targeted", "Stimulated", "value")
Plot_info$pvalue <- NA
Plot_info$Significance <- NA
for (i in c(1:dim(Plot_info)[1])){
  Plot_info$pvalue[i] <- sum(Permutted_Data_Table[Plot_info$Targeted[i],Plot_info$Stimulated[i],] >=
                               Data_Table[Plot_info$Targeted[i],Plot_info$Stimulated[i]])/npermut
  if (Plot_info$pvalue[i] < 0.001){
    Plot_info$Significance[i] <- '***'
  } else if (Plot_info$pvalue[i] < 0.01){
    Plot_info$Significance[i] <- '**'
  } else if (Plot_info$pvalue[i] < 0.05){
    Plot_info$Significance[i] <- '*'
  } else {
    Plot_info$Significance[i] <- ''
  }
}
ggplot(Plot_info, aes(x=Stimulated, y=Targeted, fill = value)) + 
  geom_tile(color='black') + 
  geom_text(aes(label=Significance), color='white',size=5,hjust=0.5,vjust=0.75) +
  scale_x_discrete(labels=c('DN-A','DN-B','FPN','dATN-A','dATN-B','SAL/PMN','LANG','CON-A','CON-B','PM-PPr','AUD','VIS','SMOT')) +
  scale_y_discrete(labels=c('DN-A','DN-B','FPN','dATN-A','dATN-B','SAL/PMN','LANG','CON-A','CON-B','PM-PPr','AUD','VIS','SMOT')) +
  scale_fill_continuous(limits=c(0,15)) +
  labs(y = 'Stimulated Network', x = 'Response Network', fill=guide_legend(title="n")) + 
  theme(text = element_text(size=12),legend.position = "right", 
        legend.justification = "bottom", axis.ticks.length=unit(.15, "in"),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        panel.background = element_rect(fill = 'white', colour = 'white'))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_3a.png',
       plot = last_plot(),width = 7.5,height = 3,units = 'in', dpi = 300)

############################## Figure 4
FM_Language_Data <- FM_Data[!FM_Data$TissueType %in% c('Subcortical','Out of Brain') &
                              !FM_Data$BrainRegion %in% c('MedialTemporalCortex') &
                              FM_Data$BrainRegion != 'SensorimotorCortex',]
FM_Language_Data$LanguageEffect <- NA
for (site in c(1:dim(FM_Language_Data )[1])){
  if (FM_Language_Data$EffectList[site] == 'Language'){
    FM_Language_Data$LanguageEffect[site] <- 'Language Deficits'
  } else if ((FM_Language_Data$ReadingEffect[site] %in% c('Negative', 'Negative+AD') | 
              FM_Language_Data$RecitingEffect[site] %in% c('Negative', 'Negative+AD') | 
              FM_Language_Data$NamingEffect[site] %in% c('Negative', 'Negative+AD')) &
             !FM_Language_Data$ReadingEffect[site] %in% c('Positive','Positive+AD','Positive+SZ') & 
             !FM_Language_Data$RecitingEffect[site] %in% c('Positive','Positive+AD','Positive+SZ') & 
             !FM_Language_Data$NamingEffect[site] %in% c('Positive','Positive+AD','Positive+SZ') & 
             !FM_Language_Data$ComprehensionEffect[site] %in% c('Positive','Positive+AD','Positive+SZ') & 
             !FM_Language_Data$MotorEffect[site] %in% c('Positive','Positive+AD','Positive+SZ') & 
             !FM_Language_Data$SensoryEffect[site] %in% c('Positive','Positive+AD','Positive+SZ')){
    FM_Language_Data$LanguageEffect[site] <- 'No Effects'
  } else if (c('Language') %in% unlist(str_split((FM_Language_Data$EffectList[site]),','))){
    FM_Language_Data$LanguageEffect[site] <- 'Complex Language Deficits' 
  } else {
    FM_Language_Data$LanguageEffect[site] <-'Inconclusive'
  }
}
FM_Language_Data$LanguageEffect <- factor(FM_Language_Data$LanguageEffect, levels=c('No Effects','Language Deficits'))
FM_Language_Data <- FM_Language_Data[!is.na(FM_Language_Data$LanguageEffect),]
Plot_info <- FM_Language_Data %>% group_by(DisttoLANG,LanguageEffect)  %>% summarise (n = n()) %>% mutate(freq = n / sum(n)) %>%
  ungroup() %>% complete(DisttoLANG,LanguageEffect, fill = list(n=0,freq=0))
p1 <- ggplotGrob(ggplot(data = Plot_info, aes(x=DisttoLANG,y=n,fill=LanguageEffect)) +
                   geom_bar(stat='identity') +
                   scale_x_continuous(limits=c(0,22),breaks=c(0,5,10,15,20)) +
                   scale_fill_manual(values=c("#377EB8", "#4DAF4A")) +
                   theme_bw() +
                   labs(x = 'Distance to Language Network (mm)',y = '# of Sites') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(), 
                         panel.grid.minor = element_blank(),
                         text = element_text(size = 12),legend.position = c(0.74,0.75),
                         legend.title = element_blank(),legend.margin=margin(-0.2,0.1,0,0, "cm"),
                         strip.text = element_text(margin = margin (3,0,3,0)),panel.spacing = unit(0, "lines"),
                         strip.background =element_rect(fill=rgb(159,176,193,maxColorValue = 255))))

Plot_info <- FM_Language_Data
nulllanguagemodel <- lm( DisttoWMBoundary~DisttoLANG, Plot_info[Plot_info$LanguageEffect == 'No Effects',])
summary(nulllanguagemodel)
languagemodel <- lm(DisttoWMBoundary~DisttoLANG, Plot_info[Plot_info$LanguageEffect == 'Language Deficits',])
summary(languagemodel)
p2 <- ggplotGrob(ggplot(data = Plot_info, aes(x=DisttoLANG)) +
                   annotate('rect',xmin=-Inf,xmax=Inf,ymin=0,ymax=Inf, fill='gray',alpha=0.5) +
                   geom_hline(yintercept = 0, linewidth=0.25) +
                   geom_line(aes(y=DisttoWMBoundary),stat="smooth",method = "lm", formula = y ~x, color='black', linewidth = 1,alpha = 0.5) + 
                   geom_point(aes(y=DisttoWMBoundary,color=LanguageEffect),size=1.5, alpha=0.5) +  facet_wrap(~LanguageEffect,ncol=1) +
                   scale_x_continuous(limits=c(0,21),breaks=c(0,5,10,15,20)) +
                   scale_y_continuous(limits=c(-12,8),breaks=c(-10,-5,0,5)) +
                   scale_color_manual(values=c("#377EB8", "#4DAF4A")) +
                   theme_bw() + guides(fill='none', color='none') +
                   labs(x = 'Distance to Language Network (mm)', y = 'White Matter Displacement (mm)') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(), 
                         panel.grid.minor = element_blank(),axis.title.x = element_text(vjust = 1, hjust = 0.5),
                         text = element_text(size = 12),
                         strip.text = element_text(margin = margin (3,0,3,0)),panel.spacing = unit(0, "lines"),
                         strip.background =element_rect(fill=rgb(159,176,193,maxColorValue = 255))))
g <- grid.arrange(p1,p2,ncol=1, heights=c(2.5,5))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_4a.png',
       plot = g,width = 3.75,height = 5,units = 'in', dpi = 300)

FM_Sensorimotor_Data <- FM_Data[!FM_Data$TissueType %in% c('Subcortical','Out of Brain') &
                                !FM_Data$BrainRegion %in% c('MedialTemporalCortex') &
                                !FM_Data$SubjectID %in% c('TTHMMI'),]
FM_Sensorimotor_Data$SMEffect <- NA
for (site in c(1:dim(FM_Sensorimotor_Data)[1])){
  if (FM_Sensorimotor_Data$EffectList[site] == 'No Effects'){
    FM_Sensorimotor_Data$SMEffect[site] <- 'No Effects'
  } else if (any(c('Hand','Body','Touch','Face') %in% unlist(str_split((FM_Sensorimotor_Data$EffectList[site]),','))) &
             all(!c('Visual','Auditory','Language','Comprehension','Version','Apnea','Temperature','Pain','Smell','Abstract','Aura') %in%
                 unlist(str_split((FM_Sensorimotor_Data$EffectList[site]),',')))){
    FM_Sensorimotor_Data$SMEffect[site] <- 'Sensorimotor Effects'
  } else {
    FM_Sensorimotor_Data$SMEffect[site] <- 'Inconclusive' 
  }
}
FM_Sensorimotor_Data$SMEffect <- factor(FM_Sensorimotor_Data$SMEffect, levels=c('No Effects','Sensorimotor Effects'))
FM_Sensorimotor_Data <- FM_Sensorimotor_Data[!is.na(FM_Sensorimotor_Data$SMEffect),]
Plot_info <- FM_Sensorimotor_Data %>% group_by(DisttoSMOT,SMEffect)  %>% summarise (n = n()) %>% mutate(freq = n / sum(n)) %>%
  ungroup() %>% complete(DisttoSMOT,SMEffect, fill = list(n=0,freq=0))
p1 <- ggplotGrob(ggplot(data = Plot_info, aes(x=DisttoSMOT,y=n,fill=SMEffect)) +
                   geom_bar(stat='identity') +
                   scale_x_continuous(limits=c(0,22),breaks=c(0,5,10,15,20)) +
                   scale_fill_manual(values=c("#377EB8", "#4DAF4A")) +
                   theme_bw() +
                   labs(x = 'Distance to Sensorimotor Network (mm)',y = '# of Sites') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(), 
                         panel.grid.minor = element_blank(),
                         text = element_text(size = 12),legend.position = c(0.74,0.75),
                         legend.title = element_blank(),legend.margin=margin(-0.2,0.1,0,0, "cm"),
                         strip.text = element_text(margin = margin (3,0,3,0)),panel.spacing = unit(0, "lines"),
                         strip.background =element_rect(fill=rgb(159,176,193,maxColorValue = 255))))

Plot_info <- FM_Sensorimotor_Data
nullsensorimotormodel <- lm( DisttoWMBoundary~DisttoSMOT, Plot_info[Plot_info$SMEffect == 'No Effects',])
summary(nullsensorimotormodel)
sensorimotormodel <- lm(DisttoWMBoundary~DisttoSMOT, Plot_info[Plot_info$SMEffect == 'Sensorimotor Effects',])
summary(sensorimotormodel)
p2 <- ggplotGrob(ggplot(data = Plot_info, aes(x=DisttoSMOT)) +
                   annotate('rect',xmin=-Inf,xmax=Inf,ymin=0,ymax=Inf, fill='gray',alpha=0.5) +
                   geom_hline(yintercept = 0, linewidth=0.25) +
                   geom_line(aes(y=DisttoWMBoundary),stat="smooth",method = "lm", formula = y ~x, color='black', linewidth = 1,alpha = 0.5) + 
                   geom_point(aes(y=DisttoWMBoundary,color=SMEffect),size=1.5, alpha=0.5) +  facet_wrap(~SMEffect,ncol=1) +
                   scale_x_continuous(limits=c(0,22),breaks=c(0,5,10,15,20)) +
                   scale_y_continuous(limits=c(-12,8),breaks=c(-10,-5,0,5)) +
                   scale_color_manual(values=c("#377EB8", "#4DAF4A")) +
                   theme_bw() + guides(fill='none', color='none') +
                   labs(x = 'Distance to Sensorimotor Network (mm)', y = 'White Matter Displacement (mm)') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(), 
                         panel.grid.minor = element_blank(),axis.title.x = element_text(vjust = 1, hjust = 0.5),
                         text = element_text(size = 12),
                         strip.text = element_text(margin = margin (3,0,3,0)),panel.spacing = unit(0, "lines"),
                         strip.background =element_rect(fill=rgb(159,176,193,maxColorValue = 255))))
g <- grid.arrange(p1,p2,ncol=1, heights=c(2.5,5))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_4b.png',
       plot = g,width = 3.75,height = 5,units = 'in', dpi = 300)

FM_Visual_Data <- FM_Data[!FM_Data$TissueType %in% c('Subcortical','Out of Brain') & 
                          !FM_Data$BrainRegion %in% c('MedialTemporalCortex'),]
FM_Visual_Data$VisEffect <- NA
for (site in c(1:dim(FM_Visual_Data)[1])){
  if (FM_Visual_Data$EffectList[site] == 'No Effects'){
    FM_Visual_Data$VisEffect[site] <- 'No Effects'
  } else if (any(c('Visual') %in% unlist(str_split((FM_Visual_Data$EffectList[site]),','))) &
             all(!c('Language','Comprehension','Version','Apnea','Temperature','Pain','Smell','Abstract','Aura','Hand','Body','Touch','Face','Auditory') %in%
                 unlist(str_split((FM_Visual_Data$EffectList[site]),',')))){
    FM_Visual_Data$VisEffect[site] <- 'Visual Effects'
  } else {
    FM_Visual_Data$VisEffect[site] <- 'Inconclusive' 
  }
}
FM_Visual_Data$VisEffect <- factor(FM_Visual_Data$VisEffect, levels=c('No Effects','Visual Effects'))
FM_Visual_Data <- FM_Visual_Data[!is.na(FM_Visual_Data$VisEffect),]
Plot_info <- FM_Visual_Data %>% group_by(DisttoVIS,VisEffect)  %>% summarise (n = n()) %>% mutate(freq = n / sum(n)) %>%
  ungroup() %>% complete(DisttoVIS,VisEffect, fill = list(n=0,freq=0))
p1 <- ggplotGrob(ggplot(data = Plot_info, aes(x=DisttoVIS,y=n,fill=VisEffect)) +
                   geom_bar(stat='identity') +
                   scale_x_continuous(limits=c(0,22),breaks=c(0,5,10,15,20)) +
                   scale_fill_manual(values=c("#377EB8", "#4DAF4A")) +
                   theme_bw() +
                   labs(x = 'Distance to Visual Network (mm)',y = '# of Sites') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(), 
                         panel.grid.minor = element_blank(),
                         text = element_text(size = 12),legend.position = c(0.74,0.75),
                         legend.title = element_blank(),legend.margin=margin(-0.2,0.1,0,0, "cm"),
                         strip.text = element_text(margin = margin (3,0,3,0)),panel.spacing = unit(0, "lines"),
                         strip.background =element_rect(fill=rgb(159,176,193,maxColorValue = 255))))

Plot_info <- FM_Visual_Data
nullvisualmodel <- lm( DisttoWMBoundary~DisttoVIS, Plot_info[Plot_info$VisEffect == 'No Effects',])
summary(nullvisualmodel)
visualmodel <- lm(DisttoWMBoundary~DisttoVIS, Plot_info[Plot_info$VisEffect == 'Visual Effects',])
summary(visualmodel)
p2 <- ggplotGrob(ggplot(data = Plot_info, aes(x=DisttoVIS)) +
                   annotate('rect',xmin=-Inf,xmax=Inf,ymin=0,ymax=Inf, fill='gray',alpha=0.5) +
                   geom_hline(yintercept = 0, linewidth=0.25) +
                   geom_line(aes(y=DisttoWMBoundary),stat="smooth",method = "lm", formula = y ~x, color='black', linewidth = 1,alpha = 0.5) + 
                   geom_point(aes(y=DisttoWMBoundary,color=VisEffect),size=1.5, alpha=0.5) +  facet_wrap(~VisEffect,ncol=1) +
                   scale_x_continuous(limits=c(0,22),breaks=c(0,5,10,15,20)) +
                   scale_y_continuous(limits=c(-12,8),breaks=c(-10,-5,0,5)) +
                   scale_color_manual(values=c("#377EB8", "#4DAF4A")) +
                   theme_bw() + guides(fill='none', color='none') +
                   labs(x = 'Distance to Visual Network (mm)', y = 'White Matter Displacement (mm)') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(), 
                         panel.grid.minor = element_blank(),axis.title.x = element_text(vjust = 1, hjust = 0.5),
                         text = element_text(size = 12),
                         strip.text = element_text(margin = margin (3,0,3,0)),panel.spacing = unit(0, "lines"),
                         strip.background =element_rect(fill=rgb(159,176,193,maxColorValue = 255))))
g <- grid.arrange(p1,p2,ncol=1, heights=c(2.5,5))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_4c.png',
       plot = g,width = 3.75,height = 5,units = 'in', dpi = 300)

FM_Auditory_Data <- FM_Data[!FM_Data$TissueType %in% c('Subcortical','Out of Brain') &
                              !FM_Data$SubjectID %in% c('TTHMMI'),]
FM_Auditory_Data$AudEffect <- NA
for (site in c(1:dim(FM_Auditory_Data)[1])){
  if (FM_Auditory_Data$EffectList[site] == 'No Effects'){
    FM_Auditory_Data$AudEffect[site] <- 'No Effects'
  } else if (any(c('Auditory') %in% unlist(str_split((FM_Auditory_Data$EffectList[site]),','))) &
             all(!c('Language','Comprehension','Version','Apnea','Temperature','Pain','Smell','Abstract','Aura','Hand','Body','Touch','Face','Visual') %in%
                 unlist(str_split((FM_Auditory_Data$EffectList[site]),',')))){
    FM_Auditory_Data$AudEffect[site] <- 'Auditory Effects'
  } else {
    FM_Auditory_Data$AudEffect[site] <- 'Inconclusive' 
  }
}
FM_Auditory_Data$AudEffect <- factor(FM_Auditory_Data$AudEffect, levels=c('No Effects','Auditory Effects'))
FM_Auditory_Data <- FM_Auditory_Data[!is.na(FM_Auditory_Data$AudEffect),]
Plot_info <- FM_Auditory_Data %>% group_by(DisttoAUD,AudEffect)  %>% summarise (n = n()) %>% mutate(freq = n / sum(n)) %>%
  ungroup() %>% complete(DisttoAUD,AudEffect, fill = list(n=0,freq=0))
p1 <- ggplotGrob(ggplot(data = Plot_info, aes(x=DisttoAUD,y=n,fill=AudEffect)) +
                   geom_bar(stat='identity') +
                   scale_x_continuous(limits=c(0,22),breaks=c(0,5,10,15,20)) +
                   scale_fill_manual(values=c("#377EB8", "#4DAF4A")) +
                   theme_bw() +
                   labs(x = 'Distance to Auditory Network (mm)',y = '# of Sites') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(), 
                         panel.grid.minor = element_blank(),
                         text = element_text(size = 12),legend.position = c(0.74,0.75),
                         legend.title = element_blank(),legend.margin=margin(-0.2,0.1,0,0, "cm"),
                         strip.text = element_text(margin = margin (3,0,3,0)),panel.spacing = unit(0, "lines"),
                         strip.background =element_rect(fill=rgb(159,176,193,maxColorValue = 255))))

Plot_info <- FM_Auditory_Data
nullauditorymodel <- lm( DisttoWMBoundary~DisttoAUD, Plot_info[Plot_info$AudEffect == 'No Effects',])
summary(nullauditorymodel)
auditorymodel <- lm(DisttoWMBoundary~DisttoAUD, Plot_info[Plot_info$AudEffect == 'Auditory Effects',])
summary(auditorymodel)
p2 <- ggplotGrob(ggplot(data = Plot_info, aes(x=DisttoAUD)) +
                   annotate('rect',xmin=-Inf,xmax=Inf,ymin=0,ymax=Inf, fill='gray',alpha=0.5) +
                   geom_hline(yintercept = 0, linewidth=0.25) +
                   geom_line(aes(y=DisttoWMBoundary),stat="smooth",method = "lm", formula = y ~x, color='black', linewidth = 1,alpha = 0.5) + 
                   geom_point(aes(y=DisttoWMBoundary,color=AudEffect),size=1.5, alpha=0.5) +  facet_wrap(~AudEffect,ncol=1) +
                   scale_x_continuous(limits=c(0,22),breaks=c(0,5,10,15,20)) +
                   scale_y_continuous(limits=c(-12,8),breaks=c(-10,-5,0,5)) +
                   scale_color_manual(values=c("#377EB8", "#4DAF4A")) +
                   theme_bw() + guides(fill='none', color='none') +
                   labs(x = 'Distance to Auditory Network (mm)', y = 'White Matter Displacement (mm)') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(), 
                         panel.grid.minor = element_blank(),axis.title.x = element_text(vjust = 1, hjust = 0.5),
                         text = element_text(size = 12),
                         strip.text = element_text(margin = margin (3,0,3,0)),panel.spacing = unit(0, "lines"),
                         strip.background =element_rect(fill=rgb(159,176,193,maxColorValue = 255))))
g <- grid.arrange(p1,p2,ncol=1, heights=c(2.5,5))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_4d.png',
       plot = g,width = 3.75,height = 5,units = 'in', dpi = 300)

############################## Supplementary Figure 1
Plot_info <- read_excel("/Users/cce3182/Desktop/b1134/analysis/ccyr/StimProject/StimResponsePairInfoTable.xlsx")
Plot_info$StimShaft = FALSE
for (i in 1:dim(Plot_info)[1]){
  Plot_info$StimShaft[i] <- sub("^([[:alpha:]]*).*", "\\1", unlist(str_split(Plot_info$StimSite[i],'-'))[1]) ==
    sub("^([[:alpha:]]*).*", "\\1", unlist(str_split(Plot_info$ChannelID[i],'-'))[1])
  
}
Plot_info <- Plot_info[Plot_info$Response_Magnitude <= 50,]
Plot_info <- Plot_info[order(Plot_info$StimShaft),]
ggplot(Plot_info, aes(x=DistancetoStim,y=Response_Magnitude,color=StimShaft)) + 
  geom_point(alpha=0.5) + 
  geom_vline(xintercept=20, linetype='dashed',color='black',linewidth=1.5) + 
  scale_color_manual(values=c('blue','red'), labels=c('Recording Shaft','Stimulating Shaft')) +
  scale_x_continuous(limits=c(0,150), breaks=seq(0,140,by=20)) + 
  scale_y_continuous(limits=c(0,50), breaks=seq(0,50,by=10)) +
  coord_cartesian(xlim=c(5,150)) +
  theme_bw() + 
  labs(x = 'Distance to Stimulation Site (mm)', y = 'Response Amplitude (Z)') + 
  theme(legend.title=element_blank(),
        legend.position=c(0.835,0.873),legend.margin=margin(-0.2,0.1,0,0, "cm"),
        legend.box.background = element_rect(colour = "black"),
        text = element_text(size = 12))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_Supp_1b.png',
       plot = last_plot(),width = 4.75,height = 2.5,units = 'in', dpi = 300)

#load data
Plot_info <- data.frame(read_excel("/Users/cce3182/Desktop/b1134/analysis/ccyr/StimProject/AllSubjects_FWHM_Results.xlsx"))
Plot_info['Group']<- 2
ggplot(Plot_info, aes(x=Rsquared, y=FWHM)) +
  geom_point(colour="black",alpha=0.25) +
  stat_density2d(geom = "polygon", aes(fill=..level.., alpha=..level..)) +
  scale_alpha_continuous(range=c(0.05,0.25)) + #range values adjust opacity of the overlay
  scale_fill_gradient(low="blue",high="red") +
  scale_x_continuous(limits=c(0,1),expand=c(0,0)) +
  scale_y_continuous(limits=c(0,40),expand=c(0,0)) +
  coord_cartesian(xlim=c(0,1.05)) +
  theme_bw() + theme(legend.position="none") +
  ylab('Full Width Half Maximum (mm)') + 
  xlab(bquote('R'^'2')) + 
  theme(panel.grid.major.y = element_line( size=.1, color="black" ),
        text = element_text(size=12))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_Supp_1c.png',
       plot = last_plot(),width = 4.75,height = 4,units = 'in', dpi = 300)

############################## Supplementary Figure 4
Plot_info <- CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                         !CCEP_Data$AmpResult %in% c("Not Stimulated"),]
Plot_info$AmpResult[Plot_info$Stimulated_networks_n == 0] <- 'No Activity'
Plot_info$AmpResult[Plot_info$Stimulated_networks_n > 0] <- 'Evoked Activity'
Plot_info$AmpResult <- factor(Plot_info$AmpResult, levels=c('No Activity','Evoked Activity'))
stats <- t.test(Plot_info$Max_Current[Plot_info$AmpResult=='No Activity'], 
                Plot_info$Max_Current[Plot_info$AmpResult=='Evoked Activity'],alternative='two.sided')
Plot_info$StimSiteType <- factor(Plot_info$StimSiteType,levels=c('D','G','S'))
p1 <- ggplotGrob(ggplot(data = Plot_info, aes(x=AmpResult,
                                              y=Max_Current, color=AmpResult)) +
                   geom_boxplot(width=0.2, outlier.shape = NA, show.legend = FALSE) +
                   geom_line(stat="smooth",method = "lm", formula = y ~x, color='black', linewidth = 1,alpha = 0.5) + 
                   geom_jitter(aes(size=StimSiteType),width=0.1, height=0.1, alpha=0.5) +
                   geom_bracket( xmin = c(1), xmax = c(2), y.position = c(8) ,label.size = 4, label = 'n.s.',
                                 inherit.aes = FALSE, tip.length = c(0.02)) +
                   scale_y_continuous(limits=c(0,16), breaks=c(0,5,10,15)) +
                   scale_size_manual(values = c("D" = 1, "G"=2, 'S'=2),labels=c('sEEG','ECOG','ECOG')) +
                   scale_color_manual(values=c("#377EB8", "#4DAF4A")) +
                   labs(y = 'Maximum Current (mA)') +
                   ggtitle('Single Pulse Electrical Stimulation') +
                   theme_bw() + guides(color="none") +
                   theme(plot.title = element_text(hjust = 0.5,size=12),legend.margin=margin(-0.2,0.1,0,0, "cm"),
                         legend.title=element_blank(),axis.title.x=element_blank(),
                         legend.box.background = element_rect(colour = "black"),legend.position=c(0.88,0.897),
                         text = element_text(size=12)))

Plot_info <- FM_Data[!FM_Data$TissueType %in% c('Subcortical') &
                       !FM_Data$StimulationResult %in% c('Not Stimulated','Inconclusive'),]
Plot_info$StimulationResult <- factor(as.character(Plot_info$StimulationResult), levels=c('No Effects', 'Behavioral Effects'))
stats <- t.test(Plot_info$MaxCurrent[Plot_info$StimulationResult=='No Effects'], 
                Plot_info$MaxCurrent[Plot_info$StimulationResult=='Behavioral Effects'],alternative='two.sided')
p2 <- ggplotGrob(ggplot(data = Plot_info, aes(x=StimulationResult,
                                              y=MaxCurrent, color=StimulationResult)) +
                   geom_boxplot(width=0.2, outlier.shape = NA, show.legend = FALSE) +
                   geom_line(stat="smooth",method = "lm", formula = y ~x, color='black', linewidth = 1,alpha = 0.5) + 
                   geom_jitter(aes(size=SiteType),width=0.1, height=0.1, alpha=0.5) +
                   geom_bracket( xmin = c(1), xmax = c(2), y.position = c(15.65) ,label.size = 4, label = 'p < 0.001',
                                 inherit.aes = FALSE, tip.length = c(0.02)) +
                   scale_y_continuous(limits=c(0,16), breaks=c(0,5,10,15)) +
                   scale_size_manual(values = c("D" = 1, "G"=2, 'S'=2),labels=c('sEEG','ECOG','ECOG')) +
                   scale_color_manual(values=c("#377EB8", "#4DAF4A")) +
                   labs(y = 'Maximum Current (mA)') +
                   ggtitle('50 Hz Electrical Stimulation') +
                   theme_bw() + guides(color="none") +
                   theme(plot.title = element_text(hjust = 0.5,size=12),legend.margin=margin(-0.2,0.1,0,0, "cm"),
                         legend.title=element_blank(),axis.title.x=element_blank(),
                         legend.box.background = element_rect(colour = "black"),legend.position=c(0.88,0.897),
                         text = element_text(size=12)))
g <- grid.arrange(p1,p2,nrow=1, widths=c(3.75,3.75))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_Supp4.png',
       plot = g,width = 7.5,height = 3,units = 'in', dpi = 300)

############################## Supplementary Figure 5
Plot_info <- CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                         !CCEP_Data$AmpResult %in% c('Not Stimulated','No In-Network Coverage','No Effect') &
                         !CCEP_Data$Targeted_network %in% c('Unknown'),]
Plot_info$AmpResult[Plot_info$AmpResult %in% c('Hit + Specific','Hit + Nonspecific')] <- 'Hit'
Plot_info$AmpResult[Plot_info$AmpResult %in% c('Miss + Specific','Miss + Nonspecific')] <- 'Miss'
Plot_info$AmpResult <- factor(Plot_info$AmpResult, levels = c('Hit','Miss'))
stats <- t.test(Plot_info$BOLDFC[Plot_info$AmpResult=='Miss'], 
                Plot_info$BOLDFC[Plot_info$AmpResult=='Hit'],alternative='less', var.equal=FALSE)
p1 <- ggplotGrob(ggplot(data = Plot_info, aes(x=as.numeric(AmpResult),y=BOLDFC, color = AmpResult)) +
                   stat_halfeye(aes(fill=AmpResult, scale=0.5), .width=0, adjust=0.5, alpha = 0.5, normalize = 'all', show.legend = FALSE) +
                   geom_boxplot(width=0.2, outlier.shape = NA, show.legend = FALSE) +
                   gghalves::geom_half_point(side='l', alpha=0.5, size=1, transformation=position_jitter(width=0.1,height=0),show.legend = FALSE) +
                   geom_bracket( xmin = c(1), xmax = c(2), y.position = c(1.05) ,label.size = 4, label = 'p = 0.002',
                                 inherit.aes = FALSE, tip.length = c(0.02)) +
                   scale_y_continuous(limits=c(-0.4,1.1), breaks=c(-0.25,0,0.25,0.5,0.75,1)) +
                   scale_x_continuous(limits=c(0.5,3), breaks=c(1:2), labels=c('Hit','Miss')) +
                   scale_color_manual(values=c('#F8766D','#00BFC4')) +
                   scale_fill_manual(values=c('#F8766D','#00BFC4')) +
                   coord_cartesian(xlim=c(0.5,2.5)) + 
                   theme_bw() +
                   labs(y = 'CCEP-RSFC Correlation (Z)') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(),
                         panel.grid.minor = element_blank(),
                         axis.ticks.x=element_blank(),axis.title.x=element_blank(),
                         text = element_text(size=12)))

Plot_info <- CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                         !CCEP_Data$AmpResult %in% c('Not Stimulated','No In-Network Coverage', 'No Effect'),]
Plot_info$SemiCollateral <- FALSE
for (i in 1:dim(Plot_info)[1]){
  if (any(Plot_info[i,paste0('Distto',unlist(Plot_info$Stimulated_networks[i]))] <= 5)){
    Plot_info$SemiCollateral[i] <- TRUE
  }
}
Plot_info <- Plot_info %>% group_by(Targeted_network, AmpResult,SemiCollateral) %>% count()
Plot_info$AmpResult <- factor(Plot_info$AmpResult,levels = c('Hit + Specific',
                                                             'Hit + Nonspecific','Miss + Specific','Miss + Nonspecific'))
p2 <- ggplotGrob(ggplot(Plot_info, aes(x=AmpResult,y=n,fill=SemiCollateral)) + 
                   geom_bar(stat='identity') +
                   scale_fill_manual(values=c('#00BFC4','#F8766D')) + #facet_wrap(~Targeted_network) +
                   theme_bw() +
                   labs(y = '# of Stimulation Sites',fill='Stimulated Nearby Network(s)') + 
                   theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(),
                         panel.grid.minor = element_blank(),legend.margin=margin(0.1,0.1,0.1,0.1, "cm"),
                         legend.box.background = element_rect(colour = "black"),legend.position=c(0.766,0.75),
                         axis.text.x = element_text(angle=30,vjust=1,hjust=1),
                         axis.ticks.x=element_blank(),axis.title.x=element_blank(),
                         text = element_text(size=12)))
g <- grid.arrange(p1,p2,nrow=1, widths=c(2,5.5))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_Supp5.png',
       plot = g,width = 7.5,height = 2.5,units = 'in', dpi = 300)

############################## Supplementary Figure 6
FM_Data$EffectVariety <- 0
for (site in c(1:dim(FM_Data)[1])){
  if (c('Language') %in% unlist(str_split((FM_Data$EffectList[site]),','))){ #language symptoms
    FM_Data$EffectVariety[site] <- FM_Data$EffectVariety[site] + 1
  } 
  if (c('Comprehension') %in% unlist(str_split((FM_Data$EffectList[site]),','))){ #comprehension symptoms
    FM_Data$EffectVariety[site] <- FM_Data$EffectVariety[site] + 1
  }
  if (any(c('Hand','Body','Visual','Auditory','Touch','Face') %in% unlist(str_split((FM_Data$EffectList[site]),',')))){ #sensorimotor symptoms
    FM_Data$EffectVariety[site] <- FM_Data$EffectVariety[site] + 1
  } 
  if (any(c('Version','Apnea','Temperature','Pain','Smell','Abstract','Aura') %in% unlist(str_split((FM_Data$EffectList[site]),',')))){ #abstract symptoms
    FM_Data$EffectVariety[site] <- FM_Data$EffectVariety[site] + 1
  } 
}
Plot_info <- FM_Data[!FM_Data$TissueType %in% c('Subcortical','Out of Brain') &
                       !FM_Data$EffectList %in% c('Not Stimulated','Inconclusive','No Effects'),]
Plot_info$AmpResult <- NA
Plot_info$AmpResult[Plot_info$EffectVariety == 1] <- 'Specific'
Plot_info$AmpResult[Plot_info$EffectVariety > 1] <- 'Nonspecific'
Plot_info$AmpResult <- factor(Plot_info$AmpResult, levels = c('Specific','Nonspecific'))
Plot_info <- Plot_info[!is.na(Plot_info$AmpResult),]
stats <- t.test(Plot_info$DisttoWMBoundary[Plot_info$AmpResult=='Specific'], 
                Plot_info$DisttoWMBoundary[Plot_info$AmpResult=='Nonspecific'],alternative='greater', var.equal=FALSE)
ggplot(data = Plot_info, aes(x=as.numeric(AmpResult),y=DisttoWMBoundary, color = AmpResult)) +
  annotate('rect',xmin=-Inf,xmax=Inf,ymin=0,ymax=Inf, fill='gray',alpha=0.5) +
  geom_hline(yintercept = 0, linewidth=0.25) +
  stat_halfeye(aes(fill=AmpResult, scale=0.5), .width=0, adjust=0.5, alpha = 0.5, normalize = 'all', show.legend = FALSE) +
  geom_boxplot(width=0.2, outlier.shape = NA, show.legend = FALSE) +
  gghalves::geom_half_point(side='l', alpha=0.5, size=1, transformation=position_jitter(width=0.05,height=0),show.legend = FALSE) +
  geom_bracket( xmin = c(1), xmax = c(2), y.position = c(4.5) ,label.size = 4, label = 'n.s.',
                inherit.aes = FALSE, tip.length = c(0)) +
  scale_y_continuous(limits=c(-11.5,5.25), breaks=seq(-10,5,by=5)) +
  scale_x_continuous(limits=c(0.5,3), breaks=c(1:2), labels=c('Specific','Nonspecific')) +
  coord_cartesian(xlim=c(0.5,2.5)) + 
  theme_bw() +
  labs(y = 'White Matter Displacement (mm)') + 
  theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        text = element_text(size=12))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_Supp6a.png',
       plot = last_plot(),width = 2,height = 3,units = 'in', dpi = 300)

FM_Language_Data <- FM_Data[!FM_Data$TissueType %in% c('Subcortical','Out of Brain') &
                              FM_Data$BrainRegion != 'SensorimotorCortex',]
FM_Language_Data$LanguageEffect <- NA
for (site in c(1:dim(FM_Language_Data )[1])){
  if (FM_Language_Data$EffectList[site] == 'Language'){
    FM_Language_Data$LanguageEffect[site] <- 'Language'
  } else if (!FM_Language_Data$EffectList[site] %in% c('Not Stimulated','Inconclusive','No Effects') &
             !c('Language') %in% unlist(str_split((FM_Language_Data$EffectList[site]),',')) &
             (!FM_Language_Data$ReadingEffect[site] %in% c('NotTested') | 
              !FM_Language_Data$RecitingEffect[site] %in% c('NotTested') | 
              !FM_Language_Data$NamingEffect[site] %in% c('NotTested'))){
    FM_Language_Data$LanguageEffect[site] <- 'Non-Language' 
  }
}
FM_Language_Data$LanguageEffect <- factor(FM_Language_Data$LanguageEffect, 
                                          levels=c('Language','Non-Language'))
FM_Language_Data <- FM_Language_Data[!is.na(FM_Language_Data$LanguageEffect),]
Plot_info <- FM_Language_Data
Plot_info <- Plot_info[Plot_info$DisttoLANG <= 5,]
stats <- t.test(Plot_info$NearNetworks[Plot_info$LanguageEffect=='Language'], 
                Plot_info$NearNetworks[Plot_info$LanguageEffect=='Non-Language'],alternative='less', var.equal=FALSE)
ggplot(data = Plot_info, aes(x=as.numeric(LanguageEffect),y=NearNetworks, color = LanguageEffect)) +
  stat_halfeye(aes(fill=LanguageEffect, scale=0.5), .width=0, adjust=0.5, alpha = 0.5, normalize = 'all', show.legend = FALSE) +
  geom_boxplot(width=0.2, outlier.shape = NA, show.legend = FALSE) +
  gghalves::geom_half_point(side='l', alpha=0.5, size=1, transformation=position_jitter(width=0.05,height=0),show.legend = FALSE) +
  geom_bracket( xmin = c(1), xmax = c(2), y.position = c(6.5) ,label.size = 4, label = 'n.s.',
                inherit.aes = FALSE, tip.length = c(0)) +
  scale_y_continuous(limits=c(0,7), breaks=seq(0,6,by=1)) +
  scale_x_continuous(limits=c(0.5,3), breaks=c(1:2), labels=c('Language','Non-Language')) +
  coord_cartesian(xlim=c(0.5,2.5)) + 
  theme_bw() +
  labs(y = '# of Nearby Networks', title = 'Sites Near Language Network') + 
  theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),axis.title.x=element_blank(),
        #axis.text.x = element_text(angle=30,hjust=1,vjust=1),
        axis.ticks.x=element_blank(),plot.title = element_text(hjust = 0.5),
        text = element_text(size=12))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_Supp6c.png',
       plot = last_plot(),width = 3.75,height = 2.5,units = 'in', dpi = 300)

FM_Sensorimotor_Data <- FM_Data[!FM_Data$TissueType %in% c('Subcortical','Out of Brain'),]
FM_Sensorimotor_Data$SMEffect <- NA
for (site in c(1:dim(FM_Sensorimotor_Data )[1])){
  if (any(c('Hand','Body','Visual','Auditory','Touch','Face') %in% unlist(str_split((FM_Sensorimotor_Data$EffectList[site]),','))) &
      all(!c('Language','Comprehension','Version','Apnea','Temperature','Pain','Smell','Abstract','Aura') %in%
          unlist(str_split((FM_Sensorimotor_Data$EffectList[site]),',')))){
    FM_Sensorimotor_Data$SMEffect[site] <- 'Sensorimotor'
  } else if (!FM_Sensorimotor_Data$EffectList[site] %in% c('Not Stimulated','Inconclusive','No Effects') &
             !any(c('Hand','Body','Visual','Auditory','Touch','Face') %in% unlist(str_split((FM_Sensorimotor_Data$EffectList[site]),',')))){
    FM_Sensorimotor_Data$SMEffect[site] <- 'Non-Sensorimotor' 
  }
}
FM_Sensorimotor_Data$SMEffect <- factor(FM_Sensorimotor_Data$SMEffect, levels=c('Sensorimotor','Non-Sensorimotor'))
FM_Sensorimotor_Data <- FM_Sensorimotor_Data[!is.na(FM_Sensorimotor_Data$SMEffect),]
Plot_info <- FM_Sensorimotor_Data
Plot_info <- Plot_info[Plot_info$DisttoSMOT <= 5,]
stats <- t.test(Plot_info$NearNetworks[Plot_info$SMEffect=='Sensorimotor'], 
                Plot_info$NearNetworks[Plot_info$SMEffect=='Non-Sensorimotor'],alternative='less', var.equal=FALSE)
ggplot(data = Plot_info, aes(x=as.numeric(SMEffect),y=NearNetworks, color = SMEffect)) +
  stat_halfeye(aes(fill=SMEffect, scale=0.5), .width=0, adjust=0.5, alpha = 0.5, normalize = 'all', show.legend = FALSE) +
  geom_boxplot(width=0.2, outlier.shape = NA, show.legend = FALSE) +
  gghalves::geom_half_point(side='l', alpha=0.5, size=1, transformation=position_jitter(width=0.05,height=0),show.legend = FALSE) +
  geom_bracket( xmin = c(1), xmax = c(2), y.position = c(6.5) ,label.size = 4, label = 'p = 0.028',
                inherit.aes = FALSE, tip.length = c(0.02)) +
  scale_y_continuous(limits=c(0,7), breaks=seq(0,6,by=1)) +
  scale_x_continuous(limits=c(0.5,3), breaks=c(1:2), labels=c('Sensorimotor','Non-Sensorimotor')) +
  coord_cartesian(xlim=c(0.5,2.5)) + 
  theme_bw() +
  labs(y = '# of Nearby Networks', title = 'Sites Near Sensorimotor Network') + 
  theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),axis.title.x=element_blank(),
        #axis.text.x = element_text(angle=30,hjust=1,vjust=1),
        axis.ticks.x=element_blank(),plot.title = element_text(hjust = 0.5),
        text = element_text(size=12))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_Supp6b.png',
       plot = last_plot(),width = 3.75,height = 2.5,units = 'in', dpi = 300)

############################## sandbox
Plot_info <- CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                         !CCEP_Data$AmpResult %in% c('Not Stimulated','No In-Network Coverage', 'No Effect') &
                         !CCEP_Data$Targeted_network %in% c('Unknown'),]
Plot_info$AmpResult[Plot_info$Stimulated_networks_n == 1] <- 'Specific'
Plot_info$AmpResult[Plot_info$Stimulated_networks_n > 1] <- 'Nonspecific'
Plot_info$AmpResult <- factor(Plot_info$AmpResult,levels=c('Specific','Nonspecific'))
SpecificityModel <- lm( DisttoWMBoundary~Stimulated_networks_n, Plot_info)
summary(SpecificityModel)
ggplot(data = Plot_info, aes(x=Stimulated_networks_n,y=DisttoWMBoundary, group=Stimulated_networks_n, color=AmpResult)) +
  annotate('rect',xmin=-Inf,xmax=Inf,ymin=0,ymax=Inf, fill='gray',alpha=0.5) +
  geom_hline(yintercept = 0, linewidth=0.25) +
  #stat_halfeye(aes(scale=0.5), .width=0, adjust=0.5, alpha = 0.5, normalize = 'all', show.legend = FALSE) +
  geom_boxplot(width=0.2, outlier.shape = NA, show.legend = FALSE) +
  gghalves::geom_half_point(side='l', alpha=0.5, size=1, transformation=position_jitter(width=0.05,height=0)) +
  scale_y_continuous(limits=c(-4,5), breaks=seq(-4,5,by=2)) +
  scale_x_continuous(limits=c(0,9), breaks=c(1:8)) +
  coord_cartesian(xlim=c(0.5,8.5)) + 
  theme_bw() +
  labs(y = 'White Matter Displacement (mm)', x = '# of Networks Stimulated') + 
  theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(), axis.ticks.x=element_blank(),
        legend.margin=margin(-0.2,0.1,0,0, "cm"),
        legend.box.background = element_rect(colour = "black"),legend.position=c(0.82,0.928),
        legend.title=element_blank(), text = element_text(size = 12))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_3b_rev.png',
       plot = last_plot(),width = 3.5,height = 4,units = 'in', dpi = 300)

Plot_info <- CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                         !CCEP_Data$BrainRegion %in% c('MedialTemporalCortex') &
                         !CCEP_Data$AmpResult %in% c('Not Stimulated','No In-Network Coverage','No Effect') &
                         !CCEP_Data$Targeted_network %in% c('Unknown'),]
Plot_info$AmpResult[Plot_info$AmpResult %in% c('Hit + Specific','Hit + Nonspecific')] <- 'Hit'
Plot_info$AmpResult[Plot_info$AmpResult %in% c('Miss + Specific','Miss + Nonspecific')] <- 'Miss'
Plot_info <- Plot_info %>% group_by(SubjectID,AmpResult) %>% count()
Plot_info$AmpResult <- factor(Plot_info$AmpResult, levels = c('Hit','Miss'))
Plot_info$SubjectID <- factor(Plot_info$SubjectID, levels = c('SSYQZJ','XVFXFI','PHPKQJ','CEWLLT','ZWLWDL','DQTAWH','XBSGST','YKBYHS','TTHMMI'))
p1 <- ggplotGrob(ggplot(Plot_info, aes(x=as.numeric(SubjectID),y=n,fill=AmpResult)) + 
  geom_bar(stat='identity') +
  scale_x_continuous(limits=c(0,10),breaks=c(1:9),labels=c('P1','P2','P3','P5','P7','P8','P9','P10','P11')) +
  scale_y_continuous(limits=c(0,16),breaks=c(0,5,10,15)) +
  coord_cartesian(xlim=c(0.5,9.5)) +
  theme_bw() +
  labs(y = '# of Stimulation Sites', x = 'Patient', fill = 'Stimulation\nResult') + 
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(), axis.ticks.x=element_blank(),
        legend.margin=margin(-0.2,-0.1,0,-0.1, "cm"),
        #legend.box.background = element_rect(colour = "black"),legend.position=c(0.31,0.82),
        text = element_text(size = 12)))

Plot_info <- CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                         !CCEP_Data$BrainRegion %in% c('MedialTemporalCortex') &
                         CCEP_Data$AmpResult %in% c('Miss + Specific','Miss + Nonspecific'),]
Plot_info$SemiCollateral <- FALSE
for (i in 1:dim(Plot_info)[1]){
  if (any(Plot_info[i,paste0('Distto',unlist(Plot_info$Stimulated_networks[i]))] <= 5)){
    Plot_info$SemiCollateral[i] <- TRUE
  }
}
Plot_info <- Plot_info %>% group_by(SubjectID,SemiCollateral) %>% count()
Plot_info$SemiCollateral <- factor(Plot_info$SemiCollateral, levels = c(TRUE,FALSE))
Plot_info$SubjectID <- factor(Plot_info$SubjectID, levels = c('SSYQZJ','XVFXFI','PHPKQJ','CEWLLT','ZWLWDL','DQTAWH','XBSGST','YKBYHS','TTHMMI'))
p2 <- ggplotGrob(ggplot(Plot_info, aes(x=as.numeric(SubjectID),y=n,fill=SemiCollateral)) + 
        geom_bar(stat='identity') +
        scale_x_continuous(limits=c(0,10),breaks=c(1:9),labels=c('P1','P2','P3','P5','P7','P8','P9','P10','P11')) +
        scale_y_continuous(limits=c(0,16),breaks=c(0,5,10,15)) +
        coord_cartesian(xlim=c(0.5,9.5)) +
        scale_fill_manual(values=c('#91ffff','#08a4a7'))+
        theme_bw() +
        labs(y = '# of Stimulation Sites', x = 'Patient', fill = 'Stimulated\nNearby\nNetwork(s)') + 
        theme(panel.grid.major.x = element_blank(),
              panel.grid.minor = element_blank(), axis.ticks.x=element_blank(),
              legend.margin=margin(-0.2,-0.1,0,-0.1, "cm"),
              #legend.box.background = element_rect(colour = "black"),legend.position=c(0.31,0.82),
              text = element_text(size = 12)))
g <- grid.arrange(p1,p2,ncol=1)
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_3c_rev.png',
       plot = g,width = 4,height = 4,units = 'in', dpi = 300)

Plot_info <- CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                         !CCEP_Data$BrainRegion %in% c('MedialTemporalCortex') &
                         !CCEP_Data$AmpResult %in% c('Not Stimulated','No In-Network Coverage','No Effect') &
                         !CCEP_Data$Targeted_network %in% c('Unknown'),]
Plot_info$AmpResult[Plot_info$AmpResult %in% c('Hit + Specific','Hit + Nonspecific')] <- 'Hit'
Plot_info$AmpResult[Plot_info$AmpResult %in% c('Miss + Specific','Miss + Nonspecific')] <- 'Miss'
Plot_info$AmpResult <- factor(Plot_info$AmpResult, levels = c('Hit','Miss'))
Plot_info$Targeted_network<- factor(Plot_info$Targeted_network, levels = c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG','CONA','CONB','PMPPR','AUD','VIS','SMOT'))
Plot_info <- Plot_info %>% group_by(Targeted_network,AmpResult) %>% summarise (n = n()) %>%
  ungroup() %>% complete(Targeted_network,AmpResult, fill = list(n=0,freq=0))
ggplot(Plot_info, aes(x=as.numeric(Targeted_network),y=n,fill=AmpResult)) + 
     geom_bar(stat='identity') +
     scale_x_continuous(limits=c(0,14),breaks=c(1:13),
                        labels=c('DN-A','DN-B','FPN','dATN-A','dATN-B','SAL/PMN','LANG','CON-A','CON-B','PM-PPr','AUD','VIS','SMOT')) +
     #scale_y_continuous(limits=c(0,16),breaks=c(0,5,10,15)) +
     coord_cartesian(xlim=c(0.5,13.5)) +
     theme_bw() +
     labs(y = '# of Stimulation Sites', x = 'Targeted Network', fill = 'Stimulation\nResult') + 
     theme(panel.grid.major.x = element_blank(),
           panel.grid.minor = element_blank(), axis.ticks.x=element_blank(),
           legend.margin=margin(-0.2,-0.1,0,-0.1, "cm"),
           text = element_text(size = 12))



Plot_info <- pivot_longer(CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                                    !CCEP_Data$BrainRegion %in% c('MedialTemporalCortex') &
                         !CCEP_Data$AmpResult %in% c('Not Stimulated','No In-Network Coverage') &
                         !CCEP_Data$Targeted_network %in% c('Unknown'),],
                         cols = c('DisttoDNA','DisttoDNB','DisttoFPN','DisttodATNA',
                                  'DisttodATNB','DisttoSALPMN','DisttoLANG','DisttoCONA',
                                  'DisttoCONB','DisttoSMOT','DisttoPMPPR','DisttoAUD',
                                  'DisttoVIS'))
Plot_info$StimResult <- NA
for (site in c(1:dim(Plot_info)[1])){
  if (Plot_info$Stimulated_networks[site] == 'None'){
    Plot_info$StimResult[site] <- 'No Activity'
  } else if (c(str_remove(Plot_info$name[site],'Distto')) %in% unlist(Plot_info$Stimulated_networks[site])){
    Plot_info$StimResult[site] <- 'Network X Activation'
  } else {
    Plot_info$StimResult[site] <- 'Other Network Activation'
  }
}
Plot_info$StimResult <- factor(Plot_info$StimResult, levels=c('No Activity','Other Network Activation','Network X Activation'))
Plot_table <- Plot_info %>% group_by(value,StimResult)  %>% summarise (n = n()) %>% mutate(freq = n / sum(n), t=sum(n)) %>%
  ungroup() %>% complete(value,StimResult, fill = list(n=0,freq=0))
p1 <- ggplotGrob(ggplot(data = Plot_table, aes(x=value,y=freq,fill=StimResult)) +
       geom_bar(stat='identity') +
       scale_x_continuous(limits=c(0,22),breaks=c(0,5,10,15,20)) +
       #geom_text(aes(y=1.05,label=t),size=3) + 
       scale_fill_manual(values=c("#377EB8","#F8766D", "#4DAF4A")) +
       theme_bw() +
       labs(x = 'Distance to Network X (mm)',y = 'Effect Rate') + 
       theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(), 
             panel.grid.minor = element_blank(),
             text = element_text(size = 12),
             legend.title = element_blank(),legend.margin=margin(-0.2,0.1,0,0, "cm"),
             strip.text = element_text(margin = margin (3,0,3,0)),panel.spacing = unit(0, "lines"),
             strip.background =element_rect(fill=rgb(159,176,193,maxColorValue = 255))))

p2 <- ggplotGrob(ggplot(data = Plot_info[Plot_info$StimResult=='Network X Activation',], aes(x=value,y=DisttoWMBoundary)) +
      annotate('rect',xmin=-Inf,xmax=Inf,ymin=0,ymax=Inf, fill='gray',alpha=0.5) +
      geom_hline(yintercept = 0, linewidth=0.25) +
      geom_line(aes(y=DisttoWMBoundary),stat="smooth",method = "lm", formula = y ~x, color='black', linewidth = 1,alpha = 0.5) + 
      geom_point(aes(y=DisttoWMBoundary,color=StimResult),size=1.5, alpha=0.5) +  facet_wrap(~name) +
      scale_x_continuous(limits=c(0,22),breaks=c(0,5,10,15,20)) +
      scale_y_continuous(limits=c(-12,8),breaks=c(-10,-5,0,5)) +
      scale_color_manual(values=c("#4DAF4A")) +
      theme_bw() + guides(fill='none', color='none') +
      labs(x = 'Distance to Network X (mm)', y = 'White Matter Displacement (mm)') + 
      theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(), 
            panel.grid.minor = element_blank(),axis.title.x = element_text(vjust = 1, hjust = 0.5),
            text = element_text(size = 12),
            strip.text = element_text(margin = margin (3,0,3,0)),panel.spacing = unit(0, "lines"),
            strip.background =element_rect(fill=rgb(159,176,193,maxColorValue = 255))))

g <- grid.arrange(p2,ncol=1, heights=c(2.5,5))
g <- grid.arrange(p2)
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_3a_rev.png',
       plot = g,width = 7.5,height = 4,units = 'in', dpi = 300)

Plot_info <- pivot_longer(CCEP_Data[!CCEP_Data$TissueType %in% c('Subcortical','Out of Brain') &
                                      !CCEP_Data$BrainRegion %in% c('MedialTemporalCortex') &
                                      !CCEP_Data$AmpResult %in% c('Not Stimulated','No In-Network Coverage') &
                                      !CCEP_Data$Targeted_network %in% c('Unknown'),],
                          cols = c("DNA_Percentage","DNB_Percentage","FPN_Percentage","dATNA_Percentage","dATNB_Percentage",
                                   "SALPMN_Percentage","LANG_Percentage","CONA_Percentage","CONB_Percentage","PMPPR_Percentage",
                                   "AUD_Percentage","VIS_Percentage","SMOT_Percentage"))
Plot_info$StimResult <- NA
for (site in c(1:dim(Plot_info)[1])){
  if (Plot_info$Stimulated_networks[site] == 'None'){
    Plot_info$StimResult[site] <- 'No Activity'
  } else if (c(str_remove(Plot_info$name[site],'_Percentage')) %in% unlist(Plot_info$Stimulated_networks[site])){
    Plot_info$StimResult[site] <- 'Network X Activation'
  } else {
    Plot_info$StimResult[site] <- 'Other Network Activation'
  }
}
Plot_table <- data.frame(value=double(),StimResult=character(),t=double(),n=double(),freq=double())
for (percent in seq(0,0.95,by=0.05)){
  for (AmpResult in c('No Activity','Other Network Activation','Network X Activation')){
    current_table <- data.frame(value=percent,
                                StimResult=AmpResult,
                                t=sum(Plot_info$value >= percent &
                                        Plot_info$value < percent+0.05),
                                n=sum(Plot_info$value >= percent &
                                      Plot_info$value < percent+0.05 &
                                      Plot_info$StimResult == AmpResult),
                                freq=sum(Plot_info$value >= percent &
                                           Plot_info$value < percent+0.05 &
                                           Plot_info$StimResult == AmpResult)/
                                     sum(Plot_info$value >= percent &
                                           Plot_info$value < percent+0.05))
   Plot_table=rbind(Plot_table,current_table)
  }
}
Plot_table$StimResult <- factor(Plot_table$StimResult, levels=c('No Activity','Other Network Activation','Network X Activation'))
p1 <- ggplotGrob(ggplot(data = Plot_table, aes(x=value,y=freq,fill=StimResult)) +
  geom_bar(stat='identity') +
  geom_text(aes(y=1.05,label=t),size=3) + 
  scale_x_continuous(limits=c(-0.1,1)) +
  scale_fill_manual(values=c("#377EB8","#F8766D", "#4DAF4A")) +
  theme_bw() +
  labs(x = 'Network X Percentage',y = 'Effect Rate') + 
  theme(panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(), 
        panel.grid.minor = element_blank(),
        text = element_text(size = 12),
        legend.title = element_blank(),legend.margin=margin(-0.2,0.1,0,0, "cm"),
        strip.text = element_text(margin = margin (3,0,3,0)),panel.spacing = unit(0, "lines"),
        strip.background =element_rect(fill=rgb(159,176,193,maxColorValue = 255))))
ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_3a_rev1.png',
       plot = p1,width = 7.5,height = 3,units = 'in', dpi = 300)
