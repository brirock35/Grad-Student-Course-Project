# import CSV data from GBIF into R
read.delim("~/Desktop/Brianna R (SPD)/seagrasssoccurances.csv")


#rename file
seagrass.occ <- read.delim("~/Desktop/Brianna R (SPD)/seagrasssoccurances.csv")


#read file/inspect elements
View(seagrass.occ)

# take only columns with species names and coordinates (latitude/longitude)
species.coord <- seagrass.occ[,22:23]
species <- seagrass.occ[,10]


# set variables with column data into a data frame
coordinate.table <- data.frame(species, species.coord)
View(coordinate.table)

#sort by species
library(plyr)
sorted.coord.table <-arrange(coordinate.table, species)
View(sorted.coord.table)
