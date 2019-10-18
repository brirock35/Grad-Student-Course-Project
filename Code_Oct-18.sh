rm(list = ls())
library(data.table)
library(raster)
library(ggplot2)
library(bioregion)
library(rgdal)
library(maptools)
data("wrld_simpl")

d <- fread("/Users/darulab/Desktop/Brianna R (SPD)/SeagrassGBIF/seagrasssoccurances.csv", stringsAsFactors = FALSE)
s <- shapefile("/Users/darulab/Desktop/Brianna R (SPD)/Data/ShapeFiles/seagrasses_dissolved/seagrasses_dissolved.shp")


# merging seagrass occurrences with preexisting dissolved seagrass ranges
# developing grids on plot that possess seagrass spatial data
pdf("~/Desktop/temprange1.pdf")
plot(s)
plot(d1,add= TRUE)
dev.off()
#reset res to 1 
# d1 <- fishnet(s, res=2)
# d1$grids <- paste0("v", 1:nrow(d1))
writeOGR(d1, dsn = "/Users/darulab/Desktop/Brianna R (SPD)/Data/ShapeFiles/grids", layer = "grids_200km", driver = "ESRI Shapefile", overwrite_layer = TRUE)


df <- d[,c(23,22,36)]
names(df) <- c("lon", "lat", "basis")
df <- df[complete.cases(df),]
coordinates(df) <- ~lon+lat
proj4string(df) <- CRS("+proj=longlat +datum=WGS84")