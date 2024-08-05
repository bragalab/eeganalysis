FunctionalMapping_SiteConclusion <- function(CurrentData, ConclusionType){
  #determine task list of interest
  if (ConclusionType == 'Reading'){
    TaskList <- c('Reading')
  } else if (ConclusionType == 'Reciting'){
    TaskList <- c('ABCs','Happy Birthday','Counting','Repeat')
  } else if (ConclusionType == 'Naming'){
    TaskList <- c('Naming')
  } else if (ConclusionType == 'Comprehension'){
    TaskList <- c('Comprehension','Math','Commands','Tasks','Recall')
  } else if (ConclusionType == 'Motor'){
    TaskList <- c('None','Reading','ABCs','Hand Movement','Happy Birthday','Look Straight',
                  'Sniffing','Naming','Counting','Math','Commands','Comprehension',
                  'Look Right','Recall','Arms Up','Tasks','hand motor','Repeat')
  } else if (ConclusionType == 'Sensory'){
    TaskList <- c('None','Reading','ABCs','Hand Movement','Happy Birthday','Look Straight',
                  'Sniffing','Naming','Counting','Math','Commands','Comprehension',
                  'Look Right','Recall','Arms Up','Tasks','hand motor','Repeat')
  }
  
  #focus on trials used for the given conclusion type
  CurrentData <- CurrentData[CurrentData$Task %in% TaskList,]
  
  #determine conclusion
  if (dim(CurrentData)[1] == 0){ #there are no trials of interest
    Conclusion <- 'NotTested'
    Symptom <- NA
  } else if (all(is.na(CurrentData[,paste0(ConclusionType,'Positive')]))){ #there are no trials with an active task 
      if ((all(CurrentData$SiteType == 'D') & max(CurrentData$CurrentIntensity) >= 7) | (all(CurrentData$SiteType %in% c('S','G')) & max(CurrentData$CurrentIntensity) >= 15)){ #and they reached the final current intensity
        if (all(CurrentData$Seizure[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, final current intensity, with seizure
          Conclusion <- 'No Result+SZ'
        } else if (all(CurrentData$AfterDischarges[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, final current intensity, with after discharges
          Conclusion <- 'No Result+AD'
        } else if (all(CurrentData$AfterDischarges[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)] |
                       CurrentData$Seizure[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, final current intensity, with after discharges/seizures
          Conclusion <- 'No Result+AD'
        } else { #no symptoms, final current intensity, no seizures or discharges
          Conclusion <- 'No Result'
        }
      } else {#no symptoms, final current intensity not reached
        if (all(CurrentData$Seizure[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, low current intensity, with seizure
          Conclusion <- 'SZ'
        } else if (all(CurrentData$AfterDischarges[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, low current intensity, with after discharges
          Conclusion <- 'AD'
        } else if (all(CurrentData$AfterDischarges[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)] |
                       CurrentData$Seizure[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, low current intensity, with after discharges/seizures
          Conclusion <- 'AD'
        } else { #no symptoms, final current intensity, no seizures or discharges
          Conclusion <- 'LowCurrent'
        }  
      }
      Symptom <- NA
  } else { #there are relevant tasks with which we can make a conclusion about functional deficits
    #remove NAs
    CurrentData <- CurrentData[!is.na(CurrentData[,paste0(ConclusionType,'Positive')]),]
      if (all(!CurrentData[,paste0(ConclusionType,'Positive')])) { #and there were no symptoms
        Symptom <- NA
        if ((all(CurrentData$SiteType == 'D') & max(CurrentData$CurrentIntensity) >= 7) | (all(CurrentData$SiteType %in% c('S','G')) & max(CurrentData$CurrentIntensity) >= 15)){ #and they reached the final current intensity
          if (all(CurrentData$Seizure[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, final current intensity, with seizure
            Conclusion <- 'Negative+SZ'
          } else if (all(CurrentData$AfterDischarges[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, final current intensity, with after discharges
            Conclusion <- 'Negative+AD'
          } else if (all(CurrentData$AfterDischarges[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)] |
                         CurrentData$Seizure[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, final current intensity, with after discharges/seizures
            Conclusion <- 'Negative+AD'
          } else { #no symptoms, final current intensity, no seizures or discharges
            Conclusion <- 'Negative'
          }
        } else {#no symptoms, final current intensity not reached
          if (all(CurrentData$Seizure[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, low current intensity, with seizure
            Conclusion <- 'SZ'
          } else if (all(CurrentData$AfterDischarges[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, low current intensity, with after discharges
            Conclusion <- 'AD'
          } else if (all(CurrentData$AfterDischarges[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)] |
                         CurrentData$Seizure[CurrentData$CurrentIntensity == max(CurrentData$CurrentIntensity)])){ #no symptoms, low current intensity, with after discharges/seizures
            Conclusion <- 'AD'
          } else { #no symptoms, final current intensity, no seizures or discharges
            Conclusion <- 'LowCurrent'
          }  
        }
      } else { #there were symptoms
        if (all(CurrentData$Seizure[CurrentData %>% pull(paste0(ConclusionType,'Positive'))])){ #and they were all concurrent with seizures
          Conclusion <- 'Positive+SZ'
        } else if (all(CurrentData$AfterDischarges[CurrentData %>% pull(paste0(ConclusionType,'Positive'))])){ #and they were all concurrent with ADs
          Conclusion <- 'Positive+AD'
        } else if (all(CurrentData$AfterDischarges[CurrentData %>% pull(paste0(ConclusionType,'Positive'))] |
                       CurrentData$Seizure[CurrentData %>% pull(paste0(ConclusionType,'Positive'))])){ #and they were all concurrent with ADs/seizures
          Conclusion <- 'Positive+AD'
        } else {
          Conclusion <- 'Positive'
        }
        #build symptom list
        SZSymptomList <- CurrentData[CurrentData[,paste0(ConclusionType,'Positive')] & CurrentData$Seizure, paste0(ConclusionType,'Symptom')] %>% summarise(a=toString(!!as.symbol(paste0(ConclusionType,'Symptom'))))
        if (SZSymptomList$a != ''){
          SZSymptomList <- paste(unique(unlist(strsplit(SZSymptomList$a, ","))), '+SZ', collapse=',')
        } else { SZSymptomList <- character()}
        ADSymptomList <- CurrentData[CurrentData[,paste0(ConclusionType,'Positive')] & CurrentData$AfterDischarges & !CurrentData$Seizure, paste0(ConclusionType,'Symptom')] %>% summarise(a=toString(!!as.symbol(paste0(ConclusionType,'Symptom'))))
        if (ADSymptomList$a != ''){
          ADSymptomList <- paste(unique(unlist(strsplit(ADSymptomList$a, ","))), '+AD', collapse=',')
        } else { ADSymptomList <- character()}
        TrueSymptomList <- CurrentData[CurrentData[,paste0(ConclusionType,'Positive')] & !CurrentData$AfterDischarges & !CurrentData$Seizure, paste0(ConclusionType,'Symptom')] %>% summarise(a=toString(!!as.symbol(paste0(ConclusionType,'Symptom'))))
        if (TrueSymptomList$a != ''){
          TrueSymptomList <- paste(unique(unlist(strsplit(TrueSymptomList$a, ","))), collapse=',')
        } else { TrueSymptomList <- character()}
        Symptom <- paste(c(SZSymptomList,ADSymptomList,TrueSymptomList),collapse=',')
      }
  }

  return(list(Conclusion = Conclusion, Symptom = Symptom))
}
















