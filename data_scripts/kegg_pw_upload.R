library(httr)
library(stringr)

y<-GET("http://rest.kegg.jp/list/pathway/hsa")%>%
  content()%>%
  unlist%>%
  {fread(input = .,sep="\t",header=FALSE)}%>%
  setnames(paste0("V",1:2),c("pathway_id","pathway_name"))%>%
  .[,pathway_name:=pathway_name%>%str_remove(" - Homo sapiens \\(human\\)")]%>%
  .[,pathway_id:=pathway_id%>%str_remove("path:")]%>%
  .[,species_id:=1]%T>%
  {dbWriteTable(db_connect(user_db = "macrophage_mysql"),"kegg_pathways",.)}


kgenes<-function(kegg_id){"http://rest.kegg.jp/get/{kegg_id}/"%>%glue%>%
    GET%>%
    content%>%
    unlist%>%
    {fread(input = .,sep="\t",header=FALSE)}%>%
    .[grep("^\\d+",V1),str_extract(V1,"^\\d+")%>%as.numeric()%>%as.integer()]%>%
    {data.table("ncbi_id"=.)}}

kegg_gene_list<-sapply(y$pathway_id,kgenes,simplify = FALSE, USE.NAMES = TRUE)

kegg_map<-db_query("SELECT kegg_pw_id, pathway_id FROM kegg_pathways")
gene_map<-db_query("SELECT gene_id, ncbi_id FROM genes")%>%na.omit

kegg_mapping<-kegg_gene_list%>%rbindlist(idcol="pathway_id")%>%
  merge(kegg_map,on="pathway_id")%>%
  merge(gene_map,by.x="ncbi_id", by.y="ncbi_id")%>%
  .[,.(kegg_pw_id,gene_id)]%T>%
  {dbWriteTable(db_connect(user_db = "macrophage_mysql"),"kegg_pw_mapping",.)}
  
