all_ontologies<-readRDS("~/Production/data/all_mapped_ontologies.RDS")


ont_map<-get_OBO("http://purl.obolibrary.org/obo/go.obo")

ont_map_dt<-data.table("ontology_id"=ont_map$id,"ontology_name"=ont_map$name,"ontology_obs"=ont_map$obsolete)%>%
  .[ontology_obs==FALSE]%>%.[grep("GO:",ontology_id)]%>%.[,ontology_obs:=NULL]

ont_list<-db_query("SELECT ont_sql_id, ontology_id, ontology_name FROM ontologies")


ont<-fread("~/Production/data/6wk_ontologies.csv")

zz<-merge(ont,ont_list, by.x="ontology", by.y="ontology_id")%>%
  .[,.(ont_sql_id,timepoint,sig_genes,total_genes,nlogp)]%>%
  .[,timepoint:=24*7*6]%T>%
  {dbWriteTable(db_connect(user_db = "macrophage_mysql"),"ontology_analysis",.,append=TRUE)}




reg_ontologies<-db_query("SELECT 
  O.`ontology_name`,
  OA.`timepoint`,
  OA.`total_genes`,
  OA.`sig_genes`,
  OA.`nlogp` 
FROM
  ontology_analysis OA 
  JOIN ontologies O 
    ON O.`ont_sql_id` = OA.`ont_sql_id` 
ORDER BY nlogp DESC")

by_tpt<-reg_ontologies%>%dcast(ontology_name~timepoint)

by_tpt[,"median":=pmap_dbl(list(`4`,`24`,`336`,`672`,`1008`),function(...)median(...,na.rm = TRUE))]



ont_genes<-fread("data/ont_genes.csv")

dbWriteTable(db_connect(user_db = "macrophage_mysql"),"ontology_genes",ont_genes)
