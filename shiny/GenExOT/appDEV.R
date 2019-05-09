library(shiny)
library(DT)
library(magrittr)
library(ggplot2)
library(purrr)
library(scales)
library(ggthemes)
library(glue)

source("/data/users/stephen/Production/functions/CommonFunctions.R")
source("/data/users/stephen/Production/functions/gene_ot.R")

conflict_prefer("dataTableOutput", "DT")
conflict_prefer("renderDataTable", "DT")

gene_list<-fread("/data/users/stephen/Production/data/genes.csv")
samp_inf<-sample_info()

setupInput <- function( id ){
  ns<-NS(id)
  tagList(dataTableOutput(ns("geneTable")))
}


ui <- fluidPage(
    h3("Select a Gene of Interest"),
        setupInput("A"),
        gene_ot_ui("main"),
br(),br(),br(),br()
) 
server <- function(input, output, session) {

#  rv<-reactiveValues(sel_gene=NULL)
  
   
  #sel_gene<<-reactive()
  
  setup<-function(input,output,session){
    
    output$geneTable<-renderDataTable({
      gene_list[,.("Symbol"=gene_symbol,"Name"=gene_name,"Species"=species)]%>%lookup_table()
    })
    
    x<-reactive(gene_list[input$geneTable_rows_selected,gene_id])
    return(x)
  }
  
  genes<-callModule(setup,"A")
  callModule(gene_ot_server, "main", genes)
}

shinyApp(ui = ui, server = server)
