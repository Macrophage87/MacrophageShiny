library(glue)
library(ggplot2)
library(DT)
library(data.table)
library(ggthemes)
library(purrr)
library(scales)
library(KEGGgraph)
source("/data/users/stephen/Production/functions/CommonFunctions.R")

genes<-function(update=FALSE){
  gns<-db_query("SELECT DISTINCT G.gene_id, G.gene_symbol, G.gene_name, S.common_name AS species
FROM genes G 
JOIN transcript_values TV ON G.gene_id = TV.gene_id 
JOIN species S ON G.species_id = S.species_id
WHERE TV.TPM >0")
  
  if(update){fwrite(gns,"/data/users/stephen/Production/data/genes.csv")}

  return(gns)
}

value_lookup<-function(gene_id){
  db_query("SELECT gene_id, LOG(2,TV.TPM+1) AS ltpm, sample_id
           FROM transcript_values TV
           WHERE gene_id IN (?)",params=list(gene_id))
}

sample_info<-function(){db_query("SELECT SIV.sample_id, SIV.sample_type_id, ST.sample_type_name AS type,
                      SIV.timepoint
                          FROM sample_info_virus SIV
                      JOIN sample_types ST ON SIV.sample_type_id = ST.sample_type_id")}

tt<-possibly(t.test,otherwise = NA_real_)

gene_over_time<-function(gene_id,samples=sample_info()){
y<-value_lookup(gene_id)%>%merge(samples,on="sample_id")
pv<-y[,.("pvalue"=tt(
             ltpm[sample_type_id==1],
             ltpm[sample_type_id==2])$p.value),
         by=c("timepoint")]
sum<-y[,.("mean"=mean(ltpm),"sem"=sd(ltpm)/sqrt(.N), .N),by=c("sample_type_id","type","timepoint")]
out<-merge(pv,sum,on="timepoint")%>%setorder("timepoint","sample_type_id")
return(out)
}


timepoints<-function(gene_ot){db_query("SELECT timepoint_hrs, timepoint_friendly FROM timepoints
                       WHERE timepoint_hrs IN (?)",params=list(gene_ot[,timepoint%>%unique]))}

gene_ot_plot<-function(gene_ot, log=FALSE, tpts=timepoints(gene_ot),title=NULL){
  
  plt<-ggplot(gene_ot,aes(x=timepoint,y=mean,color=type))+
    geom_line()+
    geom_errorbar(mapping = aes(ymin=mean-sem,ymax=mean+sem))+
    theme_tufte(base_size = 16)+
    scale_y_continuous(name="Log2 Normalized Gene Expression")+
    guides(col=guide_legend(title=""))+
    theme(legend.position="bottom")+
    ggtitle(title)
    
  

  if(log){
    plt<-plt+scale_x_log10(breaks = tpts[,timepoint_hrs],
                      labels = tpts[,timepoint_friendly],
                      name="Time Post Infection")    
  }else{
  plt<-plt+scale_x_continuous(breaks = tpts[,timepoint_hrs],
                         labels = tpts[,timepoint_friendly],
                         name="Time Post Infection")
  }
 return(plt)
}


pva<-function(p_val){ifelse(p_val<=0.05,pvalue2asterisk(p_val),"")}

p_val_pretty<-function(p_val){paste(pvalue(p_val),pva(p_val))}

ot_datatable<-function(gene_ot, tpts=timepoints(gene_ot)){
  
  x<-tpts[gene_ot,on=c("timepoint_hrs"="timepoint")]%>%
    .[,"value":=map2_chr(mean, sem,function(x,y)glue("{x%>%round(2)} (±SEM {y%>%round(2)})"))]%>%
    setorder("timepoint_hrs")

  y<-dcast.data.table(x,timepoint_hrs~type,value.var = c("value"))%>%
    merge(x[,.("L2FC"=sum(mean[sample_type_id==2])-
                 sum(mean[sample_type_id==1])),by="timepoint_hrs"])%>%
    merge(x[,.("P-value"=mean(pvalue)%>%{paste(pvalue(.),pva(.))}),by="timepoint_hrs"])%>%
    .[,"L2FC":=paste0(L2FC%>%signif(3)," (",ifelse(L2FC>=0,
                                     paste0(signif(2^L2FC,3),"X"),
                                     paste0("1/",signif(2^-L2FC,3)))
                     ,")")]
    
  
  tpts[y,on="timepoint_hrs"]%>%
    .[,timepoint_hrs:=NULL]%>%
    setnames("timepoint_friendly","Timepoint")%>%
    datatable(options = list(dom="Bt",buttons = 
    c('copy', 'csv', 'excel', 'pdf', 'print')),extensions = "Buttons",rownames = FALSE)
}

ncbi_gn_get<-function(gene_id){
  db_query("SELECT ncbi_id FROM genes WHERE gene_id=?",params = list(gene_id))
}

geneview<-function(gene_id){
  glue("<iframe src='https://www.ncbi.nlm.nih.gov/gene/",
  "{ncbi_gn_get(gene_id)}' width='100%'",
  "height='1000px'></iframe>")
}

downstream<-function(tf_gene_id, limit=100){db_query("SELECT DISTINCT target_gene_id
         FROM trans_factor_map WHERE tf_gene_id =? 
         ORDER BY binding_score DESC LIMIT ?",params=list(tf_gene_id,limit))%>%unlist}

upstream<-function(target_gene_id, limit=100){db_query("SELECT DISTINCT tf_gene_id
         FROM trans_factor_map WHERE target_gene_id =? 
         ORDER BY binding_score DESC LIMIT ?",params=list(target_gene_id,limit))%>%unlist}

gene_data<-function(gns){db_query("
SELECT G.`gene_id`, G.`gene_symbol`, LOG(2,TV.`TPM`+1) AS ltpm, 
      SIV.`sample_type_id`, ST.sample_type_name,
      SIV.`timepoint`, T.timepoint_friendly
FROM genes G 
  JOIN transcript_values TV
    ON TV.`gene_id` = G.`gene_id`
  JOIN sample_info_virus SIV
    ON SIV.`sample_id` = TV.`sample_id`
  JOIN sample_types ST ON SIV.sample_type_id = ST.sample_type_id
  JOIN timepoints T ON SIV.timepoint=T.timepoint_hrs
WHERE G.gene_id IN (?)
",params=list(gns))
}

 

gene_matrix<-function(g_dt){
  all0<-g_dt[,all(ltpm==0),by='gene_id'][V1==TRUE]
  
  g_dt[!all0,on="gene_id"][,.("L2FC"=mean(ltpm[sample_type_id==2])-mean(ltpm[sample_type_id==1]))
                              ,by=c("gene_symbol","timepoint")]%>%
    dcast.data.table(gene_symbol~timepoint)
  }

gene_heatmap<-function(g_mat){
  df<-g_mat[,-1]%>%as.data.frame()
  rownames(df)<-g_mat[,gene_symbol]

pheatmap(df,cluster_cols = FALSE,labels_col=c('4h','24h','2wk','4wk','6wk'),
         angle_col=0,show_rownames = ifelse(g_mat[,.N]<=30,TRUE,FALSE))
}


tpt_values<-function(tpt)db_query("SELECT G.gene_id, G.gene_symbol, G.gene_name,
          LOG(2,TV.TPM+1) AS ltpm,
          SIV.sample_type_id,
          TP.timepoint_friendly AS timepoint
          FROM transcript_values TV 
          JOIN sample_info_virus SIV ON SIV.sample_id=TV.sample_id
          JOIN timepoints TP ON SIV.timepoint = TP.timepoint_hrs
          JOIN genes G ON TV.gene_id = G.gene_id
          WHERE SIV.timepoint =?",params=list(tpt))


tpt_stats<-function(gene_values, tp_merge=FALSE){
  all0<-gene_values[,.("sd"=sd(ltpm),"max"=max(ltpm)),by="gene_symbol"][sd==0|max<2]
  
  if(tp_merge==TRUE){
    m_by<-c("gene_id","gene_symbol","gene_name")
  }else{m_by<-c("gene_id","gene_symbol","gene_name","timepoint")}
  
  gene_values%>%.[!all0,on="gene_symbol"]%>%
    .[,.("pvalue"=tt(ltpm[sample_type_id==2],
                     ltpm[sample_type_id==1])["p.value"]%>%unlist,
         "L2FC"=mean(ltpm[sample_type_id==2])-
           mean(ltpm[sample_type_id==1]),
         "median_expr"=median(ltpm)
    ),
    by=m_by]%>%
    .[,"qvalue":=qvalue::qvalue(pvalue)$qvalue]
}


volcano_plot<-function(data, maxq=0.2, minFC = 0, maxp=0){

    plt<-data%>%
    ggplot(aes(x=L2FC, y=pval))+
    stat_density_2d(aes(fill = stat(level)), n=100
                    , geom = "polygon"
                    )+
    scale_fill_viridis(option = "B")+
    geom_point(
      data=data[qvalue<=maxq][abs(L2FC)>= minFC][pvalue<=maxp],
      aes(x=L2FC, y=pval,
          text=glue("</br>
                                 Name: {gene_symbol}
                                 Symbol: {gene_name}
                                 P-value: {pvalue}
                                 Q-value: {qvalue}")))+
      theme_tufte(base_size = 18)+
      scale_x_continuous(name = "Log2 Fold Change")+
      scale_y_continuous(name = "-Log10(P-Value)")+
      theme(legend.position = "none")
    

#    scale_y_continuous(name=expression("Log"[2]*" Fold Change"))
    
    
  
  
  ggplotly(plt)
}
