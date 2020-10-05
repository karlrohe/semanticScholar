# Find papers with abstracts containing "METHODS".  
#  print the abstract to data/abs_methods; 
# structured abstracts have sections: BACKGROUND|OBJECTIVE|METHODS|RESULTS|CONCLUSIONS|UNASSIGNED
# so, the tables in abs_methods are parsed to find these. 
#   first col is paperID. 
#   Second col is section
#   third col is text of that section.

# This code is the first application of the function
#   processDataFiles(includeLine, processLine, outputPath)
# includeLine ensures it has structured abstact.
# processLine parses into the sections.


# load processDataFiles
source('src/prepare/processDataFiles.R')

#key functions:
includeLine = function(x) {
  if(nchar(x$paperAbstract) == 0) return(F) 
  grepl("METHODS\n", x$paperAbstract)
}

processLine = function(x){
  
  textt = x$paperAbstract
  tmp = strsplit(textt, split = "\n")[[1]]
  tmp = gsub('[[:punct:] ]+',' ',tmp)
  tmp[nchar(tmp)>0]
  
  ids = grepl("BACKGROUND|OBJECTIVE|METHODS|RESULTS|CONCLUSIONS|UNASSIGNED", tmp) %>% which()
  tmp = tibble(id = x$magId,  cellType = tmp[ids], text = tmp[ids+1])
  tt  = tmp %>% unnest_tokens(word, text)
  if("METHODS" %in% tmp$cellType){
    meth_words = tt %>% filter(grepl("METH",cellType)) %>% pull(text) 
    other_words = tt %>% filter(!(grepl("METH",cellType))) %>% pull(text)
    methDiff = setdiff(meth_words, other_words) %>% paste(collapse = " ")
    tmp = add_row(tmp, id = x$magId,  cellType = "METHODS_DIFF", text = methDiff)
  }
  out = ""
  for(i in 1:nrow(tmp)) out = paste(out,paste(tmp[i,], collapse = ",") , "\n")
  out
}

outputPath = "abs_methods"
processDataFiles(includeLine, processLine, outputPath)


# test:
# # processOneDataFile(datfile,includeLine, processLine, outputPath)
# # x=  read_csv("data/abs_methods/s2-corpus-000.txt", col_names = FALSE)

