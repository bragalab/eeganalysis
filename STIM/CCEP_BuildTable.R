CCEP_BuildTable <- function(site_list){
#Load all electrode information table
sub_list <- unique(site_list$SubjectID)
All_info <- data.frame(SubjectID=character(),Session=character(),ChannelID=character(),Coords_x=double(),Coords_y=double(),Coords_z=double(),
                       CoordsBipol_1_x=double(),CoordsBipol_1_y=double(),CoordsBipol_1_z=double(),CoordsBipol_2_x=double(),
                       CoordsBipol_2_y=double(),CoordsBipol_2_z=double(),InterElectrodeDistance=double(),DisttoWMBoundary=double(),Orientation=double(),
                       TissueType=character(),BrainRegion=character(), DisttoDNANetwork=double(), DisttoDNBNetwork=double(),
                       DisttoFPNA=double(), DisttoFPNB=double(), DisttodATNA=double(), DisttodATNB=double(),
                       DisttoSAL=double(), DisttoLANG=double(), DisttoUNI=double())
for (SubjectID in sub_list){ 
  elec_recon_dir <- paste0('/Users/cce3182/Desktop/b1134/processed/fs/',SubjectID,'/',SubjectID, '/elec_recon')
  Electrode_info <- read_excel(paste0(elec_recon_dir,'/',SubjectID,'_','SiteInfoTable_bipolar_appended.xlsx'))
  Electrode_info$SubjectID <- SubjectID
  All_info <- rbind(All_info, Electrode_info)
}
Electrode_info <- All_info
rm(All_info)

#add information about stimulation results
Electrode_info$Targeted_network <- NA
Electrode_info$Targeted_network_percentage <- NA
Electrode_info$DisttoTargetedNetwork <- NA
Electrode_info$NearNetworks <- NA
Electrode_info$AmpResult <- NA
Electrode_info$Stimulated_networks <- NA
Electrode_info$Stimulated_networks_n <- NA
Electrode_info$Max_Current <- NA
Electrode_info$BOLDFC <- NA
Electrode_info$t_test <- NA
Electrode_info$StimSiteType <- NA
for (i in 1:dim(Electrode_info)[1]){
  #find stim site within all electrode info table
  MirroredChannelID <- paste0(unlist(str_split(Electrode_info$ChannelID[i],'-'))[2],'-',unlist(str_split(Electrode_info$ChannelID[i],'-'))[1])
  index <- (site_list$StimSite==Electrode_info$ChannelID[i] | site_list$StimSite==MirroredChannelID)  & 
    site_list$SubjectID==Electrode_info$SubjectID[i]
  
  #add additional stim site info to all electrode table
  if (sum(index) == 1){ #stimulated
    Electrode_info$Targeted_network[i] <- site_list$Targeted_network[index]
    Electrode_info$Targeted_network_percentage[i] <- site_list$Targeted_network_percentage[index]
    NetworkDistances <- as.data.frame(Electrode_info[i,c('DisttoDNA','DisttoDNB','DisttoFPNA','DisttoSAL','DisttoLANG','DisttoUNI')])
    Electrode_info$DisttoTargetedNetwork[i] <- as.numeric(NetworkDistances[colnames(NetworkDistances)==paste0('Distto',Electrode_info$Targeted_network[i])])
    Electrode_info$NearNetworks[i] <- sum(NetworkDistances <= 5)
    Electrode_info$AmpResult[i] <- site_list$AmpResult[index]
    Electrode_info$Stimulated_networks[i] <- site_list$Stimulated_networks[index]
    Electrode_info$Stimulated_networks_n[i] <- site_list$Stimulated_networks_n[index]
    Electrode_info$Max_Current[i] <- site_list$Max_Current[index]
    Electrode_info$BOLDFC[i] <- site_list$BOLDFC[index]
    Electrode_info$t_test[i] <- site_list$t_test[index]
    Electrode_info$StimSiteType[i] <- site_list$StimSiteType[index]
  } else { #not stimulated
    NetworkDistances <- as.data.frame(Electrode_info[i,c('DisttoDNA','DisttoDNB','DisttoFPNA','DisttoSAL','DisttoLANG','DisttoUNI')])
    Electrode_info$NearNetworks[i] <- sum(NetworkDistances <= 5)
    Electrode_info$AmpResult[i] <- 'Not Stimulated'
    Electrode_info$Max_Current[i] <- 0
    Electrode_info$StimSiteType[i] <- 'Not Stimulated'
  }
}
Electrode_info <- Electrode_info[,!colnames(Electrode_info) %in% c("Coords_x","Coords_y","Coords_z",
                                  "CoordsBipol_1_x","CoordsBipol_1_y","CoordsBipol_1_z","CoordsBipol_2_x",
                                  "CoordsBipol_2_y","CoordsBipol_2_z","InterElectrodeDistance","Orientation")]
return(Electrode_info)
}