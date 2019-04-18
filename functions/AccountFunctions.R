create_user<-function(username,email){
  require(gmailr)
  require(password)
  require(lubridate)
  require(digest)
  
  password<-password(12)
  
  pw_date<-today()
  
  pw_hash<-digest(paste0(username,password,pw_date),algo="sha512",serialize = FALSE)
  
  val<-db_statement("INSERT INTO users (username, password, email, pw_date) VALUES (?,?,?,?)",
               params = list(username,pw_hash,email,pw_date),
               database="investigators")
  
  if(val==0){return(FALSE)}
  
  gmail_auth()
  
  url<-"https://macrophage.cieply.com"
  
  body<-glue("
Greetings! This is an automated message, but any replies to this address will be seen and likely replied to.

An account has been created for you on Macrophage Analytics ({url}), \\
a bioinfomatics analysis platform that is currently in development.

You may access this site using the following credentials:

Username: {username}
Password: {password}             

This is a one-time use password and you will be prompted to change your password.

If there are any issues, concerns, or suggestions, please feel free to contact me. 
             ")
  
  
  
  msg<-mime(body=body)%>%
    from("sjcieply@gmail.com")%>%
    to(email)%>%
    subject("Macrophage Analytics Account Created")
  
  send_message(msg)
  
}

reset_password<-function(username){
  require(gmailr)
  require(password)
  require(lubridate)
  require(digest)
  
  
  user_info<-db_query("SELECT user_id, email FROM users WHERE username = ? AND offline =0",
                  params = list(username),
                  database="investigators")
  
  if(length(user_info)==0){
    cat("There is no valid email associated with that username.")
    return(NULL)}
  
  password<-password(12)
  
  pw_date<-today()
  
  pw_hash<-digest(paste0(username,password,pw_date),algo="sha512",serialize = FALSE)
  
  val<-db_statement("UPDATE users SET password = ?, pw_date= ?, one_time_pw = 1 WHERE user_id = ?",
                    params = list(pw_hash,pw_date,user_info$user_id),
                    database="investigators")
  
  if(val==0){return(FALSE)}
  
  gmail_auth()
  
  body<-glue("
This is an automated message, but any replies to this address will be seen and likely replied to.

Your account credentials were reset with Macrophage Analytics. Your new password is below:

Password: {password}             

This is a one-time use password and you will be prompted to change your password.

If there are any issues, concerns, or suggestions, please feel free to contact me. 
             ")

  msg<-mime(body=body)%>%
    from("sjcieply@gmail.com")%>%
    to(email)%>%
    subject("Macrophage Analytics Password Reset")
  
  send_message(msg)
  
}


degen_DNA<-function(x){
  x%>%
    gsub("R","[A|G]",.)%>%
    gsub("Y","[C|T]",.)%>%
    gsub("M","[A|C]",.)%>%
    gsub("K","[G|T]",.)%>%
    gsub("S","[C|G]",.)%>%
    gsub("W","[A|T]",.)%>%
    gsub("B","[C|G|T]",.)%>%
    gsub("D","[A|G|T]",.)%>%
    gsub("H","[A|C|T]",.)%>%
    gsub("V","[A|C|G]",.)%>%
    gsub("N","[A|C|G|T]",.)
}

