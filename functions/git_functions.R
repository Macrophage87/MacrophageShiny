library(git2r)
git_path<-"~/Production"

git_add<-function(path, repo=repository("~/Production")){
  git2r::add(repo = repo, path = path)
}

git_commit<-function(repo=repository("~/Production"),...){
  commit(repo=repo,...)
}
