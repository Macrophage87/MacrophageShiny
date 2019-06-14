library(data.table)
library(magrittr)
library(stringr)
library(purrr)

l2p<-function(x){log2(x+1)}




gene_list<-db_query("SELECT gene_id, gene_symbol, ensembl_id FROM genes")

RNAseq_upload<-function(file){
  
sample_name<-dirname(file)%>%str_extract("/[^/]*$")%>%str_remove("/")%T>%
  {db_statement(user_db="macrophage_mysql",
                "INSERT INTO samples (sample_name) VALUES (?)", params = list(.))}
  
sample_id<-db_query("SELECT MAX(sample_id) AS sample_id FROM samples")
  
list<-fread(file)%>%
  setnames("gene_id","gene")%>%
  .[,"ensembl_id":=gene%>%str_extract("ENSG\\d{11}")]%>%
  .[grep("(.*?)_\\1",gene),"viral_gene":=gene%>%gsub("(.*?)_\\1","\\1",.)]%>%
  .[,"sample_id":=sample_id$sample_id%>%as.numeric()]

dtp<-.%>%.[,.(sample_id,gene_id,TPM,FPKM,expected_count,length,effective_length)]

x<-rbindlist(list(
  merge(list[!is.na(ensembl_id)],gene_list,by='ensembl_id',all = FALSE)%>%
    dtp,
  merge(list[!is.na(viral_gene)],gene_list,by.x='viral_gene',by.y="gene_symbol",all = FALSE)%>%
    setnames("viral_gene","gene_symbol")%>%
    dtp)
  )%T>%
  dbAppendTable(db_connect(user_db="macrophage_mysql"),"transcript_values",.)

print(x)

}

exp_list<-list.files("/data/users/stephen/RNAseq", pattern = "genes.results$",
           all.files = TRUE, recursive = TRUE, full.names = TRUE,
           include.dirs = TRUE)


walk(exp_list, RNAseq_upload)
