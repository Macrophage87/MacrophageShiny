

library("dplyr", lib.loc = "/usr/lib/R/library")

setwd("/data/users/stephen/Production")

db_connect <-
  function(database = NULL, user_db = "shiny_mysql") {
    cred <- config::get(user_db)
    require(RMariaDB)
    return(
      dbConnect(
        drv = MariaDB(),
        driver = "MySQL Driver",
        username = cred$username,
        password = cred$password,
        dbname = ifelse(is.null(database),cred$database,database),
        host  = cred$host,
        port = cred$port
      )
    )
    
  }

lookup_table <- function(data) {
  datatable(
    data,
    selection = "single",
    filter = "top",
    rownames = FALSE,
    extensions = "Scroller",
    options = list(
      pagelength = 10,
      dom = "t",
      deferRender = TRUE,
      scrollY = 200,
      scroller = TRUE
    )
  )
}


db_query <-
  function(...,
           params = NULL,
           database = NULL,
           user_db = "shiny_mysql") {
    require(glue)
    require(data.table)
    require(magrittr)
    con <- db_connect(database = database, user_db = user_db)
    
    query <- glue_sql(..., .con = con)
    
    res <- dbSendQuery(con, query)
    if (!is.null(params)) {
      dbBind(res, params)
    }
    opt <- dbFetch(res) %>% as.data.table()
    dbClearResult(res)
    dbDisconnect(con)
    
    return(opt)
  }

dt_to_df <- function(data_table_out) {
  df <- data_table_out %>% as.data.frame() %>% `[`(, -1)
  rownames(df) <- data_table_out[, c(colnames(data_table_out[, 1]) %>% get)]
  return(df)
}

dt_to_df2 <- function(data_table_out) {
  data_table_out<-yy
  
  df <- data_table_out %>% as.data.frame() %>% `[`(, -1)
  rownames(df) <- data_table_out[, c(colnames(data_table_out[, 1]) %>% get)]
  return(df)
}

db_statement <-
  function(...,
           params = NULL,
           database = NULL,
           user_db = "shiny_mysql") {
    require(glue)
    require(data.table)
    con <- db_connect(database = database, user_db = user_db)
    
    statement <- glue_sql(..., .con = con)
    
    res <- dbSendStatement(con, statement)
    if (!is.null(params)) {
      dbBind(res, params)
    }
    rows <- dbGetRowsAffected(res)
    dbClearResult(res)
    dbDisconnect(con)
    
    return(rows)
  }

pw_hash <- function(username, password, pw_date) {
  require(digest)
  digest(paste0(username, password, pw_date),
         algo = "sha512",
         serialize = FALSE)
}

token_hash <- function(page) {
  require(digest)
  token_pw <-
    config::get("auth_token", file = "/data/users/stephen/config.yml")
  digest(
    paste0(page, token_pw$token, lubridate::today()),
    algo = "sha512",
    serialize = FALSE
  )
}

gcat <- . %>% glue_col %>% cat

p_start <- function(x, ...) {
  if (getOption("verbose") == TRUE) {
    x %>% glue_data(...) %>% bold() %>% blue() %>% cat()
  }
}

p_complete <- function(x, ...) {
  if (getOption("verbose") == TRUE) {
    x %>% glue_data(...) %>% bold() %>% green() %>% cat()
  }
}
