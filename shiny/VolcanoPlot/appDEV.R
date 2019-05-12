library(shiny)
library(ggplot2)
library(plotly)
library(shinyWidgets)
library(viridis)
setwd("/data/users/stephen/Production")
source("functions/CommonFunctions.R")
source("functions/gene_ot.R")

ui <- fluidPage(
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    volcano_ui("volc"),
    gene_ot_ui("gene_ot")
)
server <- function(input, output) {
gene_id<-callModule(volcano_server,"volc")
callModule(gene_ot_server,"gene_ot",gene_id)
}

# Run the application 
shinyApp(ui = ui, server = server)