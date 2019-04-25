library(shiny)
library(DT)
library(magrittr)
library(ggplot2)
library(purrr)
library(scales)
library(ggthemes)
library(glue)

source("/data/users/stephen/Production/functions/gene_ot.R")
genes<-fread("/data/users/stephen/Production/data/genes.csv")
samp_inf<-sample_info()
tpts<-timepoints()

ui <- fluidPage(
    h3("Select a Gene of Interest"),
        dataTableOutput("genes"),
    tabsetPanel(
        tabPanel("Plot of Expression Over Time",  plotOutput("plot")),
        tabPanel("Table of Expression Over Time", dataTableOutput("infotable"))
    )

)
server <- function(input, output, session) {
output$genes<-renderDataTable({
    DT::datatable(genes[,.("Symbol"=gene_symbol,"Description"=gene_name,Species)], selection = "single", filter="top", rownames = FALSE, extensions = "Scroller",
                  options = list(pagelength=10, dom="t",
                                 deferRender = TRUE,
                                 scrollY = 200,
                                 scroller = TRUE))
})

genes_ot<-reactive({
    genes[input$genes_rows_selected,gene_id]%>%
        gene_over_time(samples = samp_inf)
})

output$plot<-renderPlot({
    if(input$genes_rows_selected%>%length==0){return(NULL)}
    genes_ot()%>%gene_ot_plot()
})

output$infotable<-renderDataTable({
    if(input$genes_rows_selected%>%length==0){return(NULL)}
    genes_ot()%>%ot_datatable()
})
}

shinyApp(ui = ui, server = server,options = list(display_mode=TRUE))
