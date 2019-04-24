library(shiny)
library(shinyjs)
library(lubridate)

ui <- fluidPage(
  useShinyjs(),
  fluidRow(id="login",
    column(6, offset=3,
           br(),
           
           wellPanel(
             textInput("user",
                       "User ID:",
                       width = "70%"),
             passwordInput(inputId = 'password',
                           label = 'Password',
                           width = "70%"),
             
             actionButton("button_login", "Login"),
             strong(textOutput("verification_result"))
           )
    )
  ),
  
  hidden(fluidRow(id="change",
    column(6, offset=3,
           br(),wellPanel(
                                 h3("Please change your password:"),
                                 "Your new password must be at least 8 characters.",
                                 passwordInput(inputId = 'new_pw_1',
                                               label = 'New Password',
                                               width = "70%"),
                                 passwordInput(inputId = 'new_pw_2',
                                               label = 'Confirm Password',
                                               width = "70%"),
                                 actionButton("change_pw", "Change Password"),
                                 strong(textOutput("change_result"))
           )))),
  
  
  mainPanel(width = 12,
            uiOutput("ui_page_1",width='100%',height='1024px')
        
  )
)

server <- function(input, output,session) {
  
  current_user_status <- reactiveValues()
  current_user_status$logged <- FALSE
  current_user_status$current_user <- NULL
  current_user_status$user_id <- NULL


  output$ui_page_1 <- renderUI({
    
    if(current_user_status$logged == TRUE){
      tagList(
          shinyAppDir("/data/users/stephen/Production/shiny/GenExOT",
                      options = list(width='100%',height='1024px'))
        )  
      
      }
      
    
    
  })


  observeEvent(input$button_login, {
    
    if(input$user=="" | input$password==""){return(NULL)}
      
      credentials<-db_query("SELECT user_id, username, password, pw_date, one_time_pw FROM users WHERE username = ?"
                            ,params=list(input$user),
                            database="investigators")

      if(credentials[,.N]==0){
        output$verification_result <- renderText({"Login failed"})
        return(NULL)
      }
      
    if(credentials$password==
       pw_hash(credentials$username,input$password,credentials$pw_date)){
      
      current_user_status$current_user <- input$user
      current_user_status$user_id <- credentials$user_id
      
      hideElement("login")
      
      if(credentials$one_time_pw ==1){
      show("change")
      }else{current_user_status$logged <- TRUE}
      
      
      db_statement(
      "INSERT INTO user_logins
      (user_id, created_at) 
      VALUES ({credentials$user_id},{now(tz='UTC')})",database = "investigators", user_db="macrophage_mysql")
      
      

      } else {
      current_user_status$logged <- FALSE
      current_user_status$current_user <- NULL
      
      output$verification_result <- renderText({
        "Login failed"
      })
      }
    
  })
  
  
  observeEvent(input$change_pw, {
    
    if(input$new_pw_1!=input$new_pw_2){
      output$change_result <- renderText("The two passwords must match.")
      return(NULL)
    }
    
    if(nchar(input$new_pw_1)<8){
      output$change_result <- renderText("The password is not at least 8 characters.")
      return(NULL)
    }
    
      pw_date<-today()
  
      pw_hash<-digest(paste0(current_user_status$current_user,input$new_pw_1,pw_date),algo="sha512",serialize = FALSE)
          
      val<-db_statement("UPDATE users SET password = ?, pw_date= ?, one_time_pw = 0 WHERE user_id = ?",
                        params = list(pw_hash,pw_date,current_user_status$user_id),
                        database="investigators")

      output$change_result <- renderText("Password successfully changed.")
      
      current_user_status$logged <- TRUE  
              
      hide("change")
      
  })
  
}

shinyApp(ui = ui, server = server)

