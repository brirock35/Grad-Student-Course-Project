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
d1 <- fishnet(s, res=2)
d1$grids <- paste0("v", 1:nrow(d1))
writeOGR(d1, dsn = "/Users/darulab/Desktop/Brianna R (SPD)/Data/ShapeFiles/grids", layer = "grids_200km", driver = "ESRI Shapefile", overwrite_layer = TRUE)


df <- d[,c(23,22,36)]
names(df) <- c("lon", "lat", "basis")
df <- df[complete.cases(df),]
coordinates(df) <- ~lon+lat
proj4string(df) <- CRS("+proj=longlat +datum=WGS84")

## 2.generating species richness
ss <- readOGR(dsn = "/Users/darulab/Desktop/Brianna R (SPD)/Data/ShapeFiles/Seagrasses_SHP_raw", layer = "SEAGRASSES")
proj4string(ss) <- CRS("+proj=longlat +datum=WGS84")

S <- as.character(unique(ss$binomial))

# for loop to count number of seagrasses per grid cell by species (72 species total)
out <- NULL
for (i in 1:length(S)) {
  x1 <- subset(ss, ss$binomial %in% S[i])
  proj4string(x1) <- proj4string(s1)
  x2 <- over(s1, x1)
  x3 <- cbind(data.frame(s1), x2)
  M <- as.data.frame.matrix(table(x3$grids, x3$binomial))
  M[M>0] <- 1
  M1 <- picante::matrix2sample(M)
  w <- M1[,c(1,3)]
  names(w) <- c("grids", "species")
  out <- rbind(out, w)
  print(i)
}

r <- data.frame(out)
