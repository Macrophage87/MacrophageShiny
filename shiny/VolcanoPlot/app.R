setwd(config::get("working_directory"))

library(shiny)
library(ggplot2)
library(plotly)
library(shinyWidgets)
library(viridis)

source("functions/CommonFunctions.R")
source("functions/gene_ot.R")

ui <- fluidPage(
  hide_errors(),
    volcano_ui("volc"), 
    gene_ot_ui("gene_ot")
)
server <- function(input, output) {
gene_id<-callModule(volcano_server,"volc")
callModule(gene_ot_server,"gene_ot",gene_id)
}

shinyApp(ui = ui, server = server)