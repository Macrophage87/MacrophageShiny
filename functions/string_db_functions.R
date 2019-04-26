
string_image<-function(genes,nodes=10,type="svg",html=FALSE){
  x<-glue("https://string-db.org/api/{type}/network?",
       "identifiers={paste0(genes,collapse='%0d')}",
       "&add_white_nodes={nodes}")

  if(html){return(glue("<img src='{x}'/>"))}else{return(x)}
}

string_genes<-function(genes,nodes=10){
  url<-glue("https://string-db.org/api/tsv/network?",
       "identifiers={paste0(genes,collapse='%0d')}",
       "&add_color_nodes={nodes}")
  
  tryCatch(fread(url),finally = fread(url))
  
}

string_values<-function(str_g){
  str_g[,c(preferredName_A,preferredName_B)]%>%
    unique%>%
    {db_query("SELECT TV.sample_id, G.gene_id,
              G.gene_symbol, LOG(2,TV.TPM+1) AS ltpm 
              FROM transcript_values TV
              JOIN genes G ON G.gene_id = TV.gene_id
              WHERE G.gene_symbol IN (?)",
              params = list(.))}
}

tpts<-db_query("SELECT timepoint_hour as timepoint, 
               timepoint_friendly AS Timept 
               FROM timepoints")

string_table<-function(str_v,samp=sample_info()){
  merge(str_v,samp,on="sample_id")%>%
    merge(tpts, by="timepoint")%>%
    .[,.("L2FC"=mean(ltpm[sample_type_id==2])-
                mean(ltpm[sample_type_id==1]),
         "pvalue"=tt(ltpm[sample_type_id==2],
                     ltpm[sample_type_id==1])$p.value%>%{-log(.)}),
      by=c("gene_symbol","Timept")] %>%
     dcast.data.table(gene_symbol~Timept, value.var = c("L2FC"))
   
}


#ggplot(data = zz, aes(y=gene_symbol,x=Timept,color=L2FC,size=pvalue))+geom_point()
