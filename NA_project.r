### Network analysis  Data ###

#------------------------------------------------------------------------
# Part of InstaCrawlR
# Git Hub: https://github.com/JonasSchroeder/InstaCrawlR
# Code by Jonas Schröder
# See ReadME for instructions and examples
# Version 3: Additional column for export (post_url based on shortlinks)
# Last Updated July 2019
#------------------------------------------------------------------------

library(jsonlite)
library(stringr)
library("jpeg")
library(tidyr)
library(utf8)

#Download JSON File from Instagram for a specific Hashtag

######## ! МОСКОВСКОЕ ДЕЛО ! ########

hashtag <- "Московскоедело"
url_start <- str_glue("http://instagram.com/explore/tags/{hashtag}/?__a=1")
json <- fromJSON(url_start)
edge_hashtag_to_media <- json$graphql$hashtag$edge_hashtag_to_media
end_cursor <- edge_hashtag_to_media$page_info$end_cursor
posts <- edge_hashtag_to_media$edges$node

#Extract Information per Post

index <- 1
post_id <- list()
post_url <- list()
post_text <- list()
post_time <- list()
post_likes <- list()
post_owner <- list()
post_img_url <- list()

extractInfo <- function(index){
  print("extractInfo function called")
  maxrows <- nrow(posts)
  for(i in 1:maxrows){
    if(i == maxrows){
      assign("index", index, envir = .GlobalEnv)
      assign("post_id", post_id, envir = .GlobalEnv)
      assign("post_text", post_text, envir = .GlobalEnv)
      assign("post_time", post_time, envir = .GlobalEnv)
      assign("post_img_url", post_img_url, envir = .GlobalEnv)
      assign("post_url", post_url, envir = .GlobalEnv)
      assign("post_likes", post_likes, envir = .GlobalEnv)
      assign("post_owner", post_owner, envir = .GlobalEnv)
      getNewPosts(index)
    } else {
      if(length(posts$edge_media_to_caption$edges[[i]][["node"]][["text"]])==0){
        post_text[index] <- "no-text"
        print("no text in post")
      } else {
        temp <- posts$edge_media_to_caption$edges[[i]][["node"]][["text"]]
        post_text[index] <- gsub("\n", " ", temp)
      }
      
      post_id_temp <- posts[i,5]
      post_url[index] <-  str_glue("http://instagram.com/p/{post_id_temp}")
      post_id[index] <- post_id_temp
      post_time[index] <- toString(as.POSIXct(posts[i,7], origin="1970-01-01"))
      post_img_url[index] <- posts[i,9]
      post_likes[index] <- posts[i,11]
      post_owner[index] <- posts[i,12]
      
      #optional: download image
      #img_dir <- str_glue("images/{index}_{hashtag}_post_img.jpg")
      #download.file(posts[i,8], img_dir, mode = 'wb')
      
      index <- index + 1
    }
  }    
}

#Get New Posts from Instagram

getNewPosts <- function(index){
  print("getNewPosts function called")
  url_next <- str_glue("{url_start}&max_id={end_cursor}")
  json <- fromJSON(url_next)
  edge_hashtag_to_media <- json$graphql$hashtag$edge_hashtag_to_media
  end_cursor <- edge_hashtag_to_media$page_info$end_cursor
  posts <- edge_hashtag_to_media$edges$node
  assign("end_cursor", end_cursor, envir = .GlobalEnv)
  assign("posts", posts, envir = .GlobalEnv)
  print(index)
  Sys.sleep(1)
  extractInfo(index)
}

#Start the Madness

extractInfo(index)

table <- do.call(rbind.data.frame, Map('c', post_id, post_url, post_img_url, post_likes, post_owner, post_text, post_time))
colnames(table) <- c("ID", "Post_URL", "Img_URL", "Likes", "Owner", "Text", "Date")


#Import Table and Extract Hashtags
text <- list()
htemp <- list()
htags <- data.frame()

data <- as.matrix(table[-1])

maxrows <- nrow(data)
for(i in 1:maxrows){
  text[i] <- as.character(data[i,5])
  htemp <- str_extract_all(text[i], "#\\S+", TRUE)
  
  if(ncol(htemp) != 0){
    for(j in 1:ncol(htemp)){
      htags[i,j] <- htemp[1,j]
    }  
  }
} 

#Save Hashtags as csv for Excel
write.csv(htags, "NA_Moscowcase_edges_R-data.csv", fileEncoding = "UTF-8")
df_htags <- as.data.frame(table(unlist(htags)))
write.csv(df_htags, "NA_Moscowcase_nodes_R-data.csv", fileEncoding = "UTF-8")

######## ! МОСГОРДУМА ! ########

hashtag <- "Мосгордума"
url_start <- str_glue("http://instagram.com/explore/tags/{hashtag}/?__a=1")
json <- fromJSON(url_start)
edge_hashtag_to_media <- json$graphql$hashtag$edge_hashtag_to_media
end_cursor <- edge_hashtag_to_media$page_info$end_cursor
posts <- edge_hashtag_to_media$edges$node

#Extract Information per Post

index <- 1
post_id <- list()
post_url <- list()
post_text <- list()
post_time <- list()
post_likes <- list()
post_owner <- list()
post_img_url <- list()

#Start the Madness

extractInfo(index)

#--
#Export Dataframe to CSV()
#--
table <- do.call(rbind.data.frame, Map('c', post_id, post_url, post_img_url, post_likes, post_owner, post_text, post_time))
colnames(table) <- c("ID", "Post_URL", "Img_URL", "Likes", "Owner", "Text", "Date")


#Import Table and Extract Hashtags
text <- list()
htemp <- list()
htags <- data.frame()

data <- as.matrix(table[-1])

maxrows <- nrow(data)
for(i in 1:maxrows){
  text[i] <- as.character(data[i,5])
  htemp <- str_extract_all(text[i], "#\\S+", TRUE)
  
  if(ncol(htemp) != 0){
    for(j in 1:ncol(htemp)){
      htags[i,j] <- htemp[1,j]
    }  
  }
} 

#Save Hashtags as csv for Excel
write.csv(htags, "NA_Mosgorduma_edges_R-data.csv", fileEncoding = "UTF-8")
df_htags <- as.data.frame(table(unlist(htags)))
write.csv(df_htags, "NA_Mosgorduma_nodes_R-data.csv", fileEncoding = "UTF-8")

######## ! ДОПУСКАЙ ! ########

hashtag <- "Допускай"
url_start <- str_glue("http://instagram.com/explore/tags/{hashtag}/?__a=1")
json <- fromJSON(url_start)
edge_hashtag_to_media <- json$graphql$hashtag$edge_hashtag_to_media
end_cursor <- edge_hashtag_to_media$page_info$end_cursor
posts <- edge_hashtag_to_media$edges$node

#Extract Information per Post

index <- 1
post_id <- list()
post_url <- list()
post_text <- list()
post_time <- list()
post_likes <- list()
post_owner <- list()
post_img_url <- list()

#Start the Madness

extractInfo(index)

#--
#Export Dataframe to CSV()
#--
table <- do.call(rbind.data.frame, Map('c', post_id, post_url, post_img_url, post_likes, post_owner, post_text, post_time))
colnames(table) <- c("ID", "Post_URL", "Img_URL", "Likes", "Owner", "Text", "Date")


#Import Table and Extract Hashtags
text <- list()
htemp <- list()
htags <- data.frame()

data <- as.matrix(table[-1])

maxrows <- nrow(data)
for(i in 1:maxrows){
  text[i] <- as.character(data[i,5])
  htemp <- str_extract_all(text[i], "#\\S+", TRUE)
  
  if(ncol(htemp) != 0){
    for(j in 1:ncol(htemp)){
      htags[i,j] <- htemp[1,j]
    }  
  }
} 


#Save Hashtags as csv for Excel
write.csv(htags, "NA_Dopuskai_edges_R-data.csv", fileEncoding = "UTF-8")
df_htags <- as.data.frame(table(unlist(htags)))
write.csv(df_htags, "NA_Dopuskai_nodes_R-data.csv", fileEncoding = "UTF-8")
