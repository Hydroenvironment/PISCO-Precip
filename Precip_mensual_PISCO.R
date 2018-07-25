setwd("D:/juliohydraulics/PISCO_treatment") # Ruteamos la carpeta de trabajo 
# Para descargar datos PISCO (.nc) dirigirse a: http://www.senamhi.gob.pe/?p=observacion-de-inundaciones
# Dar click en la parte que menciona "Datos SONICS (DESCARGAS)"
# La versión 2.0 tiene una carpeta llamada: PISCO_v2.0 - ftp://ftp.senamhi.gob.pe/PISCO_v2.0/
rm(list = ls())
install.packages("raster") #Instalar el paquete 
install.packages("ncdf4") #Instalar el paquete
library(raster) #cargar el paquete
library(ncdf4) #cargar el paquete
##Comenzamos con la lectura de un archivo de dos columnas "longitud" y "latitud" (coordenadas geográficas)
long_lat <- read.csv("long_lat.csv", header = T)
### Incluimos a nuestro código el archivo *.nc de PISCO
raster_pp <- raster::brick("PISCOpm.nc")
## Se asignan las coordenadas al recién creado "long_lat"
sp::coordinates(long_lat) <- ~XX+YY
# El archivo que se genere a partir del .csv debe tener la misma proyección que la del archivo .nc de PISCO
raster::projection(long_lat) <- raster::projection(raster_pp)
# Se hace la extraccción de valores acorde a las coordenadas del archivo .csv
points_long_lat <- raster::extract(raster_pp[[1]], long_lat, cellnumbers = T)[,1]
data_long_lat <- t(raster_pp[points_long_lat])
colnames(data_long_lat) <- as.character(long_lat$NN)
# Guardamos los datos como "datosPISCO_mens.csv"
# El archivo guardará una tabla en donde las columnas muestran los puntos del archivo .csv y las columnas la precipitación mensual en mm
write.csv(data_long_lat, "datosPISCO_mens.csv", quote = F)
