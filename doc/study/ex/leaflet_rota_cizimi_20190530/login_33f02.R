user_base <- data_frame(
  user = c("user1", "user2"),
  password = c("pass1", "pass2"), 
  password_hash = sapply(c("pass1", "pass2"), sodium::password_store), 
  permissions = c("admin", "standard"),
  name = c("User One", "User Two")
)

credentials <- callModule(shinyauthr::login, "login", 
													data = user_base,
													user_col = user,
													pwd_col = password_hash,
													sodium_hashed = TRUE,
													log_out = reactive(logout_init()))
logout_init <- callModule(shinyauthr::logout, "logout", reactive(credentials()$user_auth))
user_info <- reactive({credentials()$info})


