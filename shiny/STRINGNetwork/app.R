#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)

string_genes("STAT1",nodes= 1)
string_genes("STAT1",nodes= 1)

ui <- fluidPage(
        mainPanel(
            sliderInput("nodes",
                        "Number of Nodes:",
                        min = 1,
                        max = 50,
                        value = 10),
            
           htmlOutput("network"),
           dataTableOutput("results")
        )
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    #fread("https://string-db.org/api/tsv/network?identifiers=STAT1&add_nodes=10")
    
    selected<-reactive(string_genes("STAT1",nodes= input$nodes)%>%
                           string_values()%>%
                           string_table())
    
    output$network<-renderText({
        sel_genes<-c("STAT1",selected()
                     %>%.[input$results_rows_selected,gene_symbol])%>%
            unique
        
        
        string_image(sel_genes,type='image',nodes = input$nodes, html=TRUE)})
    
    
    output$results<-renderDataTable(selected()%>%
                                   datatable()%>%
                                   formatRound(2:7)
                                   )
    
    
}
# Run the application 
shinyApp(ui = ui, server = server)
