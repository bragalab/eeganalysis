CCEP_LoadData <- function(){
  #Load CCEP Data
  AverageInfo_Table <- read_excel("/Users/cce3182/Desktop/b1134/analysis/ccyr/StimProject/StimResponsePairInfoTable.xlsx")
  AverageInfo_Table$Response_BOLDFC <- FisherZ(AverageInfo_Table$Response_BOLDFC)
  colnames(AverageInfo_Table) <- str_replace(colnames(AverageInfo_Table), '_Percentage', '')
  AverageInfo_Table <- AverageInfo_Table[AverageInfo_Table$DistancetoStim > 20,]
  Networks <- str_remove(colnames(AverageInfo_Table)[c(11:13,17:19)],'Stim_')
  YeoNetworks <- str_remove(colnames(AverageInfo_Table)[20:31],'Stim_')
  AverageInfo_Table$Stim_Network <- NA
  AverageInfo_Table$Response_Network <- NA
  AverageInfo_Table$Identity <- NA
  AverageInfo_Table$Category <- NA
  AverageInfo_Table$Stim_YeoNetwork <- NA
  AverageInfo_Table$Response_YeoNetwork <- NA
  AverageInfo_Table$YeoIdentity <- NA
  AverageInfo_Table$YeoCategory <- NA
  for (i in 1:dim(AverageInfo_Table)[1]){
    #determine identity with individual parcellations
    if (max(AverageInfo_Table[i,c(11:13,17:19)]) < 0.1 | max(AverageInfo_Table[i,c(38:40,44:46)]) < 0.1){
      AverageInfo_Table$Stim_Network[i] <- 'Unknown'
      AverageInfo_Table$Response_Network[i] <- 'Unknown'
      AverageInfo_Table$Identity[i] <- 'Unknown'
      AverageInfo_Table$Category[i] <- 'Unknown'
    }
    else{
      AverageInfo_Table$Stim_Network[i] <- Networks[which.max(AverageInfo_Table[i,c(11:13,17:19)])]
      AverageInfo_Table$Response_Network[i] <- Networks[which.max(AverageInfo_Table[i,c(38:40,44:46)])]
      AverageInfo_Table$Identity[i] <- paste0(AverageInfo_Table$Stim_Network[i],
                                              '-',AverageInfo_Table$Response_Network[i])
      if (AverageInfo_Table$Stim_Network[i] == AverageInfo_Table$Response_Network[i]){
        AverageInfo_Table$Category[i] <- 'Within-Network'
      } else {
        AverageInfo_Table$Category[i] <- 'Across-Network'
      }
    }
    #determine identity with yeo parcellations
    if (max(AverageInfo_Table[i,20:31]) < 0.1 | max(AverageInfo_Table[i,46:57]) < 0.1){
      AverageInfo_Table$Stim_YeoNetwork[i] <- 'Unknown'
      AverageInfo_Table$Response_YeoNetwork[i] <- 'Unknown'
      AverageInfo_Table$YeoIdentity[i] <- 'Unknown'
      AverageInfo_Table$YeoCategory[i] <- 'Unknown'
    }
    else{
      AverageInfo_Table$Stim_YeoNetwork[i] <- YeoNetworks[which.max(AverageInfo_Table[i,20:31])]
      AverageInfo_Table$Response_YeoNetwork[i] <- YeoNetworks[which.max(AverageInfo_Table[i,46:57])]
      AverageInfo_Table$YeoIdentity[i] <- paste0(AverageInfo_Table$Stim_YeoNetwork[i],
                                                 '-',AverageInfo_Table$Response_YeoNetwork[i])
      if (AverageInfo_Table$Stim_YeoNetwork[i] == AverageInfo_Table$Response_YeoNetwork[i]){
        AverageInfo_Table$YeoCategory[i] <- 'Within-Network'
      } else {
        AverageInfo_Table$YeoCategory[i] <- 'Across-Network'
      }
    }
  }
  AverageInfo_Table <- AverageInfo_Table[AverageInfo_Table$Identity != 'Unknown',]
  return(AverageInfo_Table)
}