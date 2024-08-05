#load packages
if(!require("flextable")) {install.packages("flextable"); require("flextable")}
if(!require("readxl")) {install.packages("readxl"); require("readxl")}
Demographics_Table <- read_excel("/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Analysis/CCEP_FM_Demographics.xlsx")
ft <- flextable(Demographics_Table)
ft <- hrule(ft, rule = "atleast", part = "all")
ft <- set_table_properties(ft,layout = 'fixed')
ft <- font(ft, i=NULL,j=NULL, part = 'all', 'questrial')
ft <- fontsize(ft,size = 11, part = "all")
ft <- line_spacing(ft, space = 1.3, part = "all")
ft <- padding(ft,i=NULL,j=NULL, padding=2, part = "all")
ft <- vline(ft, j=c('Patient'), part=c('all'))
ft <- vline_left(ft, part = 'all')
ft <- vline_right(ft, part = 'all')
ft <- height(ft, i=c(1:14), height=0.6, unit='in')
ft <- width(ft, j=c('P1','P2','P3','P4','P5','P6','P7','P8','P9','P10','P11'), width=0.5, unit='in')  
flextable_dim(ft, unit='in')
save_as_image(ft,'/Users/cce3182/Desktop/CCEP_FM_Combined_Project/Figures/CCEP_HFS_T1.png',
       res = 300)

