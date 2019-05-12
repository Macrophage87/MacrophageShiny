setwd(config::get("working_directory"))


library(shiny)
library(DT)
library(magrittr)
library(ggplot2)
library(purrr)
library(scales)
library(ggthemes)
library(glue)

source("functions/CommonFunctions.R")
source("functions/gene_ot.R")

  
genes<-fread("data/genes.csv")
samp_inf<-sample_info()

ui <- fluidPage(
    h3("Select a Gene of Interest"),
        dataTableOutput("genes"),
    tabsetPanel(
        tabPanel("Plot of Expression Over Time",plotOutput("plot")),
        tabPanel("Table of Expression Over Time",dataTableOutput("infotable")),
        tabPanel("Gene Information", htmlOutput("gene_info"))
    ),
br(),br(),br(),br()
) 
server <- function(input, output, session) {
output$genes<-renderDataTable({
    genes[,.("Symbol"=gene_symbol,"Name"=gene_name,"Species"=species)]%>%lookup_table()})

sel_gene<-reactive({genes[input$genes_rows_selected,gene_id]})

genes_ot<-reactive({sel_gene()%>%gene_over_time(samples = samp_inf)})

output$plot<-renderPlot({
    if(input$genes_rows_selected%>%length==0){return(NULL)}
    genes_ot()%>%gene_ot_plot()
})

output$infotable<-renderDataTable({
    if(input$genes_rows_selected%>%length==0){return(NULL)}
    genes_ot()%>%ot_datatable()
    })  

output$gene_info<-renderText({
    if(input$genes_rows_selected%>%length==0){return(NULL)}
    sel_gene()%>%geneview()
    })

}

shinyApp(ui = ui, server = server)
