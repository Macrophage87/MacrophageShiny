library(shiny)
library(DT)
library(magrittr)
library(ggplot2)
library(purrr)
library(scales)
library(ggthemes)
library(glue)
#library(plotly)


options(shiny.reactlog=TRUE)


source("/data/users/stephen/Production/functions/gene_ot.R")

genes<-fread("/data/users/stephen/Production/data/genes.csv")

#plt<-.%>%{genes[.,on="gene_symbol",gene_id]}%>%gene_over_time()

 
ui <- fluidPage(

    #selectInput("gene","Select Gene",selectize = TRUE, choices = genes$gene_symbol),
    
    dataTableOutput("genes"),
    plotOutput("plot"),
    dataTableOutput("infotable")
    #fluidRow(column(,width=6)),
    
    #fluidRow()
    
)

# Define server logic required to draw a histogram
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
        gene_over_time()
})

output$plot<-renderPlot({
    if(input$genes_rows_selected%>%length==0){return(NULL)}
    genes_ot()%>%gene_ot_plot()
})


output$infotable<-renderDataTable({
    genes_ot()%>%ot_datatable()
    })

    
}


# Run the application 
shinyApp(ui = ui, server = server,options = list(display_mode=TRUE))
