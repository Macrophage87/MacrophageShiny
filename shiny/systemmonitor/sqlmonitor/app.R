
library(shiny)
library(dygraphs)
library(shinyWidgets)
library(data.table)
library(xts)
library(lubridate)


source("/data/users/stephen/Production/functions/CommonFunctions.R")

change_ot<-.%>%
    copy%>%
    .[,prev_entry:=dimension%>%shift]%>%
    .[,prev_time:=created_at%>%shift]%>%
    .[,change_per_hour:=(dimension-prev_entry)/
          difftime(created_at%>%ymd_hms,prev_time,"hours")%>%as.numeric()]%>%
    na.omit%>%
    .[,.(created_at,change_per_hour)]


servers<-db_query(user_db = "systemmonitor","SELECT id, description FROM servers")


ui <- fluidPage(

        inputPanel(
            selectizeInput("server", "Select a server:",
                           choices=servers$description),
            selectizeInput("dimension", "Select a dimension:",
                choices=list("Queries"="queries",
                             "Opens"="opens",
                             "qps_avg")),
            radioGroupButtons("change","Select Type",choices = c("Total","Change Per Hour")),
            numericInput("roll","Roll Period",0,min=0,step=1)
               
            
        ),
    mainPanel(
           dygraphOutput("over_time")
        )
    
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

    
    sql_data<-reactivePoll(10*1000, session= session,
                           checkFunc =function()db_query("SELECT MAX(created_at) FROM systemmysql",user_db="systemmonitor"),
        valueFunc = function(){db_query(glue("SELECT created_at, {input$dimension}
         FROM systemmysql 
         WHERE server_id=?"),
                 params=list(servers[description==input$server,id]),
                               user_db="systemmonitor")%>%
        .[,lapply(.SD,as.numeric),by='created_at']%>%setnames(input$dimension,"dimension")})
    
    
    output$over_time <- renderDygraph({
       dt<-sql_data()

                if(input$change == "Change Per Hour"){dt%<>%change_ot}
        
        dt%>%
            as.xts.data.table()%>%
            dygraph()%>%
            dyRoller(showRoller = FALSE, rollPeriod = 10*input$roll)%>%
            dyRangeSelector()
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
