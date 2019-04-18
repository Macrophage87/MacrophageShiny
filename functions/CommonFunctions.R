db_connect<-function(database="transcriptome"){
  
  require(RMariaDB)
  
  
  return(dbConnect(
    drv = MariaDB(),
    driver = "MySQL Driver",
    username = "stephen",
    password = "KrL64aPL$fHtw6LRFi0V",
    dbname = database,
    host  = "macrophage.cieply.com",
    port = 3306
  ))
  
}

db_query<-function(...,params=NULL,database="transcriptome"){
  require(glue)
  require(data.table)
  require(magrittr)
  con<-db_connect(database=database)
  
  query<-glue_sql(...,.con = con)
  
  res<-dbSendQuery(con,query)
  if(!is.null(params)){dbBind(res,params)}
  opt<-dbFetch(res)%>%as.data.table()
  dbClearResult(res)
  dbDisconnect(con)
  
  return(opt)
}

db_statement<-function(...,params=NULL,database="transcriptome"){
  require(glue)
  require(data.table)
  con<-db_connect(database=database)
  
  statement<-glue_sql(...,.con = con)
  
  res<-dbSendStatement(con,statement)
  if(!is.null(params)){dbBind(res,params)}
  rows<-dbGetRowsAffected(res)
  dbClearResult(res)
  dbDisconnect(con)
  
  return(rows)
}


gcat<-.%>%glue_col%>%cat

p_start<-function(x, ...){
  if(getOption("verbose")==TRUE){x%>%glue_data(...)%>%bold()%>%blue()%>%cat()}  
}

p_complete<-function(x, ...){
  if(getOption("verbose")==TRUE){x%>%glue_data(...)%>%bold()%>%green()%>%cat()}  
}  
