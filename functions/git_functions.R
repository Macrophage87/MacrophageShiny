library(git2r)
git_path<-"~/Production"

git_add<-function(path, repo=repository("~/Production")){
  git2r::add(repo = repo, path = path)
}

git_commit<-function(message,repo=repository("~/Production"),...){
  git2r::commit(repo=repo,message,...)
}

git_push<-function(object=repository("~/Production"),name="https://github.com/Macrophage87/MacrophageShiny"){
  
  cred <- config::get("github", file = "/data/users/stephen/config.yml")
  
  git_cred<-cred_user_pass(username = cred$username, password = cred$password)
  
  git2r::push(object,credentials = git_cred)
  
  message("Push successful")
}

git_acp<-function(path,message){
  git_add(path=path)
  git_commit(message=message)
  git_push()
}


