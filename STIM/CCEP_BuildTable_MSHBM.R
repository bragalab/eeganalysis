CCEP_BuildTable_MSHBM <- function(site_list){
  #Load all electrode information table
  sub_list <- unique(site_list$SubjectID)
  All_info <- data.frame(SubjectID=character(),ChannelID=character(),Coords_x=double(),Coords_y=double(),Coords_z=double(),
                         CoordsBipol_1_x=double(),CoordsBipol_1_y=double(),CoordsBipol_1_z=double(),CoordsBipol_2_x=double(),
                         CoordsBipol_2_y=double(),CoordsBipol_2_z=double(),InterElectrodeDistance=double(),DisttoWMBoundary=double(),Orientation=double(),
                         TissueType=character(),BrainRegion=character(), DisttoDNA=double(), DisttoDNB=double(),
                         DisttoFPN=double(), DisttodATNA=double(), DisttodATNB=double(),DisttoSALPMN=double(), 
                         DisttoLANG=double(),DisttoCONA=double(),DisttoCONB=double(),DisttoSMOTA=double(),
                         DisttoSMOTB=double(),DisttoSMOTC=double(),DisttoAUD=double(),DisttoVISP=double(),
                         TotalGaussian=double(), TotalVertices=double(),DNA_Percentage=double(), DNB_Percentage=double(), 
                         FPN_Percentage=double(),dATNA_Percentage=double(), dATNB_Percentage=double(), SALPMN_percentage=double(),
                         LANG_Percentage=double(),CONA_Percentage=double(),CONB_Percentage=double(),SMOTA_Percentage=double(),
                         SMOTB_Percentage=double(),PMPPR_Percentage=double(),AUD_Percentage=double(),VIS_Percentage=double())
  for (i in 1:length(sub_list)){ 
    SubjectID <- sub_list[i]
    if (SubjectID=='SSYQZJ'){
      network_file <- paste0('/Users/cce3182/Desktop/b1134/analysis/ccyr/CCEP_FM_Combined_Project/ind_parcellation/',
                             SubjectID,'/16/',SubjectID,'_Bipolar_gauss_10mm_FWHM_Elec_Network_Membership_MSHBM_Surgery2.csv')
    } else {
      network_file <- paste0('/Users/cce3182/Desktop/b1134/analysis/ccyr/CCEP_FM_Combined_Project/ind_parcellation/',
                             SubjectID,'/16/',SubjectID,'_Bipolar_gauss_10mm_FWHM_Elec_Network_Membership_MSHBM.csv')
    }
    elec_recon_dir  <- paste0('/Users/cce3182/Desktop/b1134/processed/fs/',SubjectID,'/',SubjectID, '/elec_recon')
    Electrode_info <- read_excel(paste0(elec_recon_dir,'/',SubjectID,'_','SiteInfoTable_bipolar_appended_MSHBM.xlsx'))
    Electrode_info$SubjectID <- SubjectID
    NetworkInfo <- read_csv(network_file,col_types=cols())
    Electrode_info <- merge(Electrode_info,NetworkInfo,by='ChannelID')
    All_info <- rbind(All_info, Electrode_info)
  }
  Electrode_info <- All_info[,!colnames(All_info) %in%  c("Coords_x","Coords_y","Coords_z",
                                                          "CoordsBipol_1_x","CoordsBipol_1_y","CoordsBipol_1_z", "CoordsBipol_2_x","CoordsBipol_2_y","CoordsBipol_2_z",
                                                          "InterElectrodeDistance","Orientation")]
  Electrode_info$DisttoSMOT <- apply(Electrode_info[,c('DisttoSMOTA','DisttoSMOTB')],1, FUN=min)
  Electrode_info$SMOT_Percentage <- apply(Electrode_info[,c('SMOTA_Percentage','SMOTB_Percentage')],1, FUN=sum)
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
      NetworkDistances <- as.data.frame(Electrode_info[i,c('DisttoDNA','DisttoDNB','DisttoFPN','DisttodATNA',
                                                           'DisttodATNB','DisttoSALPMN','DisttoLANG','DisttoCONA',
                                                           'DisttoCONB','DisttoPMPPR',
                                                           'DisttoAUD','DisttoVIS','DisttoSMOT')])
      if (Electrode_info$Targeted_network[i] != 'Unknown'){
        Electrode_info$DisttoTargetedNetwork[i] <- as.numeric(NetworkDistances[colnames(NetworkDistances)==paste0('Distto',Electrode_info$Targeted_network[i])])
      }
      Electrode_info$NearNetworks[i] <- sum(NetworkDistances <= 5)
      Electrode_info$AmpResult[i] <- site_list$AmpResult[index]
      Electrode_info$Stimulated_networks[i] <- site_list$Stimulated_networks[index]
      Electrode_info$Stimulated_networks_n[i] <- site_list$Stimulated_networks_n[index]
      Electrode_info$Max_Current[i] <- site_list$Max_Current[index]
      Electrode_info$BOLDFC[i] <- site_list$BOLDFC[index]
      Electrode_info$StimSiteType[i] <- site_list$StimSiteType[index]
    } else { #not stimulated
      NetworkDistances <- as.data.frame(Electrode_info[i,c('DisttoDNA','DisttoDNB','DisttoFPN','DisttodATNA',
                                                           'DisttodATNB','DisttoSALPMN','DisttoLANG','DisttoCONA',
                                                           'DisttoCONB','DisttoPMPPR',
                                                           'DisttoAUD','DisttoVIS','DisttoSMOT')])
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