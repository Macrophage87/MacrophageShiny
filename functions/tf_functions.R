


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
