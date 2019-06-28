library(dplyr)

user_base <- tibble::tibble(
  user = c("user1", "user2"),
  password = c("pass1", "pass2"), 
  password_hash = sapply(c("pass1", "pass2"), sodium::password_store), 
  permissions = c("admin", "standard"),
  name = c("User One", "User Two")
)

user_info <- shiny::reactive({credentials()$info})


