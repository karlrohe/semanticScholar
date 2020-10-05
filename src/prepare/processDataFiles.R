# this file gives a function for scanning through the raw data (in parallel)
#   processDataFiles(includeLine, processLine, outputPath)
# includeLine and processLine are functions. 
# if x is a line of data, then includeLine(x) is a boolian 
#    to denote whether this line should be processed.
# if true, then processLine(x) is written to a new line of 
#    data/outputPath/xxx.txt
#  where xxx is the name of the file from which x was drawn.




# this code iterates through /raw/manifest.tex using multiple cores.  
#     for(datfile in manifest)
#     inFile = paste("raw/", datfile, sep  ="")
#     in.con = file(inFile, "r")
#  each data file, is read line-by-line with /scripts/functions/getLine.R
#     x = getLine(in.con);
#  inclusion critera is assessed.  
#     if(includeLine(x))
#  data is processed
#     output = processLine(x) 
#  output is appended to outputPath
#     writeLines(text = output, out.con)
#   where 
#     out.con = paste0(outputPath,"/", datfile, ".txt") %>% file("w")


library(tidyverse)
library(parallel)
source("src/prepare/getLine.R")
cores = detectCores(logical = F)

#leave some cores for the rest of us:
useCores= cores - 1
if(cores>8) useCores= cores/2 - 3



processDataFiles = function(includeLine, processLine, outputPath){
  
  dir.create(paste0("data/",outputPath))
  
  filenames = read_csv("raw/manifest.txt")  %>% pull  
  tmp = mclapply(filenames, 
                 function(datfile){
                   processOneDataFile(datfile, includeLine, processLine, outputPath)
                 },
                 # includeLine=includeLine, processLine=processLine, outputPath=outputPath, 
                 mc.cores = useCores)  
  tmp = do.call(c,tmp)
  return(tmp)
}







# datfile  = filenames[1]

processOneDataFile = function(datfile,includeLine, processLine, outputPath){
  
  in.con = paste0("raw/", datfile) %>% file("r")
  # outputPath = "output/tmp"
  out.con = paste0("data/", outputPath,"/", datfile) %>% file("w")
  tick = 0
  while(1){
    tick = tick +1
    if(tick%in% c(1, 10000,100000,500000)) print(paste0(datfile, log10(tick)))
    x = getLine(in.con); 
    if(x[1] == "THIS IS THE ERROR STRING RETURNED"){
      print(paste(datfile, "terminated early, at line", tick))
      break
    }
    if(includeLine(x)){
      output = processLine(x) 
      writeLines(text = output, out.con)
    }
  }
  close(in.con)
  close(out.con)
  return(tick)
}

readNoNames = function(fileName) read_csv(fileName, col_names = F)

pullDataFiles = function(outputPath, readOneDataFile = readNoNames, checkSize = T){
  x = ""
  files<-list.files(paste0("data/",outputPath),full.names = T)
  if(checkSize){ 
    vect_size <- sapply(files, file.size)
    print(paste("total size on disc in mb:",sum(vect_size)/10^6,".  enter any character to cancel."))
    x = scan()
    
  }
  if(length(x) >0) break
  
  # tmp = lapply(X = files, FUN = readOneDataFile)
  tmp = mclapply(files,
                 function(x){
                   readOneDataFile(x)
                 },
                 # includeLine=includeLine, processLine=processLine, outputPath=outputPath,
                 mc.cores = useCores)
  do.call(rbind, tmp)

}


# tmp = lapply(files, 
#                function(x){
#                  readOneDataFile(x)
#                })
# 
# ### TEST:
# # ensure that there is no overwritting of files.
# includeLine= function(x) TRUE
# processLine = function(x) x$magId
# outputPath = "test"
# howmanylines = processDataFiles(includeLine, processLine, outputPath)
# howmanylines = do.call(c, howmanylines)
# 
# filenames = read_csv("raw/manifest.txt")  %>% pull
# 
# x= c()
# for(datfile in filenames) x= c(x, read_csv(paste0("data/",outputPath,"/",datfile), col_names =  F)$X1)
# # these two should be equal:
# length(x)
# length(unique(x))
# 
# dat = rep(NA, length(filenames))
# for(i in 1:length(filenames)){
#   datfile = filenames[i]
#   x= read_csv(paste0("data/",outputPath,"/",datfile), col_names =  F)$X1
#   dat[i]= length(x)
# }
