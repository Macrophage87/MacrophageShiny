library(glue)
library(ggplot2)
library(DT)
library(data.table)
library(ggthemes)
library(purrr)
library(scales)
source("/data/users/stephen/Production/functions/CommonFunctions.R")

genes<-function(){
  db_query("SELECT DISTINCT G.gene_id, G.gene_symbol, G.gene_name, S.common_name AS species
FROM genes G 
JOIN transcript_values TV ON G.gene_id = TV.gene_id 
JOIN species S ON G.species_id = S.species_id
WHERE TV.TPM >0")
}

value_lookup<-function(gene_id){
  db_query("SELECT LOG(2,TV.TPM+1) AS ltpm, sample_id
           FROM transcript_values TV
           WHERE gene_id = ?",params=list(gene_id))
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

gene_ot_plot<-function(gene_ot, log=FALSE, tpts=timepoints(gene_ot)){
  
  plt<-ggplot(gene_ot,aes(x=timepoint,y=mean,color=type))+
    geom_line()+
    geom_errorbar(mapping = aes(ymin=mean-sem,ymax=mean+sem))+
    theme_tufte(base_size = 16)+
    scale_y_continuous(name="Log2 Normalized Gene Expression")+
    guides(col=guide_legend(title=""))
  

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

pvf<-pvalue_format(0.05)

ot_datatable<-function(gene_ot, tpts=timepoints(gene_ot)){
  
  x<-tpts[gene_ot,on=c("timepoint_hrs"="timepoint")]%>%
    .[,"value":=map2_chr(mean, sem,function(x,y)glue("{x%>%round(2)} (±SEM {y%>%round(2)})"))]%>%
    setorder("timepoint_hrs")

  y<-dcast.data.table(x,timepoint_hrs~type,value.var = c("value"))%>%
    merge(x[,.("L2FC"=sum(mean[sample_type_id==2])-
                 sum(mean[sample_type_id==1])),by="timepoint_hrs"])%>%
    merge(x[,.("P-value"=mean(pvalue)%>%pvalue),by="timepoint_hrs"])
  
  tpts[y,on="timepoint_hrs"][,timepoint_hrs:=NULL]%>%setnames("timepoint_friendly","Timepoint")%>%
    datatable(options = list(dom="t"),rownames = FALSE)%>%formatRound("L2FC")
}

ncbi_gn_get<-function(gene_id){
  db_query("SELECT ncbi_id FROM genes WHERE gene_id=?",params = list(gene_id))
}

geneview<-function(gene_id){
  glue("<iframe src='https://www.ncbi.nlm.nih.gov/gene/",
  "{ncbi_gn_get(gene_id)}' width='100%'",
  "height='1000px'></iframe>")
}
