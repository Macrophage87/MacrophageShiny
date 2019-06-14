library(viridisLite)
library(viridis)


kegg_pw_genes<-function(pw_id, g_names=FALSE){
  
  if(g_names==FALSE){
  db_query("SELECT DISTINCT G.`gene_id`, G.`ncbi_id`
           
           FROM kegg_pw_mapping KPW 
           JOIN genes G ON KPW.`gene_id` = G.`gene_id`
           JOIN transcript_values TV ON TV.gene_id = G.gene_id
           WHERE kegg_pw_id = ? 
           AND TV.TPM >0",params=list(pw_id))
  }else{
  db_query("SELECT DISTINCT G.`gene_id`, G.`ncbi_id`,
           G.gene_symbol, G.gene_name
           FROM kegg_pw_mapping KPW 
           JOIN genes G ON KPW.`gene_id` = G.`gene_id`
           JOIN transcript_values TV ON TV.gene_id = G.gene_id
           WHERE kegg_pw_id = ? 
           AND TV.TPM >0",params=list(pw_id))}

}


kegg_ot<-function(genes,s=sample_info()){
  gx<-value_lookup(genes$gene_id)
  
  gx[genes, on="gene_id"]%>%
    .[s,on="sample_id"]%>%
    na.omit%>%
    .[,.("L2FC"=mean(ltpm[sample_type_id==2])-
                mean(ltpm[sample_type_id==1])),
      by=c("timepoint","gene_id","gene_symbol","gene_name")]%>%
    dcast(gene_id+gene_symbol+gene_name~timepoint)%>%setorder("gene_id")%>%
    setnames(c("4","24","336","672","1008"),
             c("4h","24h","2wk","4wk","6wk"))
}

ab_max<-possibly(function(x)ifelse(is.numeric(x),x,0)%>%abs%>%max,otherwise=0)

kegg_datatable<-function(kegg_ot_o){
  kegg_ot_o2<-kegg_ot_o%>%copy%>%.[,gene_id:=NULL]

  brks <- seq(from=-3,to=3,length.out = 255)
  clrs <- cividis(256)
  
  datatable(kegg_ot_o2,selection = "single", rownames = FALSE, extensions = "Scroller",
            options = list(pagelength=20, dom="ft",
                           deferRender = TRUE,
                           scrollY = 200,
                           scroller = TRUE))%>%
    formatRound(3:7)%>%
    formatStyle(
      3:7,
      fontWeight = 'bold',
      color = styleInterval(-0.001,c("lightblue",'black')),
      backgroundColor = styleInterval(brks, clrs)
    )
  
}



kegg_df<-function(kegg_genes,s=sample_info()){
  sapply(kegg_genes$gene_id%>%as.character,
          gene_over_time, 
          samples=s,USE.NAMES = TRUE, simplify = FALSE)%>%
  rbindlist(idcol="gene_id")%>%
  .[,gene_id:=gene_id%>%as.integer()]%>%
  merge(kegg_genes,on="gene_id")%>%
  .[,.("L2FC"=mean(mean[sample_type_id==2])
       -mean(mean[sample_type_id==1])),by=c("ncbi_id","timepoint")]%>%
  dcast(ncbi_id~timepoint)%>%dt_to_df()
}

kpid<-function(kegg_pw_id){
  db_query("SELECT pathway_id FROM kegg_pathways WHERE kegg_pw_id = ?",
           params=list(kegg_pw_id))$pathway_id%>%
    str_remove("hsa")}

kegg_pw_plot<-function(kegg_pw,
                       kegg_dir="/data/users/stephen/Production/kegg",
                       kegg_native=TRUE){

  gene_info<-kegg_pw_genes(kegg_pw)
  
  if(gene_info%>%nrow==0){return(NULL)}
  gene_info%<>%kegg_df()
  
  pathview(gene.data  = gene_info,
         pathway.id = kpid(kegg_pw),
         species    = "hsa",
         low=list(gene="blue"),
         high=list(gene="yellow"),
         limit      = list(gene=max(abs(gene_info)), cpd=1),
         kegg.native = kegg_native,
         kegg.dir = kegg_dir)
}
KPP<-possibly(kegg_pw_plot,otherwise = NA)

# files<-list.files("/data/users/stephen/Production/kegg",pattern=".*\\.pathview\\.multi\\.png")%>%
#   str_remove(".pathview.multi.png")
# 
# db_statement("UPDATE kegg_pathways SET png_exists = 1 WHERE pathway_id IN ({files*})",user_db = "macrophage_mysql")




