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

tf_stats<-db_query("SELECT tf_gene_id,target_gene_id, binding_score
                   FROM trans_factor_map 
                   WHERE tf_expt_id != 10")%>%
  .[,.("binding_score"=binding_score%>%{mean(.,na.rm = TRUE)}),by=c("tf_gene_id","target_gene_id")]
  setkey("tf_gene_id")

tf_binding<-db_query("SELECT tf_gene_id, target_gene_id, binding_score  FROM trans_factor_map WHERE tf_expt_id != 10")%>%
  .[,.("meanbs"=binding_score%>%{mean(.,na.rm = TRUE)+sd(.,na.rm = TRUE)}),by="tf_gene_id"]


binding_scores<-merge(tf_stats,tf_binding,by="tf_gene_id")%>%na.omit%>%.[binding_score>=meanbs]%>%.[binding_score>0]


tf_gene_list<-binding_scores[,unique(tf_gene_id)]
tf_targets<-binding_scores[,.("gene_id"=unique(target_gene_id))]

mapped_stats<-stats_by_timepoint%>%
  .[pvalue<=0.05,sig:=1]%>%
  .[is.na(sig),sig:=0]%>%
  .[tf_targets,on="gene_id"]%>%na.omit()

avail_genes<-mapped_stats[,.("target_gene_id"=gene_id%>%unique)]%>%setkey("target_gene_id")

total_gene_n<-mapped_stats[,uniqueN(gene_id)]

gene_enrichment<-function(tf,tpt){
  
  tf_genes<-binding_scores[tf_gene_id==tf]%>%merge(avail_genes,by="target_gene_id")
  
  # Initialize variables
  m <- tf_genes[,uniqueN(target_gene_id)]                 # Genes IN GO term
  n <- total_gene_n-tf_genes[,uniqueN(target_gene_id)]    # Genes NOT IN GO term
  k <- mapped_stats[timepoint==tpt][sig==1,.N]       # Gene hits, that is, differentially expressed
  x <- mapped_stats[timepoint==tpt]%>%
    .[tf_genes, on=c("gene_id"="target_gene_id")]%>%
    .[sig==1,.N]  # Genes both IN GO term and differentially expressed 'hits'
  
  # Use the dhyper built-in function for hypergeometric density
  probabilities <- -dhyper(x, m, n, k, log = TRUE)
  
  data.table("timepoint"=timepoints[tpt==text,numbers],"tf_gene_id"=tf, "sig_genes"=x, "total_genes"=m, nlogp=probabilities)
}

tpt_func_parallel<-function(tpt){mclapply(tf_gene_list,gene_enrichment,tpt=tpt,mc.cores=6L)%>%rbindlist}

xx<-mclapply(timepoints[,text], tpt_func_parallel)%>%rbindlist%>%setorder("timepoint","tf_gene_id")%T>%
  {dbWriteTable(db_connect(user_db = "macrophage_mysql"), "tf_statistics", .)}


