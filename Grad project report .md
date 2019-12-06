# Introduction 

This project involves downloading  data from the Global Biodiversity Information Facility (GBIF) and adapting it into R code in order to assess species diversity of seagrasses. The end goal is to produce a geographic plot with 100km grid cells measuring the number of different species present per cell. Because occurances included both observation and specimen data, there are some errors to account for in the raw csv file. GBIF compiles data from many different sources, some including citizen science projects. Therefore such data is subject to human error. In order to correct for this issue, we had to find a way to filter out the spatial points that fell out of the range of normal seagrass distributions (eg. points falling on land or in the middle of the ocean). Because these points were most likely incorrectly documented, they would not be considered significant. To omit such spatial points from the plot, we needed to apply a shapefile layer to the data consisting of dissolved ranges where seagrasses are found. This layer would essentially limit the seagrass occurance data to only points falling within these known ranges. 

# Breaking Down the Code

The first step to completing this project is to upload all needed libaries and data files into the R script.

```
library(data.table)
library(raster)
library(ggplot2)
library(bioregion)
library(rgdal)
library(maptools)
library(phytools)
library(sp)
data("wrld_simpl")

# variable d represents the seagrass occurrances from GBIF and variable s is the shapefile of dissolved seagrass ranges
d <- fread("/Users/darulab/Desktop/Brianna R (SPD)/SeagrassGBIF/seagrasssoccurances.csv", stringsAsFactors = FALSE)
s <- shapefile("/Users/darulab/Desktop/Brianna R (SPD)/Data/ShapeFiles/seagrasses_dissolved/seagrasses_dissolved.shp")
pdf("~/Desktop/temprange1.pdf")

```

The next step is to incorporate 100 km grids to the data file and apply the plotting function. The fishnet function creates a regular grid of locations covering the selected study area. 

```
d1 <- fishnet(s, res=2)
d1$grids <- paste0("v", 1:nrow(d1))
plot(s)
plot(d1,add= TRUE)
dev.off()

# the below code will write spatial vector data and will allow the data to be written out using supported drivers 
# whether drivers are supported is based off of the local installation and the capabilities of the drivers

writeOGR(d1, dsn = "/Users/darulab/Desktop/Brianna R (SPD)/Data/ShapeFiles/grids", layer = "grids_100km", driver = "ESRI Shapefile", overwrite_layer = TRUE)
 
```

Next, we need to extract the columns in the data file that have the needed rows of infomation (i.e. longitude, latitude, and basis of record), and utilize specific functions to retrieve the desired data (i.e. coordinates(df) and proj4string(df)) and reorganize the data.

```
df <- d[,c(23,22,36)]
names(df) <- c("lon", "lat", "basis")

# the below code omits any NA's present
df <- df[complete.cases(df),]

coordinates(df) <- ~lon+lat
proj4string(df) <- CRS("+proj=longlat +datum=WGS84")

```

Now we assign a new variable for reading in the shapefile of dissolved seagrass ranges while incorporating a layer of seagrass occurrances.  Then, we create a for loop that reads through all 72 seagrass species occurrances and counts the  number of species per grid cell.

```
# reads OGR data source and layers it into a suitable spatial vector object (in this case "SEAGRASSES")
ss <- readOGR(dsn = "/Users/darulab/Desktop/Brianna R (SPD)/Data/ShapeFiles/Seagrasses_SHP_raw", layer = "SEAGRASSES")

# sets or retrieves projection attributes and permits spatial data to be associated with coordinate reference systems 
proj4string(ss) <- CRS("+proj=longlat +datum=WGS84")

S <- as.character(unique(ss$binomial))

# for loop to count number of species per grid
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
write.csv(r, "/Users/darulab/Desktop/Brianna R (SPD)/Data/CSVs/PRESAB_100km.csv", row.names = FALSE)

```
Finally, the last step is to plot the data we've manipulated in geographic space.

```
# create data frame and vector to combine grids with species richness
mm <- data.frame(table(r$grids))
names(mm) <- c("grids", "SR")

index1 <- match(s1$grids, mm$grids)
zm <- cbind(s1, mm$SR[index1])
names(zm)[3] <- "SR"
zm1 <- zm[zm@data$SR>0, ]

# the below code selects for the desired color palette and creates a vector of a group of contiguous colors
k=10
COLOUR <- hcl.colors(k, palette = "Zissou 1")

# the choropleth function discretizes the values of the quantity based on their quantities
y = choropleth(zm1, values=zm1$SR, k)

# the below code plots the basic geographic map that the seagrass data will be placed on
plot(wrld_simpl, col="white", border="grey")
plot(y, layer="SR", col=COLOUR[y$values], border = NA, add=T)

# this code adds a color bar to help with interpretation of the species richness plot
add.color.bar( leg=100,cols = COLOUR, lims=c(1,22), digits=1, prompt=TRUE,title = NA,
              lwd=4, outline=TRUE)
```

# Final Product
Seagrass global species richness plot:
![seagrass SR](https://raw.githubusercontent.com/brirock35/Rock-Grad-Project/master/species%20richness.png)

