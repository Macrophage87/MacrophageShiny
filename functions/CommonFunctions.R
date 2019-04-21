

db_connect<-function(database="transcriptome", user_db="shiny_mysql"){
  
  
  cred<-config::get(user_db, file = "Production/config.yml")
  
  require(RMariaDB)
  
  
  return(dbConnect(
    drv = MariaDB(),
    driver = "MySQL Driver",
    username = cred$username,
    password = cred$password,
    dbname = database,
    host  = cred$host,
    port = cred$port
  ))
  
}

db_query<-function(...,params=NULL,database="transcriptome",user_db="shiny_mysql"){
  require(glue)
  require(data.table)
  require(magrittr)
  con<-db_connect(database=database, user_db=user_db)
  
  query<-glue_sql(...,.con = con)
  
  res<-dbSendQuery(con,query)
  if(!is.null(params)){dbBind(res,params)}
  opt<-dbFetch(res)%>%as.data.table()
  dbClearResult(res)
  dbDisconnect(con)
  
  return(opt)
}

db_statement<-function(...,params=NULL,database="transcriptome",user_db="shiny_mysql"){
  require(glue)
  require(data.table)
  con<-db_connect(database=database,user_db=user_db)
  
  statement<-glue_sql(...,.con = con)
  
  res<-dbSendStatement(con,statement)
  if(!is.null(params)){dbBind(res,params)}
  rows<-dbGetRowsAffected(res)
  dbClearResult(res)
  dbDisconnect(con)
  
  return(rows)
}

pw_hash<-function(username, password,pw_date){
  require(digest)
  digest(paste0(username,password,pw_date),algo="sha512",serialize = FALSE)
}

gcat<-.%>%glue_col%>%cat

p_start<-function(x, ...){
  if(getOption("verbose")==TRUE){x%>%glue_data(...)%>%bold()%>%blue()%>%cat()}  
}

p_complete<-function(x, ...){
  if(getOption("verbose")==TRUE){x%>%glue_data(...)%>%bold()%>%green()%>%cat()}  
}  
