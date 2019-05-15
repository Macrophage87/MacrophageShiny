
library(httr)


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

  mapped<-string_db$map(analysis_sig,"gene_symbol")%>%na.omit
  
  analysis_sig<-analysis[pvalue<0.05][order(qvalue)]
  return(mapped)
}

all_mapped<-lapply(all_analyses,map_sig)
mapped_clusters<-lapply(all_mapped,function(x)string_db$get_clusters(x$STRING_id))

string_db$plot_network(mapped_clusters[[1]][[1]])



enrichment<-function(x)GET(glue("https://string-db.org/api/tsv/enrichment?identifiers={paste(x,collapse='%0')}"))%>%
  content()


enrichment(all_mapped[[1]])
                                
                                
all_mapped_dt<-lapply(all_mapped,as.data.table)
annot<-fread("data/annotations_9606.tsv",header=FALSE)%>%setnames(paste0("V",1:4),c("STRING_id","Ontology","Type","IEA"))
ontologies<-annot[,unique(Ontology)]


insig<-lapply(all_analyses,function(x)x[pvalue>0.05])

#%>%unlist%>%{data.table("list_no"=1:length(.),"insig"=.)}


map_all<-function(analysis){
  mapped<-string_db$map(analysis,"gene_symbol")%>%na.omit%>%as.data.table
  
  analysis_sig<-mapped[pvalue<=0.05,sig:=1][order(qvalue)]
  
  return(analysis_sig)
}

all_mapped<-lapply(all_analyses,map_all)


ont_map<-function(ont){
ontology<-annot[Ontology==ont]
fish<-matrix(rep(NA,4),nrow = 2)

fish[1,1]<-sig_mapped  [ontology,on="STRING_id",.N]
fish[1,2]<-insig_mapped[ontology,on="STRING_id",.N]
fish[2,1]<-sig_mapped  [!ontology,on="STRING_id",.N]
fish[2,2]<-insig_mapped[!ontology,on="STRING_id",.N]

return(fisher.test(fish)%>%broom::tidy(x)%>%as.data.table%>%.[,"Ontology":=ont])
}

map_ont<-function(values){
sig_mapped<-values[sig==1]
insig_mapped<-values[is.na(sig)]

tp_enrich<-lapply(ontologies,ont_map)%>%rbindlist()

return(tp_enrich)}

all_mapped_ontologies<-lapply(all_mapped,map_ont)
