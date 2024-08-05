FunctionalMapping_Summary <- function(InfoTable){
  source('/Users/cce3182/Desktop/b1134/analysis/ccyr/FunctionalMappingProject/FunctionalMapping_SiteConclusion.R')
  ################# initialize variables
  SiteSummary <- unique(InfoTable[,c('SubjectID','Session','StimulationSite','StimulationType','SiteType')])
  SiteSummary$TaskList <- rep(list(I(list())), nrow(SiteSummary))
  SiteSummary$AfterDischarges <- NA
  SiteSummary$Seizure <- NA
  SiteSummary$MaxCurrent <- NA 
  SiteSummary$CaveatList <- rep(list(I(list())), nrow(SiteSummary))
  SiteSummary$ReadingConclusion <- NA
  SiteSummary$ReadingSymptomList <- NA
  SiteSummary$RecitingConclusion <- NA
  SiteSummary$RecitingSymptomList <- NA
  SiteSummary$NamingConclusion <- NA
  SiteSummary$NamingSymptomList <- NA
  SiteSummary$ComprehensionConclusion <- NA
  SiteSummary$ComprehensionSymptomList <- NA
  SiteSummary$MotorConclusion <- NA
  SiteSummary$MotorSymptomList <- NA
  SiteSummary$SensoryConclusion <- NA
  SiteSummary$SensorySymptomList <- NA
  ################# assess each stimulation site
  for (i in 1:dim(SiteSummary)[1]){
    #all trials at current stimulation site
    CurrentData <- InfoTable[InfoTable$SubjectID == SiteSummary$SubjectID[i] & 
                               InfoTable$Session == SiteSummary$Session[i] &
                               InfoTable$StimulationSite == SiteSummary$StimulationSite[i],]
    
    #list of all tasks used at this site
    SiteSummary$TaskList[[i]] <- append(SiteSummary$TaskList[[i]], unlist(strsplit(unique(CurrentData$Task[!is.na(CurrentData$Task)]),',')))
    
    #any adverse effects
    SiteSummary$AfterDischarges[i] <- any(CurrentData$AfterDischarges)
    SiteSummary$Seizure[i] <- any(CurrentData$Seizure)   
    
    #max current intensity used at this site across all tasks
    SiteSummary$MaxCurrent[i] <- max(CurrentData$CurrentIntensity)
    
    #list of all caveats at this site
    if (sum(!is.na(CurrentData$Caveat)) > 0) {
      SiteSummary$CaveatList[[i]] <- append(SiteSummary$CaveatList[[i]], unlist(strsplit(unique(CurrentData$Caveat[!is.na(CurrentData$Caveat)]),',')))
      CurrentData <- CurrentData[is.na(CurrentData$Caveat),]
    }
    
    #Reading Conclusion
    SiteInfo <- FunctionalMapping_SiteConclusion(CurrentData, 'Reading')
    SiteSummary$ReadingConclusion[i] <- SiteInfo$Conclusion
    SiteSummary$ReadingSymptomList[i] <- SiteInfo$Symptom
    
    #Reciting Conclusion
    SiteInfo <- FunctionalMapping_SiteConclusion(CurrentData, 'Reciting')
    SiteSummary$RecitingConclusion[i] <- SiteInfo$Conclusion
    SiteSummary$RecitingSymptomList[i] <- SiteInfo$Symptom
    
    #Naming Conclusion
    SiteInfo <- FunctionalMapping_SiteConclusion(CurrentData, 'Naming')
    SiteSummary$NamingConclusion[i] <- SiteInfo$Conclusion
    SiteSummary$NamingSymptomList[i] <- SiteInfo$Symptom
    
    #Comprehension Conclusion
    SiteInfo <- FunctionalMapping_SiteConclusion(CurrentData, 'Comprehension')
    SiteSummary$ComprehensionConclusion[i] <- SiteInfo$Conclusion
    SiteSummary$ComprehensionSymptomList[i] <- SiteInfo$Symptom
    
    #Motor Conclusion
    SiteInfo <- FunctionalMapping_SiteConclusion(CurrentData, 'Motor')
    SiteSummary$MotorConclusion[i] <- SiteInfo$Conclusion
    SiteSummary$MotorSymptomList[i] <- SiteInfo$Symptom
    
    #Sensory Conclusion
    SiteInfo <- FunctionalMapping_SiteConclusion(CurrentData, 'Sensory')
    SiteSummary$SensoryConclusion[i] <- SiteInfo$Conclusion
    SiteSummary$SensorySymptomList[i] <- SiteInfo$Symptom
    
    #Language Conclusion
    #if (!SiteSummary[i,paste0(Task,'Conclusion')] %in% c('NotTested')){
    #  if (SiteSummary[i,paste0(Task,'Conclusion')] %in% c('Positive') & (SiteSummary$LANG[i] > NetworkThreshold & SiteSummary$DisttoWMBoundary[i] >= WhiteThreshold)) {
    #    SiteSummary$LanguageConclusion[i] <- 'TruePositive'
    #  }
    #  else if (SiteSummary[i,paste0(Task,'Conclusion')] %in% c('Positive') & (SiteSummary$LANG[i] <= NetworkThreshold | SiteSummary$DisttoWMBoundary[i] < WhiteThreshold)) {
    #    SiteSummary$LanguageConclusion[i] <- 'FalsePositive'
    #  }
    #  else if (SiteSummary[i,paste0(Task,'Conclusion')] %in% c('Negative','Negative+SZ','Negative+AD') & (SiteSummary$LANG[i] > NetworkThreshold & SiteSummary$DisttoWMBoundary[i] >= WhiteThreshold)) {
    #    SiteSummary$LanguageConclusion[i] <- 'FalseNegative'
    #  }
    #  else if (SiteSummary[i,paste0(Task,'Conclusion')] %in% c('Negative','Negative+SZ','Negative+AD') & (SiteSummary$LANG[i] <= NetworkThreshold | SiteSummary$DisttoWMBoundary[i] < WhiteThreshold)) {
    #    SiteSummary$LanguageConclusion[i] <- 'TrueNegative'
    #  }
    #  else {
    #    SiteSummary$LanguageConclusion[i] <- 'Inconclusive'
    #  }
    #}

    
    #list of all head/face/eye/gaze related symptoms at this site    
    #HFEGindices <- (mapply(grepl, rep(dATNASymptomList,dim(CurrentData)[1]), CurrentData$MotorSymptom)) | 
    #  (mapply(grepl, rep(dATNASymptomList,dim(CurrentData)[1]), CurrentData$SensorySymptom))
    #
    #if (any(HFEGindices)){ #if there was any head/face/eye/gaze related symptoms
    #  if (all(CurrentData$AfterDischarges[HFEGindices] | CurrentData$Seizure[HFEGindices], na.rm=TRUE)){ #and they were concurrent with ADs or SZs
    #    SiteSummary$HFEGConclusion[i] <- 'Inconclusive'
    #  }
    #  else {
    #    SiteSummary$HFEGConclusion[i] <- 'Positive'
    #  }
    #} else { #there were no head/face/eye/gaze related symptoms
    #  SiteSummary$HFEGConclusion[i] <- 'Negative'
    #}
    
    #dATNA Conclusion
    #if (SiteSummary$HFEGConclusion[i] == 'Positive' & (SiteSummary$dATNA[i] > dATNAThreshold & SiteSummary$DisttoWMBoundary[i] >= WhiteThreshold)) {
    #  SiteSummary$dATNAConclusion[i] <- 'TruePositive'
    #} else if (SiteSummary$HFEGConclusion[i] == 'Positive' & (SiteSummary$dATNA[i] <= dATNAThreshold | SiteSummary$DisttoWMBoundary[i] < WhiteThreshold)) {
    #  SiteSummary$dATNAConclusion[i] <- 'FalsePositive'
    #} else if (SiteSummary$HFEGConclusion[i] == 'Negative' & (SiteSummary$dATNA[i] > dATNAThreshold & SiteSummary$DisttoWMBoundary[i] >= WhiteThreshold)) {
    #  SiteSummary$dATNAConclusion[i] <- 'FalseNegative'
    #} else if (SiteSummary$HFEGConclusion[i] == 'Negative' & (SiteSummary$dATNA[i] <= dATNAThreshold | SiteSummary$DisttoWMBoundary[i] < WhiteThreshold)) {
    #  SiteSummary$dATNAConclusion[i] <- 'TrueNegative'
    #} else {
    #  SiteSummary$dATNAConclusion[i] <- 'Inconclusive'
    #}
  }
  
  #remove Monopolar stimulation
  SiteSummary <- SiteSummary[!(SiteSummary$StimulationType == 'Monopolar'),]
  
  #factor variables
  SiteSummary$ReadingConclusion <- factor(SiteSummary$ReadingConclusion, levels=c('Positive','Positive+SZ','Positive+AD','Negative','Negative+SZ','Negative+AD','No Result','No Result+SZ','No Result+AD','SZ','AD','LowCurrent','NotTested'))
  SiteSummary$RecitingConclusion <- factor(SiteSummary$RecitingConclusion, levels=c('Positive','Positive+SZ','Positive+AD','Negative','Negative+SZ','Negative+AD','No Result','No Result+SZ','No Result+AD','SZ','AD','LowCurrent','NotTested'))
  SiteSummary$NamingConclusion <- factor(SiteSummary$NamingConclusion, levels=c('Positive','Positive+SZ','Positive+AD','Negative','Negative+SZ','Negative+AD','No Result','No Result+SZ','No Result+AD','SZ','AD','LowCurrent','NotTested'))
  SiteSummary$MotorConclusion <- factor(SiteSummary$MotorConclusion, levels=c('Positive','Positive+SZ','Positive+AD','Negative','Negative+SZ','Negative+AD','No Result','No Result+SZ','No Result+AD','SZ','AD','LowCurrent','NotTested'))
  SiteSummary$SensoryConclusion <- factor(SiteSummary$SensoryConclusion, levels=c('Positive','Positive+SZ','Positive+AD','Negative','Negative+SZ','Negative+AD','No Result','No Result+SZ','No Result+AD','SZ','AD','LowCurrent','NotTested'))
  #SiteSummary$LanguageConclusion <- factor(SiteSummary$LanguageConclusion, levels=c('Inconclusive','TrueNegative','FalseNegative','TruePositive','FalsePositive'))
  #SiteSummary$HFEGConclusion <- factor(SiteSummary$HFEGConclusion, levels=c('Inconclusive','Negative','Positive'))
  #SiteSummary$dATNAConclusion <- factor(SiteSummary$dATNAConclusion, levels=c('Inconclusive','TrueNegative','FalseNegative','TruePositive','FalsePositive'))  
  return(SiteSummary)
}