CCEP_CaseList_MSHBM <- function(AverageInfo_Table){
  #determine outcome of stimulation for each stimulation case
  case_list <- unique(AverageInfo_Table[,c('SubjectID','StimSite','StimSiteType','CurrentIntensity','PulseWidth',
                                           'Stim_DNA','Stim_DNB','Stim_FPN','Stim_dATNA','Stim_dATNB',
                                           'Stim_SALPMN','Stim_LANG','Stim_CONA','Stim_CONB','Stim_PMPPR',
                                           'Stim_AUD','Stim_VIS','Stim_SMOT')])
  case_list$Targeted_network <- NA
  case_list$Targeted_network_percentage <- NA
  case_list$AmpResult <- NA
  case_list$Stimulated_networks <- NA
  case_list$Stimulated_networks_n <- NA
  case_list$BOLDFC <- NA
  AverageInfo_Table$AmpResult <- NA
  for (i in 1:dim(case_list)[1]){
    ### determine result using individual parcellations
    #isolate CCEPs for a given stim case
    current_indices <- AverageInfo_Table$SubjectID==case_list$SubjectID[i] & 
      AverageInfo_Table$StimSite==case_list$StimSite[i] &
      AverageInfo_Table$CurrentIntensity==case_list$CurrentIntensity[i]
    
    current_data <- AverageInfo_Table[current_indices,]
    case_list$Targeted_network[i] <- unique(as.character(current_data$Stim_Network))
    if (case_list$Targeted_network[i] != 'Unknown'){
      case_list$Targeted_network_percentage[i] <- as.numeric(unique(current_data[,paste0('Stim_',case_list$Targeted_network[i])]))
    }
    stimulated_networks <- unique(as.character(current_data$Response_Network[current_data$Response_Magnitude > 2]))
    case_list$Stimulated_networks_n[i] <- length(stimulated_networks)
    
    if (length(stimulated_networks) > 0){
      case_list$Stimulated_networks[i] <- list(stimulated_networks)
      if (sum(current_data$Category == 'Within-Network') >= 1){
        if (case_list$Targeted_network[i] %in% stimulated_networks){
          if (length(stimulated_networks) == 1){
            case_list$AmpResult[i] <- 'Hit + Specific'
          } else {
            case_list$AmpResult[i] <- 'Hit + Nonspecific'
          }
        } else {
          if (length(stimulated_networks) == 1){
            case_list$AmpResult[i] <- 'Miss + Specific'
          } else {
            case_list$AmpResult[i] <- 'Miss + Nonspecific'
          }
        }
      } else {
        case_list$AmpResult[i] <- 'No In-Network Coverage'
      }
    } else {
      case_list$Stimulated_networks[i] <- 'None'
      case_list$AmpResult[i] <- 'No Effect'
    }
    AverageInfo_Table$AmpResult[current_indices] <- case_list$AmpResult[i]
    
    ### determine BOLD RSFC vs CCEP correlation strength
    case_list$BOLDFC[i] <- FisherZ(cor(current_data$Response_Magnitude, current_data$Response_BOLDFC, method = c("pearson")))
  }
  
  ###### plot examples of different stimulation effects
  #sites_of_interest <- c(8,180,4,222,164)
  sites_of_interest <- c(8,180,4,222,201)
  indices_of_interest <- rep(FALSE,dim(AverageInfo_Table)[1])
  for (i in c(1:length(sites_of_interest))){
    current_indices <- AverageInfo_Table$SubjectID %in% case_list$SubjectID[sites_of_interest[i]] & 
      AverageInfo_Table$StimSite %in% case_list$StimSite[sites_of_interest[i]] &
      AverageInfo_Table$CurrentIntensity %in% case_list$CurrentIntensity[sites_of_interest[i]]
    indices_of_interest <- indices_of_interest | current_indices
  }
  Plot_info <- AverageInfo_Table[indices_of_interest,]
  Plot_info$AmpResult <- factor(Plot_info$AmpResult, levels = c('No Effect','No In-Network Coverage','Hit + Specific','Hit + Nonspecific','Miss + Specific','Miss + Nonspecific'))
  Plot_info$Response_Network <- factor(Plot_info$Response_Network, levels = c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG',
                                                                             'CONA','CONB','SMOT','PMPPR','AUD','VIS'))
  ggplot(Plot_info, aes(x=Response_Network, y=Response_Magnitude, color = Category)) + 
    geom_hline(yintercept=2, linetype="dashed", color = "gray", linewidth=1) + 
    geom_boxplot(width=0.2, outlier.shape = NA) +
    gghalves::geom_half_point(side='l', alpha=0.5, size=1, transformation=position_jitter(width=0.05,height=0),show.legend = FALSE) +
    scale_fill_manual(values=c('red','#606163')) + 
    scale_color_manual(breaks=c('Within-Network'), values=c('red','#606163'), labels=c('Stimulated Network')) + 
    scale_x_discrete(labels=c('DN-A','DN-B','FPN','dATN-A','dATN-B','SAL/PMN','LANG',
                              'CON-A','CON-B','SMOT','PM-PPr','AUD','VIS')) +
    scale_y_continuous(limits=c(0,10),breaks=c(0,2,4,6,8,10)) +
    facet_wrap(~AmpResult, ncol=1) + theme_bw() +
    ylab('Max Amplitude (Z)') + xlab('Response Network') +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),panel.spacing = unit(0, "lines"),
          strip.text.x = element_text(size = 12, margin = margin(0.05,0,0.05,0, "cm")),
          legend.margin=margin(-0.2,0.1,0,0, "cm"),plot.title = element_text(hjust = 0.5,size=14),
          legend.box.background = element_rect(colour = "black"),legend.position=c(0.805,0.966),
          legend.title=element_blank(), text = element_text(size = 12))
  ggsave('/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_SuppFigure1d.png',
         plot = last_plot(),width = 4.5,height = 5,units = 'in')  
  structure.AverageInfo_Table <- AverageInfo_Table
  structure.case_list <- case_list
  return(list(AverageInfo_Table = AverageInfo_Table, case_list = case_list))
}