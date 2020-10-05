# In the abstracts parsed in abs_methods,
#  find the words in METHODS that do not appear outside of METHODS
#  vsp on those words. 

# pull data
# parse each section into vector of words. 
# setdiff
library(tidyverse)
library(tidytext)

x = pullDataFiles("abs_methods")
colnames(x) = c("id","section","text")
tt  = x %>% unnest_tokens(word, text)

ids = unique(x$id)
i = 1
dat = matrix("", nrow = length(ids), ncol = 2)
for(i in 1:length(ids)){
  a = tt %>% filter(id ==ids[i])
  meth_words = a %>% filter(grepl("METH",section)) %>% pull(word) 
  other_words = a %>% filter(!grepl("METH",section)) %>% pull(word) 
  tmp = setdiff(meth_words, other_words) %>% paste(collapse = " ")
  dat[i,] = c(as.character(ids[i]), tmp)
}

dat = dat %>% as.data.frame %>% tibble 
colnames(dat)=c("id", "text")
A = dat %>% unnest_tokens(word, text) %>%  cast_sparse(id, word)
