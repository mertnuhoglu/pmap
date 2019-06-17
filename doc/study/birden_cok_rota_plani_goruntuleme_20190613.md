
# Birden çok rota planını haritada göstermek mümkün olsun 20190613 

## Mevcut kodu incele

Bir dropdown olmalı, mevcut planları seçmeye izin veren.

Mevcut planları ideal durumda veritabanından çekmeli, ama şimdilik pvrp_data/out içindeki klasörlerden alalım.

## Belli bir klasördeki tüm plan dosyalarını selectInput ile listele

`/Users/mertnuhoglu/projects/itr/peyman/pvrp_data/out`

``` bash
ls out
  ##> report_20190526_00   
``` 

Klasörleri listeleyelim.

``` r
list.files(path = glue::glue("{PEYMAN_PROJECT_DIR}/pvrp_data/out"), include.dirs = T, pattern = "^report_\\d+.*")
``` 

`plan_select` değişince, `routes_all` da değişmeli.

Bu durumda bu reactive bir değer olmalı.

### Error: harita değişmedi planı değiştirdiğimde

`state$routes_all` hiçbir şeyi etkilemiyor.

