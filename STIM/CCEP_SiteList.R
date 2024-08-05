CCEP_SiteList <- function(case_list){
  #condense results across stimulation intensities so that there's one outcome per stimulation site
  site_list <- unique(case_list[,c('SubjectID','StimSite','StimSiteType','Targeted_network','Targeted_network_percentage')])
  site_list$AmpResult <- NA
  site_list$Stimulated_networks <- NA
  site_list$Stimulated_networks_n <- NA
  site_list$Max_Current <- NA
  site_list$BOLDFC <- NA
  site_list$t_test <- NA
  for (i in 1:dim(site_list)[1]){
    current_indices <- case_list$SubjectID==site_list$SubjectID[i] & 
      case_list$StimSite==site_list$StimSite[i]
    current_data <- case_list[current_indices,]
    site_list$Max_Current[i] <- max(current_data$CurrentIntensity)
    
    #determine result of stimulation using individual parcellations
    if (all(current_data$AmpResult == 'No Effect')){ 
      site_list$AmpResult[i] <- 'No Effect'
      site_list$Stimulated_networks_n[i] <- 0
      site_list$Stimulated_networks[i] <- 'None'
      index <- which.max(current_data$CurrentIntensity)
      site_list$BOLDFC[i] <- current_data$BOLDFC[index]
    } else {
        if (any(current_data$AmpResult == 'No In-Network Coverage')){ 
          tmp_data <- current_data[current_data$AmpResult == 'No In-Network Coverage',]
          site_list$AmpResult[i] <- 'No In-Network Coverage'
        } else if (any(current_data$AmpResult == 'Hit + Specific')){ 
          tmp_data <- current_data[current_data$AmpResult == 'Hit + Specific',]
          site_list$AmpResult[i] <- 'Hit + Specific'
        }  else if (any(current_data$AmpResult == 'Hit + Nonspecific')){ 
          tmp_data <- current_data[current_data$AmpResult == 'Hit + Nonspecific',]
          site_list$AmpResult[i] <- 'Hit + Nonspecific'
        } else if (any(current_data$AmpResult == 'Miss + Specific')){ 
          tmp_data <- current_data[current_data$AmpResult == 'Miss + Specific',]
          site_list$AmpResult[i] <- 'Miss + Specific'
        } else if (any(current_data$AmpResult == 'Miss + Nonspecific')){ 
          tmp_data <- current_data[current_data$AmpResult == 'Miss + Nonspecific',]
          site_list$AmpResult[i] <- 'Miss + Nonspecific'
        }  
      site_list$Stimulated_networks_n[i] <- min(tmp_data$Stimulated_networks_n)
      tmp_data <- tmp_data[tmp_data$Stimulated_networks_n ==  min(tmp_data$Stimulated_networks_n),]
      tmp_data <- tmp_data[tmp_data$CurrentIntensity ==  max(tmp_data$CurrentIntensity),]
      site_list$Stimulated_networks[i] <- tmp_data$Stimulated_networks
      site_list$BOLDFC[i] <- tmp_data$BOLDFC
      site_list$t_test[i] <- tmp_data$t_test
    }
  }
  return(site_list)
}