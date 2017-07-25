########################################## LOAD DATA ######################################################

library(rgdal)
setwd("data")
shape<-readOGR(".", "DZ_2011_EoR_Aberdeen_City")

################################## POLYGON AGGREGATOR FUNCTION ############################################

polygonaggregator<-function(clusternumber, desiredpopulation){
library(plyr)
library(dplyr)
library(rgeos)

### Create centroids
shape2<-as.data.frame(shape)
trueCentroids = gCentroid(shape,byid=TRUE)
trueCentroids<-as.data.frame(trueCentroids)
trueCentroids$Data.Zone<-shape2$GSS_CODEDZ

### add the population data
population<-read.csv("2013-sape-t1ap.csv")
population$population<-sub(",", "", population$population)
population$population<-as.numeric(population$population)
trueCentroids<-merge(trueCentroids, population, by="Data.Zone")
trueCentroids2 <- trueCentroids[,-1]
rownames(trueCentroids2) <- trueCentroids[,1]

# Partition data into 'clusternumber' number of clusters
km <- kmeans(trueCentroids2, centers = clusternumber)
plot(trueCentroids2$x, trueCentroids2$y, col = km$cluster, pch = 20)
trueCentroids2$cluster<-km$cluster

# Create descriptive statistics for each cluster
output<-trueCentroids2 %>%
  group_by(cluster) %>%
  summarise(sum=sum(population), sd=sd(population))

# Create Mean Absolute Error (MAE) statistic to measure accuracy based on how well 
# cluster attribute value compares to desired attribute value
output$error<-desiredpopulation-output$sum
dataoutput<-cbind(mean(output$sum), max(output$cluster), mean(abs(output$error)) )
colnames(dataoutput)<-c("meansummedpopulation", "clusternumber", "mae")
return(dataoutput)
}

########################################## TEST #################################################

polygonaggregator(2, 12000)
polygonaggregator(10, 12000)


########################################## BATCH ################################################

# through a sequence through lots of combinations of parameters 
clusternumber<-seq(2, 100)
datainput<-as.data.frame(clusternumber)
datainput$desiredpopulation<-12000
finaloutput<-mdply(datainput,polygonaggregator)

######################################### OUTPUT RESULT #########################################

# Find clusternumber with lowest MAE, then run the k-means with this cluster number
# Then append to the original shapefile and create plot of the clusters

shape2<-as.data.frame(shape)
trueCentroids = gCentroid(shape,byid=TRUE)
trueCentroids<-as.data.frame(trueCentroids)
trueCentroids$Data.Zone<-shape2$GSS_CODEDZ
population<-read.csv("2013-sape-t1ap.csv")
population$population<-sub(",", "", population$population)
population$population<-as.numeric(population$population)
trueCentroids<-merge(trueCentroids, population, by="Data.Zone")
trueCentroids2 <- trueCentroids[,-1]
rownames(trueCentroids2) <- trueCentroids[,1]

# Partition data into 'clusternumber' number of clusters
km <- kmeans(trueCentroids2, centers = finaloutput$clusternumber[finaloutput$mae %in% min(finaloutput$mae)==T])
trueCentroids2$cluster<-km$cluster
output<-trueCentroids2 %>%
  group_by(cluster) %>%
  summarise(sum=sum(population), sd=sd(population))

#### plot final polygons
shape$clusternumber<-km$cluster
plot(shape, col=km$cluster)
