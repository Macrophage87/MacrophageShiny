setwd(config::get("working_directory"))
library(shiny)
library(magrittr)
source("functions/CommonFunctions.R")
source("functions/gene_ot.R")
source("functions/kegg_functions.R")
source("functions/tf_functions.R")

ui <- fluidPage(
    hide_errors(),
    tf_table_ui("tf"),
    tabsetPanel(
        tabPanel("Regulated Gene Info", tf_target_ui("heatmap"),
                 gene_ot_ui("target")),
        tabPanel("Transcription Factor Info",gene_ot_ui("transf"))
    )
)

server <- function(input, output,session) {
    sel_tf<-callModule(tf_table,"tf")
    callModule(gene_ot_server,"transf",sel_tf)
    sel_target<-callModule(tf_target,"heatmap",sel_tf)
    callModule(gene_ot_server,"target",sel_target)
}

shinyApp(ui = ui, server = server)
