#combine pdfs from plot_all_CCEPs.m

# load libraries
setwd('~')
if(!require("qpdf")) {install.packages(c("qpdf")); require("qpdf")}
if(!require("stringr")) {install.packages(c("stringr")); require("stringr")}
if (!require("gridExtra")) {install.packages(c("gridExtra")); require("gridExtra")}
if (!require("gtable")) {install.packages(c("gtable")); require("gtable")} 
if (!require("grid")) {install.packages(c("grid")); require("grid")} 
if (!require("png")) {install.packages(c("png")); require("png")}
if (!require("jpeg")) {install.packages(c("jpeg")); require("jpeg")}
if (!require("ggplot2")) {install.packages(c("ggplot2")); require("ggplot2")}
#if (!require("EBImage")) {BiocManager::install(c("EBImage")); require ("EBImage")}
#if (!require("OpenImageR")) {install.packages(c("OpenImageR")); require("OpenImageR")}
#options(EBImage.display = "raster")

OUTPATH <- commandArgs(trailingOnly=TRUE)

fileinfo <- unlist(strsplit(OUTPATH,'/'))
last <- length(fileinfo)
SubjectID <- fileinfo[last-4]
SessionID <- fileinfo[last-3]
TaskID <- fileinfo[last-2]
StimID <- fileinfo[last-1]
CurrentID <- fileinfo[last]
FILENAME <- paste(SubjectID, SessionID, TaskID, StimID, CurrentID, 'preprocoutput.pdf', sep = '_')

#create blank page filler
blank <- grid.rect(gp=gpar(fill="white", lwd = 0, col = "white"))


setwd(OUTPATH)
filelist <- list()
file_counter <- 1
for(i in 1:50){ #search for all CCEP#.png files made by plot_all_CCEPs.m
  current_file <- paste('CCEPs',i,'.png',sep='')
  if (file.exists(current_file)&(file.info(current_file)$size > 18000)){ #for only the non blank ones
    tmpfilename <- paste( 'tmp', file_counter, '.pdf', sep = '')
    
    #convert to pdf
    pdf(tmpfilename, height = 11, width = 8.5, onefile = T)
    pdf <- grid.arrange(arrangeGrob(blank, nrow = 1),
                        arrangeGrob(blank, rasterGrob(readPNG(current_file)), blank, nrow = 1, widths = c(0.25, 8, 0.25)),
                        arrangeGrob(blank, nrow = 1),
                        nrow = 3, heights = c(0.25, 10.5, 0.25))  
    
    dev.off()
    filelist[[file_counter]] <- i
    file_counter <- file_counter + 1
  }
  else {
     break
  }
}

#combine pdf files
savelist <- list()
file_counter <- 1
for(i in 1:50){
  current_file <- paste('tmp',i,'.pdf',sep='')
  if (file.exists(current_file)){
    savelist[[file_counter]] <- current_file
    file_counter <- file_counter + 1
  }
  else {
     break
  }
}  
outfile <- paste(OUTPATH, '/', FILENAME, sep='')
pdf_combine(savelist,
            outfile, password = "")

#remove temporary files
for (i in list.files(pattern = '^tmp'))
{
  file.remove(i)
}
for(i in list.files(pattern = '^CCEPs'))
{
  file.remove(i)
}
