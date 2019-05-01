library(rcompanion)

timepoints<-c(4,24,24*7*2,24*7*4,24*7*6)

stats_by_timepoint<-timepoints%>%
  lapply(tpt_values)%>%
  lapply(tpt_stats)%>%
  lapply(na.omit)%>%
  rbindlist

string_db<-STRINGdb::STRINGdb$new()

gene_string<-string_db$map(stats_by_timepoint[,
                                              .("gene_id"=gene_id[1]), 
                                              by="gene_symbol"], "gene_symbol")%>%as.data.table

mapped_stats<-stats_by_timepoint[gene_string,on="gene_id"][!is.na(STRING_id)][pvalue<=0.05,sig:=1][is.na(sig),sig:=0]

ontologies<-fread("~/Production/data/annotations_9606.tsv",header=FALSE)%>%
  setnames(paste0("V",1:4),c("STRING_id","ontology","type","IEA"))


ont_list<-ontologies[,unique(ontology)]

total_gene_n<-ontologies[,uniqueN(STRING_id)]


ont<-"GO:0006810"
tpt<-"4h"

gene_enrichment<-function(ont,tpt){
ont_genes<-ontologies[ontology==ont]

# Initialize variables
m <- ont_genes[,uniqueN(STRING_id)]                 # Genes IN GO term
n <- total_gene_n-ont_genes[,uniqueN(STRING_id)]   # Genes NOT IN GO term
k <- mapped_stats[timepoint==tpt][sig==1,.N]       # Gene hits, that is, differentially expressed
x <- mapped_stats[timepoint==tpt][ont_genes, on="STRING_id"][sig==1,.N]  # Genes both IN GO term and differentially expressed 'hits'

# Use the dhyper built-in function for hypergeometric density
probabilities <- -dhyper(x, m, n, k, log = TRUE)

data.table("timepoint"=tpt,"ontology"=ont, "sig_genes"=x, "total_genes"=m, nlogp=probabilities)
}


foreach(i=1:nrow(ont_list), .combine=rbindlist) %dopar%
  gene_enrichment(ont_list,tpt="4h")


gse_tpt<-function(tpt){
  require(foreach)
foreach(i=1:nrow(ont_list)
        , .combine=rbind) %dopar%
  gene_enrichment(ont_list[i],tpt=tpt)
}

zz<-gse_tpt("4h")


gene_enrichment_tpt<-function(ont){
  ont_genes<-ontologies[ontology==ont]
  
yy<-  mapped_stats[ont_genes, on="STRING_id"][!is.na(sig)][,.("sig"=sum(sig==1),"total"=.N),by="timepoint"]%>%
  dt_to_df()%>%as.matrix%>%
  pairwiseNominalIndependence(fisher=TRUE, digits = 3)%>%
  as.data.table%>%
  dcast.data.table(.~Comparison,value.var = "p.adj.Chisq")%>%
  .[,comparison:=ont]%>%
  .[,.:=NULL]%>%
  setcolorder("comparison")
 
return(yy)
}

gene_enrichment_tpt%<>%
  possibly(otherwise=NA)

gse_tpt_all<-function(){
  require(foreach)
  foreach(i=1:1000) %dopar%
    gene_enrichment_tpt(ont_list[i])
}

gse_tpt_complete<-gse_tpt_all()

gse_tpt_complete%>%compact()
