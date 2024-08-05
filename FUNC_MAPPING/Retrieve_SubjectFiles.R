Retrieve_SubjectFiles <- function(SubjectID){
  if (SubjectID == 'CEWLLT'){
    task_file <- '/Users/cce3182/Desktop/b1134/analysis/task_feats/task_maps/BNI/CEWLLT/LANG/surf_41k/cross_session_maps/CEWLLT_LANG_SENTENCESmPSEUDO_n2_mean.dscalar.nii'
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/CEWLLT/REST/2mm/vonmises_parcellations/14/CEWLLT_k14_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/CEWLLT/REST/2mm/vonmises_parcellations/14/Network_ids.txt'
    lat_med_rotation <- c(-2, 67, 85)
    inf_rotation <- c(-2, 180, 85)
  } else if (SubjectID == 'DQTAWH'){
    task_file <- '/Users/cce3182/Desktop/b1134/analysis/task_feats/task_maps/BNI/DQTAWH/LANG/surf_41k/cross_session_maps/DQTAWH_LANG_SENTENCESmPSEUDO_n7_mean.dscalar.nii'
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/DQTAWH/REST_test_41k/2mm/vonmises_parcellations/17/DQTAWH_k17_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/DQTAWH/REST_test_41k/2mm/vonmises_parcellations/17/Network_ids.txt'
    lat_med_rotation <- c(5,69,100.53)
    inf_rotation <- c(5, 173, 87.53)
  } else if (SubjectID == 'SSYQZJ'){
    task_file <- '/Users/cce3182/Desktop/b1134/analysis/task_feats/task_maps/BNI/SSYQZJ/LANG/surf_41k/cross_session_maps/SSYQZJ_LANG_SENTENCESmPSEUDO_n7_mean.dscalar.nii'
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/SSYQZJ/REST_41k_test/2mm/vonmises_parcellations/14/SSYQZJ_k14_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/SSYQZJ/REST_41k_test/2mm/vonmises_parcellations/14/Network_ids.txt'
    lat_med_rotation <- c(2,70,96.5)
    inf_rotation <- c(2,185,91.5)
  } else if (SubjectID == 'PHPKQJ'){
    task_file <- ''
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/PHPKQJ/REST/2mm/vonmises_parcellations/18/PHPKQJ_k18_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/PHPKQJ/REST/2mm/vonmises_parcellations/18/Network_ids.txt'
    lat_med_rotation <- c(12,65,102.53)
    inf_rotation <- c(12,173,89.53)
  } else if (SubjectID == 'KKYNWL'){
    task_file <- ''
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/KKYNWL/REST/2mm/vonmises_parcellations/17/KKYNWL_k17_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/KKYNWL/REST/2mm/vonmises_parcellations/17/Network_ids.txt'
    lat_med_rotation <- c(-2.94,69.8,98.64)
    inf_rotation <- c(-2.94,174,94.64)
  } else if (SubjectID == 'XVFXFI'){
    task_file <- ''
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/XVFXFI/REST/2mm/vonmises_parcellations/14/XVFXFI_k14_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/XVFXFI/REST/2mm/vonmises_parcellations/14/Network_ids.txt'
    lat_med_rotation <- c(10,75,102.53)
    inf_rotation <- c(10,175,93,53)
  } else if (SubjectID == 'ZWLWDL'){
    task_file <- ''
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/ZWLWDL/REST/2mm/vonmises_parcellations/17/ZWLWDL_k17_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/ZWLWDL/REST/2mm/vonmises_parcellations/17/Network_ids.txt'
    lat_med_rotation <- c(5,69,100.53)
    inf_rotation <- c(5,176,87.53)
  } else if (SubjectID == 'DVYZVK'){
    task_file <- ''
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/DVYZVK/REST/2mm/vonmises_parcellations/20/DVYZVK_k20_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/DVYZVK/REST/2mm/vonmises_parcellations/20/Network_ids.txt'
    lat_med_rotation <- c(-2,67,103.53)
    inf_rotation <- c(-2,171,97.53)
  } else if (SubjectID == 'PLLBNH'){
    task_file <- ''    
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/PLLBNH/REST/2mm/vonmises_parcellations/16/PLLBNH_k16_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/PLLBNH/REST/2mm/vonmises_parcellations/16/Network_ids.txt'
    lat_med_rotation <- c(-10,70,116.53)
    inf_rotation <- c(15,171,94.74)
  } else if (SubjectID == 'VPWMYH'){
    task_file <- ''
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/VPWMYH/REST_ALL/2mm/vonmises_parcellations/14/VPWMYH_k14_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/VPWMYH/REST_ALL/2mm/vonmises_parcellations/14/Network_ids.txt'
    lat_med_rotation <- c(-2.94,69.8,98.54)
    inf_rotation <- c(-2.94,171.8,93.54)
  } else if (SubjectID == 'XBSGST'){
    task_file <- '/Users/cce3182/Desktop/b1134/analysis/task_feats/task_maps/BNI/XBSGST/LANG/surf_41k/cross_session_maps/XBSGST_LANG_SENTENCESmPSEUDO_n3_mean.dscalar.nii'
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/XBSGST/REST_41k/2mm/vonmises_parcellations/17/XBSGST_k17_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/XBSGST/REST_41k/2mm/vonmises_parcellations/17/Network_ids.txt'
    lat_med_rotation <- c(0,73,101)
    inf_rotation <- c(0,173,97)
  } else if (SubjectID == 'YKBYHS'){
    task_file <- '/Users/cce3182/Desktop/b1134/analysis/task_feats/task_maps/BNI/YKBYHS/LANG/surf_41k/cross_session_maps/YKBYHS_LANG_SENTENCESmPSEUDO_n8_mean.dscalar.nii'
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/YKBYHS/REST_41k_best/2mm/vonmises_parcellations/20/YKBYHS_k20_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/YKBYHS/REST_41k_best/2mm/vonmises_parcellations/20/Network_ids.txt'
    lat_med_rotation <- c(-10,69.15,103.53)
    inf_rotation <- c(9,175,94.53)
  }  else if (SubjectID == 'TTHMMI'){
    task_file <- ''
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/TTHMMI/REST/2mm/vonmises_parcellations/13/TTHMMI_k13_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/TTHMMI/REST/2mm/vonmises_parcellations/13/Network_ids.txt'
    lat_med_rotation <- c(-9,73,103)
    inf_rotation <- c(-9,174,95)
  }   else if (SubjectID == 'DZAEWN'){
    task_file <- ''
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/DZAEWN/REST/2mm/vonmises_parcellations/11/DZAEWN_k11_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/DZAEWN/REST/2mm/vonmises_parcellations/11/Network_ids.txt'
    lat_med_rotation <- c(-11,72,114)
    inf_rotation <- c(21,171,94)
  }    else if (SubjectID == 'ATHUAT'){
    task_file <- ''
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/ATHUAT/REST_41k/2mm/vonmises_parcellations/18/ATHUAT_k18_init100_roifsaverage3_vonmises_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/BNI/ATHUAT/REST_41k/2mm/vonmises_parcellations/18/Network_ids.txt'
    lat_med_rotation <- c(-11,72,114)
    inf_rotation <- c(21,171,94)
  }    else if (SubjectID == 'S1242'){
    task_file <- ''
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/Stanford/S1242/ALL_41k/2mm/parcellations/20/S1242_k20_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/Stanford/S1242/ALL_41k/2mm/parcellations/20/Network_ids.txt'
    lat_med_rotation <- c(-11,72,114)
    inf_rotation <- c(21,171,94)
  }    else if (SubjectID == 'S19145'){
    task_file <- ''
    kmeans_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/Stanford/S19145/ALL_41k/2mm/parcellations/19/S19145_k19_parcellation.dlabel.nii'
    labelinfo_file <- '/Users/cce3182/Desktop/b1134/analysis/surfFC/Stanford/S19145/ALL_41k/2mm/parcellations/19/Network_ids.txt'
    lat_med_rotation <- c(-11,72,114)
    inf_rotation <- c(21,171,94)
  } 
  return(list(task_file = task_file, kmeans_file = kmeans_file, 
              labelinfo_file = labelinfo_file,lat_med_rotation = lat_med_rotation, inf_rotation = inf_rotation))
}
