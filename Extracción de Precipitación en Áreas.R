library(dplyr)
library(ncdf4)
library(raster)

##-------------------------------------------------------------------------
## PRIMERA PARTE
ppbrick = brick("E:/TESIS/datos/nc/PISCO_19812015.nc")                # cambiar netcdf
shp     = shapefile("E:/TESIS/datos/shp/tmp/microcuencasWS.shp")      # Shapefile con áreas a extraer
shpRp   = spTransform(shp, proj4string(ppbrick))

# Cortando el area de estudio
ppcrop  = crop(ppbrick, shpRp)
ppmask  = mask(ppcrop, shpRp)
writeRaster(ppmask, "E:/2018/MAGALY/ppMask.tif", overwrite=T)

##-------------------------------------------------------------------------
##-------------------------------------------------------------------------
# Funciones para hallar estadisticas zonales
myZonal <- function (x, z, stat, digits = 0, na.rm = TRUE, ...) {
  library(data.table)
  fun <- match.fun(stat) 
  vals <- getValues(x) 
  zones <- round(getValues(z), digits = digits) 
  rDT <- data.table(vals, z=zones) 
  setkey(rDT, z) 
  rDT[, lapply(.SD, fun, na.rm = TRUE), by=z] 
} 
ZonalPipe<- function (zone.in, raster.in, shp.out=NULL, stat){
  require(raster)
  require(rgdal)
  require(plyr)
  
  r <- stack(raster.in)
  shp <- readOGR(zone.in)
  shp <- spTransform(shp, crs(r))
  
  shp@data$ID<-c(1:length(shp@data[,1]))
  
  r <- crop(r, extent(shp))	
  zone <- rasterize(shp, r, field="ID", dataType = "INT1U") # Cambiar dataType si nrow(shp) > 255 a INT2U o INT4U
  
  Zstat<-data.frame(myZonal(r, zone, stat))
  colnames(Zstat)<-c("ID", paste0(names(r), "_", c(1:(length(Zstat)-1)), "_",stat))
  
  shp@data <- plyr::join(shp@data, Zstat, by="ID")
  
  if (is.null(shp.out)){
    return(shp)
  }else{
    writeOGR(shp, shp.out, layer= sub("^([^.]*).*", "\\1", basename(zone.in)), driver="ESRI Shapefile")
  }
}
##-------------------------------------------------------------------------
##-------------------------------------------------------------------------

# Hallar las estadísticas zonales
zone.in   = "E:/TESIS/datos/shp/tmp/microcuencasWS.shp"               # Volver a rutear
raster.in = "E:/2018/MAGALY/ppMask.tif"                               # En este tif está stackeado todas los años para el area de estudio
shp.out   = "E:/2018/MAGALY/ppZonal.shp"                              # Shapefile de salida

shp = ZonalPipe(zone.in, raster.in, stat="mean")                      # Funcion, con stat puedes cambiar

tbpp = write.csv(shp@data, header = T, sep = ",")  # Ruta de salida del csv
