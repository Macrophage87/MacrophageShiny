library(shinydashboard)
library(shiny)
library(data.table)
library(magrittr)
library(purrr)
library(data.table)

source("/data/users/stephen/Production/functions/CommonFunctions.R")

app_list<-db_query("SELECT app_id, app_name, srv_directory, home_directory, icon, uri
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
    dashboardBody(  tags$head(tags$script('
                                var dimension = [0, 0];
                                $(document).on("shiny:connected", function(e) {
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                                $(window).resize(function(e) {
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                            ')),
                      htmlOutput("selectedPage"))
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$selectedPage<-renderText(
        glue("<iframe src='http://macrophage.cieply.com:3838/",
             "{app_list[input$tab==app_id, uri]}' width='100%'",
             "height='{input$dimension[1]}'></iframe>")
        
    )
    
}

# Run the application 
shinyApp(ui = ui, server = server)
