FunctionalMapping_BuildTable_MSHBM <- function(SiteSummary){
  ######################### load each subjects electrode info excel and combine them
  sub_list <- unique(SiteSummary[,c('SubjectID','Session')])
  All_info <- data.frame(SubjectID=character(),Session=character(),ChannelID=character(),Coords_x=double(),Coords_y=double(),Coords_z=double(),
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
  for (i in 1:dim(sub_list)[1]){ 
    SubjectID <- sub_list[[i,1]]
    SessionID <- sub_list[[i,2]]
    if (length(dir(path=paste0('/Users/cce3182/Desktop/b1134/processed/fs/',SubjectID,'/',SubjectID), pattern='elec_recon_Surgery', recursive=FALSE))==0){
      elec_recon_dir <- paste0('/Users/cce3182/Desktop/b1134/processed/fs/',SubjectID,'/',SubjectID, '/elec_recon')
      network_file <- paste0('/Users/cce3182/Desktop/b1134/analysis/ccyr/CCEP_FM_Combined_Project/ind_parcellation/',
                             SubjectID,'/16/',SubjectID,'_Bipolar_gauss_10mm_FWHM_Elec_Network_Membership_MSHBM.csv')
    } else {
      elec_recon_dir  <- paste0('/Users/cce3182/Desktop/b1134/processed/fs/',SubjectID,'/',SubjectID, '/elec_recon_', SessionID)
      network_file <- paste0('/Users/cce3182/Desktop/b1134/analysis/ccyr/CCEP_FM_Combined_Project/ind_parcellation/',
                             SubjectID,'/16/',SubjectID,'_Bipolar_gauss_10mm_FWHM_Elec_Network_Membership_MSHBM_', SessionID,'.csv')
    }
    Electrode_info <- read_excel(paste0(elec_recon_dir,'/',SubjectID,'_','SiteInfoTable_bipolar_appended_MSHBM.xlsx'))
    Electrode_info$SubjectID <- SubjectID
    Electrode_info$Session <- SessionID
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
  
  ################### add information about stimulation results
  Electrode_info$StimulationResult <- NA
  Electrode_info$EffectList <- NA
  Electrode_info$EffectType <- NA
  Electrode_info$ReadingEffect <- NA
  Electrode_info$ReadingSymptom <- NA
  Electrode_info$RecitingEffect <- NA
  Electrode_info$RecitingSymptom <- NA
  Electrode_info$NamingEffect <- NA
  Electrode_info$NamingSymptom <- NA
  Electrode_info$ComprehensionEffect <- NA
  Electrode_info$ComprehensionSymptom <- NA
  Electrode_info$MotorEffect <- NA
  Electrode_info$MotorSymptom <- NA
  Electrode_info$SensoryEffect <- NA
  Electrode_info$SensorySymptom <- NA
  Electrode_info$MaxCurrent <- NA
  Electrode_info$AfterDischarges <- NA
  Electrode_info$Seizure <- NA
  Electrode_info$NearNetworks <- NA
  Electrode_info$SiteType <- NA
  Electrode_info$Network <- NA
  Networks <- c('DNA','DNB','FPN','dATNA','dATNB','SALPMN','LANG','CONA','CONB','SMOT','PMPPR','AUD','VIS')
  versionlist <- c('gaze','version','deviation', 'Eye/head version','eyes move')
  apnealist <- c('apnea')
  facelist <- c('face','eyes closed','eye flutter','lip','cheek','tongue','jaw','Jaw','facial')
  handlist <- c('hand')
  bodylist <- c('arm','shoulder','body','calf','tremors','foot')
  visuallist <- c('strobe','light','blurry','moving','stars','visual','visual hallucination',
                  'vision vibration','flickering','vision','blurring',"can't see",'flash','see')
  auditorylist <- c('ringing','ears',"can't hear",'echo','hum','tone','hear','auditory')
  touchlist <- c('tingling','poking','vibration sensation','shock','mouth sensation','numb','numbness','sensation r side','buzzing') 
  temperaturelist <- c('hot','warm','warmth','heat')
  painlist <- c('pain','hurts')
  smelllist <- c('smells')
  abstractlist <- c('deja vu','fear','off feeling','panic','confusion','focus','lapse')
  auralist <- c('aura')
  for (i in 1:dim(Electrode_info)[1]){
    MirroredChannelID <- paste0(unlist(str_split(Electrode_info$ChannelID[i],'-'))[2],'-',unlist(str_split(Electrode_info$ChannelID[i],'-'))[1])
    index = (SiteSummary$StimulationSite == Electrode_info$ChannelID[i] | SiteSummary$StimulationSite == MirroredChannelID) &
      SiteSummary$SubjectID == Electrode_info$SubjectID[i] &
      SiteSummary$Session == Electrode_info$Session[i]
    
    #Network information
    Electrode_info$NearNetworks[i] <-  sum(Electrode_info[i,c('DisttoDNA','DisttoDNB','DisttoFPN','DisttodATNA',
                                                              'DisttodATNB','DisttoSALPMN','DisttoLANG','DisttoCONA',
                                                              'DisttoCONB','DisttoSMOT','DisttoPMPPR',
                                                              'DisttoAUD','DisttoVIS')] <= 5)
    if (max(Electrode_info[i,c('DNA_Percentage','DNB_Percentage','FPN_Percentage','dATNA_Percentage',
                               'dATNB_Percentage', 'SALPMN_Percentage', 'LANG_Percentage', 'CONA_Percentage',
                               'CONB_Percentage', 'SMOT_Percentage', 'PMPPR_Percentage',
                               'AUD_Percentage', 'VIS_Percentage')]) < 0.1){
      Electrode_info$Network[i] <- 'Unknown'
    }
    else{
      Electrode_info$Network[i] <- Networks[which.max(Electrode_info[i,c('DNA_Percentage','DNB_Percentage','FPN_Percentage','dATNA_Percentage',
                                                                         'dATNB_Percentage', 'SALPMN_Percentage', 'LANG_Percentage', 'CONA_Percentage',
                                                                         'CONB_Percentage', 'SMOT_Percentage', 'PMPPR_Percentage',
                                                                         'AUD_Percentage', 'VIS_Percentage')])]
    }
    
    if (sum(index) == 1){ #if site was stimulated on
      #pipe in stimulation results info
      Electrode_info$ReadingEffect[i] <- as.character(SiteSummary$ReadingConclusion[index])
      Electrode_info$ReadingSymptom[i] <- as.character(SiteSummary$ReadingSymptomList[index])
      Electrode_info$RecitingEffect[i] <- as.character(SiteSummary$RecitingConclusion[index])
      Electrode_info$RecitingSymptom[i] <- as.character(SiteSummary$RecitingSymptomList[index])
      Electrode_info$NamingEffect[i] <- as.character(SiteSummary$NamingConclusion[index])
      Electrode_info$NamingSymptom[i] <- as.character(SiteSummary$NamingSymptomList[index])
      Electrode_info$ComprehensionEffect[i] <- as.character(SiteSummary$ComprehensionConclusion[index])
      Electrode_info$ComprehensionSymptom[i] <- as.character(SiteSummary$ComprehensionSymptomList[index])
      Electrode_info$MotorEffect[i] <- as.character(SiteSummary$MotorConclusion[index])
      Electrode_info$MotorSymptom[i] <- as.character(SiteSummary$MotorSymptomList[index])
      Electrode_info$SensoryEffect[i] <- as.character(SiteSummary$SensoryConclusion[index])
      Electrode_info$SensorySymptom[i] <- as.character(SiteSummary$SensorySymptomList[index])
      Electrode_info$MaxCurrent[i] <- SiteSummary$MaxCurrent[index]
      Electrode_info$AfterDischarges[i] <- SiteSummary$AfterDischarges[index]
      Electrode_info$Seizure[i] <- SiteSummary$Seizure[index]
      Electrode_info$SiteType[i] <- SiteSummary$SiteType[index]
      
      #further parse out effects of stimulation
      if (any(as.data.frame(SiteSummary[index,c('ReadingConclusion','RecitingConclusion','NamingConclusion','ComprehensionConclusion',
                                                'MotorConclusion','SensoryConclusion')]) =='Positive')){
        Electrode_info$StimulationResult[i] <- 'Behavioral Effects'
        if (any(as.data.frame(SiteSummary[index,c('ReadingConclusion','RecitingConclusion','NamingConclusion')]) =='Positive')){
          LanguageSymptom = 'Language' } else {LanguageSymptom = character()}
        if (SiteSummary$ComprehensionConclusion[index] == 'Positive'){
          ComprehensionSymptom = 'Comprehension' } else {ComprehensionSymptom = character()}
        if (SiteSummary$MotorConclusion[index] == 'Positive'){
          MotorSymptoms <- unlist(str_split(SiteSummary$MotorSymptomList[index],','))
          MotorSymptoms <- MotorSymptoms[!grepl('+',MotorSymptoms, fixed=TRUE)]
          MotorSymptoms <- tolower(trimws(unique(c(unlist(str_split(MotorSymptoms,' ')),MotorSymptoms))))
          if (any(MotorSymptoms %in% versionlist)){
            VersionSymptom = 'Version' } else {VersionSymptom = character()}
          if (any(MotorSymptoms %in% apnealist)){
            ApneaSymptom = 'Apnea' } else {ApneaSymptom = character()}
          if (any(MotorSymptoms %in% facelist)){
            FaceSymptom = 'Face' } else {FaceSymptom = character()}
          if (any(MotorSymptoms %in% handlist)){
            HandSymptom = 'Hand' } else {HandSymptom = character()}
          if (any(MotorSymptoms %in% bodylist)){
            BodySymptom = 'Body' } else {BodySymptom = character()}
        } else {VersionSymptom = character();ApneaSymptom = character();FaceSymptom = character();HandSymptom = character();BodySymptom = character()}
        if (SiteSummary$SensoryConclusion[index] == 'Positive'){
          SensorySymptoms <- unlist(str_split(SiteSummary$SensorySymptomList[index],','))
          SensorySymptoms <- SensorySymptoms[!grepl('+',SensorySymptoms, fixed=TRUE)]
          SensorySymptoms <- tolower(trimws(unique(c(unlist(str_split(SensorySymptoms,' ')),SensorySymptoms))))
          if (any(SensorySymptoms %in% visuallist)){
            VisualSymptom = 'Visual' } else {VisualSymptom = character()}     
          if (any(SensorySymptoms %in% auditorylist)){
            AuditorySymptom = 'Auditory' } else {AuditorySymptom = character()} 
          if (any(SensorySymptoms %in% touchlist)){
            TouchSymptom = 'Touch' } else {TouchSymptom = character()} 
          if (any(SensorySymptoms %in% temperaturelist)){
            TemperatureSymptom = 'Temperature' } else {TemperatureSymptom = character()} 
          if (any(SensorySymptoms %in% painlist)){
            PainSymptom = 'Pain' } else {PainSymptom = character()}  
          if (any(SensorySymptoms %in% smelllist)){
            SmellSymptom = 'Smell' } else {SmellSymptom = character()}       
          if (any(SensorySymptoms %in% abstractlist)){
            AbstractSymptom = 'Abstract' } else {AbstractSymptom = character()} 
          if (any(SensorySymptoms %in% auralist)){
            AuraSymptom = 'Aura' } else {AuraSymptom = character()} 
        } else {VisualSymptom = character();AuditorySymptom = character();TouchSymptom = character();TemperatureSymptom = character();PainSymptom = character();SmellSymptom = character();AbstractSymptom = character();AuraSymptom = character()}       
        Electrode_info$EffectList[i] <-  paste(c(LanguageSymptom, ComprehensionSymptom,
                                                 VersionSymptom,ApneaSymptom,FaceSymptom,HandSymptom,BodySymptom,
                                                 VisualSymptom,AuditorySymptom,TouchSymptom,TemperatureSymptom,
                                                 PainSymptom,SmellSymptom,AbstractSymptom,AuraSymptom),collapse=',')
      } else if (any(as.data.frame(SiteSummary[index,c('ReadingConclusion','RecitingConclusion','NamingConclusion','ComprehensionConclusion','MotorConclusion','SensoryConclusion')]) =='Negative')){
        Electrode_info$StimulationResult[i] <- 'No Effects' 
        Electrode_info$EffectList[i] <- 'No Effects'
      } else if (any(as.data.frame(SiteSummary[index,c('ReadingConclusion','RecitingConclusion','NamingConclusion','ComprehensionConclusion','MotorConclusion','SensoryConclusion')]) =='Negative+AD')){
        Electrode_info$StimulationResult[i] <- 'No Effects'
        Electrode_info$EffectList[i] <- 'No Effects'
      } else if (any(as.data.frame(SiteSummary[index,c('ReadingConclusion','RecitingConclusion','NamingConclusion','ComprehensionConclusion','MotorConclusion','SensoryConclusion')]) =='No Result')){
        Electrode_info$StimulationResult[i] <- 'No Effects' 
        Electrode_info$EffectList[i] <- 'No Effects'
      } else if (any(as.data.frame(SiteSummary[index,c('ReadingConclusion','RecitingConclusion','NamingConclusion','ComprehensionConclusion','MotorConclusion','SensoryConclusion')]) =='No Result+AD')){
        Electrode_info$StimulationResult[i] <- 'No Effects' 
        Electrode_info$EffectList[i] <- 'No Effects'
      } else {
        Electrode_info$StimulationResult[i] <- 'Inconclusive'
        Electrode_info$EffectList[i] <- 'Inconclusive'
      }
    } else {
      Electrode_info$StimulationResult[i] <- 'Not Stimulated'
      Electrode_info$EffectList[i] <- 'Not Stimulated'
      Electrode_info$ReadingEffect[i] <- 'Not Stimulated'
      Electrode_info$ReadingSymptom[i] <- ''
      Electrode_info$RecitingEffect[i] <- 'Not Stimulated'
      Electrode_info$RecitingSymptom[i] <- ''
      Electrode_info$NamingEffect[i] <- 'Not Stimulated'
      Electrode_info$NamingSymptom[i] <- ''
      Electrode_info$ComprehensionEffect[i] <- 'Not Stimulated'
      Electrode_info$ComprehensionSymptom[i] <- ''
      Electrode_info$MotorEffect[i] <- 'Not Stimulated'
      Electrode_info$MotorSymptom[i] <- ''
      Electrode_info$SensoryEffect[i] <- 'Not Stimulated'
      Electrode_info$MotorSymptom[i] <- ''
      Electrode_info$MaxCurrent[i] <- 0
      Electrode_info$AfterDischarges[i] <- 'Not Stimulated'
      Electrode_info$Seizure[i] <- 'Not Stimulated'
      Electrode_info$SiteType[i] <- 'Not Stimulated'
    }
  }
  return(Electrode_info)
}
