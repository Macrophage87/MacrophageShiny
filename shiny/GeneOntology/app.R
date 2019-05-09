#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
setwd("/data/users/stephen/Production/")

library(shiny)
library(DT)
library(data.table)
library(ggplot2)
#library(conflicted)

source("functions/CommonFunctions.R")
source("functions/gene_ot.R")
source("functions/ontology_functions.R")

# conflict_prefer("dataTableOutput", "DT")
# conflict_prefer("renderDataTable", "DT")
# 


reg_ont_chart<-fread("data/reg_ontology_chart.csv")

ui <- fluidPage(
  
      dataTableOutput("ontTable"),
      tabsetPanel(
        tabPanel("PCA Plot",plotOutput("distPlot")),
        tabPanel("PCA Loadings", dataTableOutput("pcaTable"))
      ),
      tabsetPanel(
        tabPanel("Plot of Expression Over Time",plotOutput("plot")),
        tabPanel("Table of Expression Over Time",dataTableOutput("infotable")),
        tabPanel("Gene Information", htmlOutput("gene_info"))
      )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  output$ontTable<-renderDataTable(reg_ont_chart%>%
                                     .[,.("Ontology Name"=ontology_name,
                                          "4h"=`4`,
                                          "24h"=`24`,
                                          "2wk"=`336`,
                                          "4wk"=`672`,
                                          "6wk"=`1008`)]%>%lookup_table%>%formatRound(2:6,digits=0))
  
  sel_ont<-reactive(reg_ont_chart[input$ontTable_rows_selected,ont_sql_id])

sel_ont_genes<-reactive({
    db_query("SELECT 
  G.`gene_id`,
  G.`gene_symbol`,
  LOG(2, TV.`TPM` + 1) AS ltpm,
  TV.`sample_id` 
FROM
  ontology_gene_map OGM 
  JOIN genes G 
    ON G.`gene_id` = OGM.`gene_id` 
  JOIN transcript_values TV 
    ON TV.`gene_id` = OGM.`gene_id` 
WHERE OGM.ont_sql_id = ?",params=list(sel_ont()))
    
  })
pca<-reactive(sel_ont_genes()%>%pca_ocf)

pca_genes<-reactive(pca_genes_ot(pca(),sel_ont_genes()))

output$distPlot <- renderPlot(pca()%>%pca_sample_inf()%>%plot_pca())

output$pcaTable<-renderDataTable(pca_genes()%>%gene_ont_datatable)

sel_gene<-reactive(pca_genes()%>%.[input$pcaTable_rows_selected,gene_id])

genes_ot<-reactive(sel_gene()%>%gene_over_time(samples = sample_info()))

output$plot<-renderPlot({
  genes_ot()%>%gene_ot_plot()
})

output$infotable<-renderDataTable({
  genes_ot()%>%ot_datatable()
})  

output$gene_info<-renderText({
  sel_gene()%>%geneview()
})
    
  
}

# Run the application 
shinyApp(ui = ui, server = server)
