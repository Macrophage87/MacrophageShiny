library(rcompanion)
library(foreach)
library(magrittr)
library(future)
library(parallel)

timepoints<-data.table("numbers"=c(4,24,24*7*2,24*7*4,24*7*6),"text"=c("4h","24h","2wk","4wk","6wk"))

stats_by_timepoint<-timepoints[,numbers]%>%
  lapply(tpt_values)%>%
  lapply(tpt_stats)%>%
  lapply(na.omit)%>%
  rbindlist

kegg_pw<-db_query("SELECT kegg_pw_id, gene_id FROM kegg_pw_mapping")


mapped_stats<-stats_by_timepoint%>%
  .[pvalue<=0.05,sig:=1]%>%
  .[is.na(sig),sig:=0]

kegg_list<-kegg_pw[,unique(kegg_pw_id)]

total_gene_n<-stats_by_timepoint[,uniqueN(gene_id)]

gene_enrichment<-function(kgg,tpt){
  
  ont_genes<-kegg_pw[kegg_pw_id==kgg]
  
  # Initialize variables
  m <- ont_genes[,uniqueN(gene_id)]                 # Genes IN GO term
  n <- total_gene_n-ont_genes[,uniqueN(gene_id)]   # Genes NOT IN GO term
  k <- mapped_stats[timepoint==tpt][sig==1,.N]       # Gene hits, that is, differentially expressed
  x <- mapped_stats[timepoint==tpt][ont_genes, on="gene_id"][sig==1,.N]  # Genes both IN GO term and differentially expressed 'hits'
  
  # Use the dhyper built-in function for hypergeometric density
  probabilities <- -dhyper(x, m, n, k, log = TRUE)
  
  data.table("timepoint"=timepoints[tpt==text,numbers],"kegg_pw_id"=kgg, "sig_genes"=x, "total_genes"=m, nlogp=probabilities)
}

tpt_func_parallel<-function(tpt){mclapply(kegg_list,gene_enrichment,tpt=tpt,mc.cores=6L)%>%rbindlist}

xx<-mclapply(timepoints[,text], tpt_func_parallel)%>%rbindlist%T>%
  {dbWriteTable(db_connect(user_db = "macrophage_mysql"), "kegg_statistics", .)}


