setwd(config::get("working_directory"))

library(shinydashboard)
library(shiny) 
library(data.table)
library(magrittr)
library(purrr)
library(data.table)
source("functions/CommonFunctions.R")
  
 
app_list<-db_query("SELECT app_id, app_name, icon, uri, description
                   FROM app_list WHERE offline=0 ORDER BY `order`")
create_menu_item<-function(app_name,app_id){
    list(menuItem(text=app_name, tabName=app_id))
}
menu_list<-map2(app_list$app_name,app_list$app_id,create_menu_item)

ui <- dashboardPage(
    dashboardHeader(title="Macrophage Analytics"),
    dashboardSidebar(
        sidebarMenu(id='tab',.list=menu_list)
    ),
    dashboardBody(  get_screen_size(),
                      htmlOutput("selectedPage"))
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$selectedPage<-renderText(
        glue("<iframe src='http://macrophage.cieply.com:3838/",
             "{app_list[input$tab==app_id, uri]}/",
             "?a={app_list[input$tab==app_id, uri]%>%token_hash}'",
             " width='100%'",
             " height='{max(input$dimension[1],1500)}'></iframe>")
    )

}

shinyApp(ui = ui, server = server)
