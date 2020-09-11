library(here)
source(here("code", "code_01_setup.R"))

# Problema: Descargar los datos del personal a contrata del Hospital Barros Luco en 
#           agosto 2020 del Portal de Transparencia.

# Solución con rvest
url_transparencia <- "https://www.portaltransparencia.cl/PortalPdT/pdtta/-/ta/AO080/PR/PCONT/53654951"
# https://www.portaltransparencia.cl/PortalPdT/pdtta?codOrganismo=AO080  > 4. Personal y remuneraciones > Personal a Contrata > Año 2020 > Agosto

transparencia <- read_html(url_transparencia)
transparencia <- transparencia %>% html_node(css = "table") #xpath = "//table")
transparencia <- transparencia %>% html_table()
transparencia <- transparencia %>% as_tibble()
transparencia


# Solución con RSelenium y rvest
remDr <- remoteDriver(
  remoteServerAddr = "192.168.99.100",
  port = 4445L
)
remDr$closeall()
remDr$open(silent = TRUE)
remDr$navigate(url_transparencia)
siguiente <- remDr$findElement(using = 'xpath', value = "//span[@class='ui-icon ui-icon-seek-next']")
siguiente$highlightElement()
siguiente$clickElement()
table_url <- remDr$getPageSource() %>% extract2(1)

transparencia <- read_html(table_url)
transparencia <- transparencia %>% html_node(css = "table") #xpath = "//table")
transparencia <- transparencia %>% html_table()
transparencia <- transparencia %>% as_tibble()
transparencia

# Solución con RSelenium, rvest e implementando funciones, recolecta todos los registro en 27 páginas

remDr <- remoteDriver(
  remoteServerAddr = "192.168.99.100",
  port = 4445L
)

get_last      <- function(url, remDr){
  remDr$closeall()
  remDr$open(silent = TRUE)
  remDr$navigate(url)
  ultimo <- remDr$findElement(using = 'xpath', value = "//span[@class='ui-paginator-last ui-state-default ui-corner-all']")
  ultimo$clickElement()
  Sys.sleep(0.5)
  activo <- remDr$findElement(using = 'xpath', value = "//span[@class='ui-paginator-page ui-state-default ui-corner-all ui-state-active']")
  activo <- activo$getElementText() %>% extract2(1) %>% as.numeric()
  primero <- remDr$findElement(using = 'xpath', value = "//span[@class='ui-icon ui-icon-seek-first']")
  primero$clickElement()
  Sys.sleep(0.5)
  return(activo)
}
get_table_url <- function(page, remDr, last){
  activo <- remDr$findElement(using = 'xpath', value = "//span[@class='ui-paginator-page ui-state-default ui-corner-all ui-state-active']")
  activo <- activo$getElementText() %>% extract2(1) %>% as.numeric()
  if(activo == page){
    table_url <- remDr$getPageSource() %>% extract2(1)
  }else{
    table_url <- "error"
  }
  if(activo != last){
    siguiente <- remDr$findElement(using = 'xpath', value = "//span[@class='ui-icon ui-icon-seek-next']")
    siguiente$clickElement()
    Sys.sleep(0.5)
  }
  return(table_url)
}
get_table     <- function(table_url){
  tabla <- read_html(table_url)
  tabla <- tabla %>% html_node(css = "table") #xpath = "//table")
  tabla <- tabla %>% html_table()
  tabla <- tabla %>% as_tibble()
  tabla
} 

last <- get_last(url_transparencia, remDr)

data <- tibble(page = 1:last)
data <- data %>% mutate(table_url = page      %>% map(get_table_url, remDr, last))
data <- data %>% mutate(table     = table_url %>% map(get_table))
data <- data %>% select(-table_url)
data <- data %>% unnest(table)
