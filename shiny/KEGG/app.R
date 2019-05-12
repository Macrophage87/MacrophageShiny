setwd(config::get("working_directory"))

library(shiny)
library(magrittr)

source("functions/CommonFunctions.R")
source("functions/gene_ot.R")
source("functions/kegg_functions.R")



kegg_pws<-db_query("SELECT kegg_pw_id, pathway_id, pathway_name FROM kegg_pathways WHERE png_exists =1")
 
ui <- fluidPage(
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
        mainPanel(
           dataTableOutput("keggpw"),
           
           tabsetPanel(
               tabPanel("KEGG Image",imageOutput("kegg_image")),
               tabPanel("Table of Associated Genes",
                        tabsetPanel(
                            tabPanel("All Genes in Ontology", dataTableOutput("kegg_DT")),
                            tabPanel("Selected Gene Graph Over Time",plotOutput("plot")),
                            tabPanel("Selected Gene Table",dataTableOutput("infotable")),
                            tabPanel("Selected Gene Information",htmlOutput("gene_info"))
                        )
               )
           )
        ,width=12)
    )

server <- function(input, output, session) {
    observe({
        strg<-parseQueryString(session$clientData$url_search)
        if(strg$a != token_hash("KEGG")){q()}
    })
    
    output$keggpw <- renderDataTable({
        kegg_pws[,.("Pathway ID"=pathway_id,"Pathway Name"=pathway_name)]%>%
            lookup_table()})
    
    output$kegg_image <-renderImage({
    if(input$keggpw_rows_selected%>%is.null){return(FALSE)} 
    if(input$keggpw_rows_selected%>%length==0){return(FALSE)}
    if(input$keggpw_rows_selected==""){return(FALSE)}
            
            
        filename <- glue("kegg/",
                         "{kegg_pws[input$keggpw_rows_selected,pathway_id]}.pathview.multi.png")
        list(src = filename) 
    }, deleteFile = FALSE)
    
    kegg_ot_rc<-reactive(kegg_pws[input$keggpw_rows_selected,kegg_pw_id]%>%
            kegg_pw_genes(TRUE)%>%kegg_ot())
    
    output$kegg_DT<-renderDataTable({ 
        if(input$keggpw_rows_selected%>%is.null){return(FALSE)} 
        if(input$keggpw_rows_selected%>%length==0){return(FALSE)}
        kegg_ot_rc()%>%kegg_datatable})
   
    sel_gene<-reactive({kegg_ot_rc()%>%.[input$kegg_DT_rows_selected,gene_id]})
    
    genes_ot<-reactive({
        sel_gene()%>%gene_over_time()
    })
    
    output$plot<-renderPlot({
        if(input$kegg_DT_rows_selected%>%length==0){return(NULL)}
        genes_ot()%>%gene_ot_plot() 
    })
     
    output$infotable<-renderDataTable({
        if(input$kegg_DT_rows_selected%>%length==0){return(NULL)}
        genes_ot()%>%ot_datatable() 
    })  
    
    output$gene_info<-renderText({
        if(input$kegg_DT_rows_selected%>%length==0){return(NULL)}
        sel_gene()%>%geneview()
    })
    
}

shinyApp(ui = ui, server = server)
