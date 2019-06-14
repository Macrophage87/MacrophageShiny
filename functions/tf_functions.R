
library(plotly)
library(data.table)


transcription_factors<-function(){
  
  db_query("SELECT G.gene_id, G.gene_symbol, TS.timepoint, TS.nlogp
                    FROM tf_statistics TS
                    JOIN genes G ON TS.tf_gene_id = G.gene_id
                   ")%>%
    dcast(gene_id+gene_symbol~timepoint)%>%
    setnames(colnames(.),c("gene_id","transcription_factor","4h", "24h", "2wk", "4wk", "6wk"))
  
}

tf_table_ui<-function(id){
  ns<-NS(id)
dataTableOutput(ns("tf_table"))
}

tf_table<-function(input,output,session,tf=transcription_factors()){
  
  output$tf_table<-renderDataTable(tf%>%
      .[,.("Transcription Factor"=transcription_factor,
           `4h`,`24h`,`2wk`,`4wk`,`6wk`)]%>%lookup_table()%>%
        formatRound(2:6,digits=1))
  
  sel_tf<-reactive(tf[input$tf_table_rows_selected,gene_id])
  
  return(sel_tf)
  
}

ab_max<-possibly(function(x)ifelse(is.numeric(x),x,0)%>%abs%>%max,otherwise=0)

source("functions/kegg_functions.R")

tf_target_ui<-function(id){
  ns<-NS(id)
  dataTableOutput(ns("tf_dt"))
}


tf_genes<-function(tf_gene_id,limit=50){

db_query("SELECT G.gene_id, G.gene_symbol, G.gene_name 
FROM trans_factor_map TF
JOIN genes G ON TF.target_gene_id = G.gene_id
WHERE TF.tf_gene_id = ?
GROUP BY TF.target_gene_id 
ORDER BY TF.binding_score DESC 
Limit ?",
params= list(tf_gene_id,limit))

}


  
tf_target<-function(input,output,session,tf){

  gene_list<-reactive(tf_genes(tf(), limit=50))

  output$tf_dt<-renderDataTable({
    
    gene_list()%>%kegg_ot()%>%kegg_datatable()
    
    })
  
  sel_target<-reactive(
                      gene_list()%>%
                        setorder("gene_id")%>%
                        .[input$tf_dt_rows_selected,gene_id]
                       )
  
  return(sel_target)
  
}



