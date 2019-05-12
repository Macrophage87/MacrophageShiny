library(shiny)
library(ggplot2)
library(plotly)
library(shinyWidgets)
library(viridis)

setwd("/data/users/stephen/Production")

source("functions/CommonFunctions.R")
source("functions/gene_ot.R")


timepoints<-db_query("SELECT timepoint_friendly AS timepoints
                     from timepoints ORDER BY timepoint_hrs")$timepoints
stats_by_timepoint<-fread("data/stats_by_timepoint.csv")

ui <- fluidPage(
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),

    inputPanel(
        sliderTextInput("timepoint","Select Timepoint",
                        choices = timepoints, animate = animationOptions(interval = 10*1000, loop = FALSE, playButton = NULL,
                                                                         pauseButton = NULL),
                        grid = TRUE),
        sliderTextInput("pv","Max P-Value",
                        choices = c("1e-5","1e-4","0.01","0.05","1"), grid = TRUE),
        sliderTextInput("qv","Max Q-Value",
                        choices = c("0.01","0.05","0.1","0.2","0.3","0.5","1"), grid = TRUE,
                        selected = "1"),
        sliderTextInput("fc","Min L2FC",
                        choices = c("10","5","3","2","1","0.5","0"), grid = TRUE)
        
               ),
    

        # Show a plot of the generated distribution
        tabsetPanel(
        tabPanel("Volcano Plot (Click point to view gene expression over time)",
           plotlyOutput("volcano"),
           plotOutput("plot_gene")
        ),
        tabPanel("Table of selected genes",
           dataTableOutput("dt"),
           plotOutput("plot_gene_dt")
        )
        )
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$volcano <- renderPlotly(
        volcano_plot(
            stats_by_timepoint[timepoint==input$timepoint],
            maxp  = as.numeric(input$pv),
            maxq  = as.numeric(input$qv),
            minFC = as.numeric(input$fc)
        ))

    filter<-reactive(stats_by_timepoint[timepoint==input$timepoint]%>%
                                 .[pvalue<=as.numeric(input$pv)]%>%
                                 .[qvalue<=as.numeric(input$qv)]%>%
                                 .[abs(L2FC)>=as.numeric(input$fc)])
    
        output$dt<-renderDataTable(
            filter()%>%
            .[order(pvalue),.("Symbol"=gene_symbol,"Name"=gene_name,L2FC,
                 "P-value"=pvalue,"Q-value"=qvalue)]%>%
            lookup_table()
        
        
    )
    
    plt_click<-reactive(event_data("plotly_click")%>%unlist%>%extract(2))
    click_gene<-reactive(filter()%>%.[plt_click()+1])
    
    output$plot_gene<-renderPlot({
        y<-click_gene()
        
        y[,gene_id]%>%gene_over_time()%>%gene_ot_plot(title = y[,gene_symbol])
    }) 

    output$plot_gene_dt<-renderPlot({
        y<-filter()%>%.[order(pvalue)]%>%.[input$dt_rows_selected]
        y[,gene_id]%>%gene_over_time()%>%gene_ot_plot(title = y[,gene_symbol])
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
