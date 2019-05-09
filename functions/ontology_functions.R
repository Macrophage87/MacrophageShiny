library(forcats)
library(viridis)


samp_inf<-sample_info(numeric_tp=FALSE)

pca_ocf<-.%>%
  dcast(gene_symbol~sample_id,value.var="ltpm",fun=median)%>%
  dt_to_df()%>%
  prcomp( center = TRUE,scale. = TRUE)

pca_sample_inf<-.%>%`$`(rotation)%>%as.data.table(keep.rownames = "sample_id")%>%.[,sample_id:=as.numeric(sample_id)]%>%merge(samp_inf,by="sample_id")


plot_pca<-function(pca_out){ggplot(pca_out,aes(x=PC1,y=PC2, color=timepoint, shape=type,size=11))+
    geom_point()+
    scale_colour_brewer(palette="Dark2")+
    guides(size="none")}


pca_genes_ot<-function(pca_values,sel_ont_genes){
  
  pca_vals<-pca_out$x%>%as.data.table(keep.rownames = "gene_symbol" )
  
  sel_ont_genes[samp_inf,on="sample_id"][pca_vals,on="gene_symbol"]%>%
    na.omit%>%
      .[,.("L2FC"=mean(ltpm[sample_type_id==2])-
             mean(ltpm[sample_type_id==1])
           ),
      by=c("gene_id","gene_symbol","timepoint","PC1","PC2")]%>%
    dcast(gene_symbol+gene_id+PC1+PC2~timepoint)%>%
    .[order(-PC1)]
  
}

gene_ont_datatable<-function(pca_genes_otd){
  pca_genes_otd<-pca_genes_otd%>%copy%>%.[,gene_id:=NULL]
  
  brks <- seq(from=-3,to=3,length.out = 255)
  clrs <- cividis(256)
  
  datatable(pca_genes_otd,selection = "single", rownames = FALSE, extensions = "Scroller",
            options = list(pagelength=20, dom="ft",
                           deferRender = TRUE,
                           scrollY = 200,
                           scroller = TRUE))%>%
    formatRound(2:8)%>%
    formatStyle(
      4:8,
      fontWeight = 'bold',
      color = styleInterval(-0.001,c("lightblue",'black')),
      backgroundColor = styleInterval(brks, clrs)
    )
  
}



# reg_ontologies<-db_query("SELECT 
#   O.ont_sql_id,
#   O.`ontology_name`,
#   OA.`timepoint`,
#   OA.`total_genes`,
#   OA.`sig_genes`,
#   OA.`nlogp` 
# FROM
#   ontology_analysis OA 
#   JOIN ontologies O 
#     ON O.`ont_sql_id` = OA.`ont_sql_id` 
# ORDER BY nlogp DESC")%T>%fwrite("data/reg_ontologies.csv")%>%
#   dcast(ontology_name+ont_sql_id~timepoint)%>%
#   .[order(-(`4`+`24`+`336`+`672`+`1008`))]%T>%
#   fwrite("data/reg_ontology_chart.csv")
