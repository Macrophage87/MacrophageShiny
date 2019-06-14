


files<-list.dirs("~/pscan_files/")%>%
  {grep("Homo-sapiens",.,value = TRUE)}%>%
  lapply(list.files,full.names=TRUE)%>%unlist

fl<-files[1]

genes<-db_query("SELECT gene_id, gene_symbol FROM genes")

read_tf<-function(file,tf_expt_id){

fread(file)%>%
  merge(genes,by.x="tf_name",by.y = "gene_symbol")%>%
  setnames("gene_id", "tf_gene_id")%>%
  merge(genes,by.x= "target_name",by.y = "gene_symbol")%>%
  setnames("gene_id", "target_gene_id")%>%
  .[,.(tf_expt_id,tf_gene_id,target_gene_id, binding_score, p_value)]%>%
    {dbAppendTable(db_connect(user_db = "macrophage_mysql"),"trans_factor_map",.)}

}

expts<-data.table("experiment_name"=files%>%dirname%>%str_extract("//.*")%>%str_remove("//")%>%unique)%>%
  .[,"tf_expt_id":=1:.N]

fls<-data.table("files"=files,"experiment_name"=files%>%dirname%>%str_extract("//.*")%>%str_remove("//"))

tf_fls<-fls[expts,on="experiment_name"]

walk2(tf_fls[tf_expt_id==10][262:.N,files],tf_fls[tf_expt_id==10][262:.N,tf_expt_id],read_tf)
