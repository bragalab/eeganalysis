CCEP_LoadData_MSHBM <- function(){
  #Load CCEP Data
  AverageInfo_Table <- read_excel("/Users/cce3182/Desktop/b1134/analysis/ccyr/StimProject/StimResponsePairInfoTable_MSHBM.xlsx")
  AverageInfo_Table$Response_BOLDFC <- FisherZ(AverageInfo_Table$Response_BOLDFC)
  colnames(AverageInfo_Table) <- str_replace(colnames(AverageInfo_Table), '_Percentage', '')
  AverageInfo_Table <- AverageInfo_Table[AverageInfo_Table$DistancetoStim > 20,]
  AverageInfo_Table$Stim_SMOT <- apply(AverageInfo_Table[,c('Stim_SMOTA','Stim_SMOTB')], 1, FUN=sum)
  AverageInfo_Table$Response_SMOT <- apply(AverageInfo_Table[,c('Response_SMOTA','Response_SMOTB')], 1, FUN=sum)  
  Networks <- c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG',
                'CONA','CONB','PMPPR','AUD','VIS','SMOT')
  AverageInfo_Table$Stim_Network <- NA
  AverageInfo_Table$Response_Network <- NA
  AverageInfo_Table$Identity <- NA
  AverageInfo_Table$Category <- NA
  for (i in 1:dim(AverageInfo_Table)[1]){
    #determine identity with individual parcellations
    if (max(AverageInfo_Table[i,c('Stim_DNA','Stim_DNB','Stim_FPN','Stim_dATNA',
                                  'Stim_dATNB','Stim_SALPMN','Stim_LANG','Stim_CONA',
                                  'Stim_CONB','Stim_PMPPR',
                                  'Stim_AUD','Stim_VIS','Stim_SMOT')]) < 0.1){
      AverageInfo_Table$Stim_Network[i] <- 'Unknown'
    } else {
      AverageInfo_Table$Stim_Network[i] <- Networks[which.max(AverageInfo_Table[i,c('Stim_DNA','Stim_DNB','Stim_FPN','Stim_dATNA',
                                                                                    'Stim_dATNB','Stim_SALPMN','Stim_LANG','Stim_CONA',
                                                                                    'Stim_CONB','Stim_PMPPR',
                                                                                    'Stim_AUD','Stim_VIS','Stim_SMOT')])]
    }
    if (max(AverageInfo_Table[i,c('Response_DNA','Response_DNB','Response_FPN','Response_dATNA',
                                  'Response_dATNB','Response_SALPMN','Response_LANG','Response_CONA',
                                  'Response_CONB','Response_PMPPR',
                                  'Response_AUD','Response_VIS','Response_SMOT')]) < 0.1){

      AverageInfo_Table$Response_Network[i] <- 'Unknown'
      
    } else {
      AverageInfo_Table$Response_Network[i] <- Networks[which.max(AverageInfo_Table[i,c('Response_DNA','Response_DNB','Response_FPN','Response_dATNA',
                                                                                        'Response_dATNB','Response_SALPMN','Response_LANG','Response_CONA',
                                                                                        'Response_CONB','Response_PMPPR',
                                                                                        'Response_AUD','Response_VIS','Response_SMOT')])]
    }
    
    AverageInfo_Table$Identity[i] <- paste0(AverageInfo_Table$Stim_Network[i],
                                            '-',AverageInfo_Table$Response_Network[i])
    if (AverageInfo_Table$Stim_Network[i] == AverageInfo_Table$Response_Network[i]){
      AverageInfo_Table$Category[i] <- 'Within-Network'
    } else {
      AverageInfo_Table$Category[i] <- 'Across-Network'
    }
  }
  return(AverageInfo_Table)
}