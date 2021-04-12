
# shiny login app

## Logs

### Örnek uygulamalar 

#### Örnek uygulama: authentication and database

https://shiny.rstudio.com/gallery/authentication-and-database.html

``` bash
git clone https://gist.github.com/trestletech/9793754 login
``` 

Check `/Users/mertnuhoglu/codes/rr/shiny_ex/login/server.R`

``` r
install.packages(c("RSQLite", "sqldf", "hflights"))
install.packages("sqldf")
``` 

Bu örnek shiny server pro gerektiriyor. 

#### Örnek uygulama: Shiny-App-User-Authentication

https://github.com/bormanjo/Shiny-App-User-Authentication

Check `/Users/mertnuhoglu/codes/rr/shiny_ex/Shiny-App-User-Authentication/server`

#### Örnek uygulama: auth0 ile

https://auth0.com/blog/adding-authentication-to-shiny-server/

https://github.com/auth0/shiny-auth0

#### Örnek uygulama:

https://stackoverflow.com/questions/28987622/starting-shiny-app-after-password-input

Check `~/codes/rr/shiny_ex/login02/login02.R`

This works.

``` r
source("login02.R")
``` 

#### shinyauthr:

https://github.com/paulc91/shinyauthr

``` r
devtools::install_github("paulc91/shinyauthr")
``` 

Check `~/codes/rr/shiny_ex/shinyauthr01/shinyauthr01.R`

It works

``` r
source("shinyauthr01.R")
``` 

##### shinyauthr with shinydashboard

https://github.com/PaulC91/shinyauthr/blob/master/inst/shiny-examples/shinyauthr_example/app.R

Check `~/codes/rr/shiny_ex/shinyauthr01/shinyauthr02.R`

``` r
source("shinyauthr02.R")
``` 

#### Örnek uygulama: shiny_password

https://github.com/treysp/shiny_password

#### Örnek uygulama: google login before shiny

https://code.markedmondson.me/googleAuthR/reference/gar_shiny_ui.html

``` r
install.packages("googleAuthR")
``` 

Check `~/codes/rr/shiny_ex/googleauthr01/googleauthr01.R`

``` r
source("googleauthr01.R")
``` 

Follow:

https://cloud.r-project.org/web/packages/googleAuthR/vignettes/google-authentication-types.html

https://code.markedmondson.me/googleAuthR/articles/troubleshooting.html

https://lmyint.github.io/post/shiny-app-with-google-login/

#### Örnek uygulama: auth0 with reverse proxy apache

https://auth0.com/blog/adding-authentication-to-shiny-open-source-edition/

https://auth0.com/blog/adding-authentication-to-shiny-server/

## Examples

Ref: `login ekranı koyalım <url:/Users/mertnuhoglu/projects/itr/fmcgvrp/pmap/doc/study/leaflet_rota_cizimi_20190530.md#tn=login ekranı koyalım>`


