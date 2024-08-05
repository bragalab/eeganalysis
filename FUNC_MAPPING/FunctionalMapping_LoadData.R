FunctionalMapping_LoadData <- function(){
InfoTable <- read_excel(paste0("/Users/cce3182/Desktop/b1134/analysis/ccyr/FunctionalMappingProject/FunctionalMappingResults_appended.xlsx"),
                        col_types = c('text','text','text','text','numeric','logical','logical','logical','text','logical','text',
                                      'logical','text','logical','text','logical','text','logical','text','text','text','text'))

return(InfoTable)
}