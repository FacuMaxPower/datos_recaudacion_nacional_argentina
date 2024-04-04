# Lectura de archivos recaudación AFIP

library(stringr)

dr <- read.csv("AFIP/recaudacion_link_acceso.csv", encoding = "UTF-8")

dr$Tipo_Archivo <- NA

for (i in 1:nrow(dr)){
  if (str_detect(string = dr$Link.Acceso[i], pattern = "\\.htm$")) {
    dr$Tipo_Archivo[i] <- "HTML"
  } else if (str_detect(string = dr$Link.Acceso[i], pattern = "\\.xls$")) {
    dr$Tipo_Archivo[i] <- "XLS"
  } else {
    dr$Tipo_Archivo[i] <- "Desconocido"
  }
}

library(rvest)

url <- dr$Link.Acceso[8]
url <- gsub("\"", "", url)
page <- read_html(url)
tables <- html_table(page)
print(tables)

table.df <- as.data.frame(tables)
encabezado <- tolower(as.character(table.df[1,]))
colnames(table.df) <- encabezado
table.df <- table.df[-1, ]
num.cols <- 2:ncol(table.df)
table.df[,num.cols] <- lapply(table.df[,num.cols], function(x) as.numeric(gsub(",","",x)))
non_numeric <- sapply(table.df[, num.cols], function(x) any(!is.na(x) & !is.numeric(x)))
table.df[,1] <- tolower(table.df[,1])
table.df$concepto <- gsub("\\s+", " ", table.df$concepto)

library(tidyr)

table.df.long <- gather(data = table.df,key = "mes",value = "valores",enero : total)

install.packages("gdata")
library(gdata)
library(readxl)
nombre_archivo <- basename(url)
carpeta_destino <- "C:/Users/Facu/Documents/AFIP/Archivos locales"
archivo_local <- file.path(carpeta_destino, nombre_archivo)
download.file(url, archivo_local, mode = "wb")
xls.df <- read_xls(archivo_local)

xls.df <- read_xls("https://contenidos.afip.gob.ar/institucional/estudios/archivos/serie2003.xls")
