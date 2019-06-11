library(magrittr)
library(stringr)
library(STRINGdb)
library(httr)

source("functions/gene_ot.R")


timepoints<-c(4,24,24*7*2,24*7*4,24*7*6)

gene_info_by_timepoint<-timepoints%>%
  lapply(tpt_values)

stats_by_timepoint<-gene_info_by_timepoint%>%
  lapply(tpt_stats)%>%
  lapply(na.omit)

merge_all_tpts<-gene_info_by_timepoint%>%
  lapply(tpt_stats,tp_merge=TRUE)%>%
  lapply(na.omit)%>%
  rbindlist

all_analyses<-purrr::splice(stats_by_timepoint,merge_all_tpts)


string_db<-STRINGdb$new(9606)

string_db

map_all<-function(analysis){
  mapped<-string_db$map(analysis,"gene_symbol")%>%na.omit
  return(mapped)
}

sig<-.%>%.[pvalue<=0.05]

all_sig_map<-lapply(all_analyses,sig)%>%lapply(map_all)%>%lapply(as.data.table)

string_db$get_clusters(all_sig_map[[1]]$STRING_id)


graph

library(igraph)

