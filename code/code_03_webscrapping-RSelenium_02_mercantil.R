library(here)
source(here("code", "code_01_setup.R"))

# Problema: A partir de una bases de datos con RUT de empresas de 
#           estudio de mercado obtener más info desde mercantil.com

data <- tribble(~ rut       , 
                "96583240-8",
                "76069565-3",
                "78574400-4",
                "76203048-9",
                "78370920-1")

remDr <- remoteDriver(
  remoteServerAddr = "192.168.99.100",
  port = 4445L
)
remDr$closeall()
remDr$open(silent = TRUE)

url_mercantil <- "https://www.mercantil.com/"

remDr$navigate(url_mercantil)

buscador_text   <- remDr$findElement(using = "xpath", value = "//div[@class='buscador']/input[@type='text']")
buscador_submit <- remDr$findElement(using = "xpath", value = "//div[@class='buscador']/input[@type='submit']")

buscador_text$highlightElement()
buscador_submit$highlightElement()

get_url    <- function(text, remDr){
  buscador_text   <- remDr$findElement(using = "xpath", value = "//div[@class='buscador']/input[@type='text']")
  buscador_submit <- remDr$findElement(using = "xpath", value = "//div[@class='buscador']/input[@type='submit']")
  
  buscador_text$highlightElement()
  buscador_submit$highlightElement()
  
  buscador_text$sendKeysToElement(list(text))
  buscador_submit$clickElement()
  
  empresa1     <- try(remDr$findElement(using = "xpath", value = "//div[@class='empresa1']"), silent = TRUE)
  
  if(empresa1 %>% class %>% extract(1) %>% equals("webElement")){
    try(remDr$mouseMoveToLocation(webElement = empresa1))
  }
  
  mas_detalles <- try(remDr$findElement(using = "xpath", value = "//div[@class='detalle_boton']/a[@id='compLink']"), silent = TRUE)
  
  url <- try(mas_detalles$getElementAttribute("href"), silent = TRUE)
  url <- url %>% pluck(1)
  return(url)
}
get_phones <- function(url, remDr){
  
  remDr$navigate(url)
  phone_1 <- try(remDr$findElement(using = "xpath", value = "//div[contains(@id,'phon_phones')]/span[1]/a")$getElementAttribute("href") %>% extract2(1), silent = TRUE)
  phone_2 <- try(remDr$findElement(using = "xpath", value = "//div[contains(@id,'phon_phones')]/span[2]/a")$getElementAttribute("href") %>% extract2(1), silent = TRUE)
  phone_3 <- try(remDr$findElement(using = "xpath", value = "//div[contains(@id,'phon_phones')]/span[3]/a")$getElementAttribute("href") %>% extract2(1), silent = TRUE)
  phone_1 <- if(phone_1 %>% class == "character"){phone_1}else{"error"}
  phone_2 <- if(phone_2 %>% class == "character"){phone_2}else{"error"}
  phone_3 <- if(phone_3 %>% class == "character"){phone_3}else{"error"}
  return(list(phone_1, phone_2, phone_3))
}
get_name   <- function(url, remDr){
  
  remDr$navigate(url)
  name <- try(remDr$findElement(using = "xpath", value = "//a[contains(@itemprop,'name')]")$getElementAttribute("title") %>% extract2(1), silent = TRUE)
  return(name)
}

data <- data %>% mutate(url    = rut %>% map_chr(~suppress_messages(.x %>% get_url(remDr), "Selenium message") %>% extract2(1)))
data <- data %>% mutate(phones = url %>% map(~suppress_messages(.x %>% get_phones(remDr), "Selenium message")))
data <- data %>% unnest(phones)
data <- data %>% unnest(phones)
data <- data %>% filter(phones != "error")
data <- data %>% mutate(names = url %>% map(~.x %>% get_name(remDr)))
data <- data %>% unnest(names)
data <- data %>% unnest(names)
data

url <- "https://www.freelancer.com/freelancers/skills/all?ngsw-bypass=&w=f"
remDr$navigate(url)
siguiente <- remDr$findElement(using = 'xpath', value = "//li/a[@class='btn Pagination-link']")
siguiente$highlightElement()
