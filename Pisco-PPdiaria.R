library(raster)
library(ggplot2)
library(ncdf4)
library(maptools)

setwd("C:/Users/USER/Desktop/DATOS")     ## Ubicación de la carpeta donde est?n los archivos *.tif o el *.nc
ts = seq(as.Date("1981-01-01"),as.Date("2016-12-31"),by = "day")      ## Secuencia de fechas (a?o%-mes%-dia%), puede cambiar "month" por "day" o "year"
st = stack(list.files(pattern=".tif"))                                ## Si son *.tif
nc = brick("C:/Users/USER/Desktop/DATOS/LLUVIA/PISCO V2.0/PISCOpd.nc")## Si es *.nc

########################################################################## Caso Shapefile

pt = shapefile("C:/Users/USER/Desktop/BASE GIS/SHAPEFILES/Estaciones_Catchira_GEO.shp")                          ## Si tiene puntos como shp
ext = extract(nc, pt)                                                   ## Extract, para sacar los puntos
plot(ext[2,],type = "l")
df = data.frame(ts,ext[5,])                                             ## El 2 lo puede cambiar por el n?mero de punto que quiere(si es un s?lo punto tambi?n)
plot(df,type = "p")                                                     ## Plot1
plot(ext[2,],type = "l")                                                ## Plot2
write.csv(ext,"C:/Users/USER/Desktop/MSC/DATOS/LLUVIA/PISCO V2.1/datoslluvia.csv")  ## Guardar como *.csv

########################################################################## Caso Coordenadas (Igual hasta la l?nea 8)
xy = cbind(-72.93199135377485,  -13.881556230479553)                                      ## Introducir coordenadas
ext = extract(nc, xy)                                                   ## Extraer s?lo un punto   (nc o tif)   

#-------------------------------------------------------------------------------------------------------------------#
write.csv(ext,"C:/Users/USER/Desktop/DATOS/LLUVIA/PISCO V2.0/estacionX.csv")   ## Cambia la direcci?n para guardar

##########################################################################
##########################################################################

# Si lo que quiere es sacar una media o sumatoria de un pol?gono

list<-list.files("D:/RUSLE_SED/Datos/RUSLE/RUSLE/","\\.tif$")          ## Lista de archivos *.tif o *.nc
Area2 = shapefile("D:/RUSLE_SED/Datos/Area_est2.shp")                  ## ?rea como pol?gono

mapply(function(i){
  mk = mask(crop(raster(list[i]),Area2),Area2)                         ## corta la imagen o el paquete de im?genes (como un clip)
  a = sum(getValues(mk),na.rm=T)                                       ## cambia sum por mean o la funci?n que requiera
  print(i)
  return(a)},1:length(list))
