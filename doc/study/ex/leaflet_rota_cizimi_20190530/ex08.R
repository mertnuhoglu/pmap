library(dplyr, warn.conflicts = FALSE)

df <- data.frame(x1 = rep(1:3, times = 3), x2 = 1:9)
df$x3 <- df %>% mutate(x3 = x2)
as_tibble(df)
