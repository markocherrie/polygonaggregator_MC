I have used datazones from Aberdeen: https://saspac.org/data/2011-census/scotland-2011/

I have used population data from: https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/special-area-population-estimates/small-area-population-estimates/mid-2013/detailed-data-zone-tables

Aggregate smaller polygons to bigger area based on desired attribute value.

Briefly, I've taken the centroid of each datazone, added the attribute data, then clusteted using k-means. An error value has been generated based on the difference between the summed attribute of your new clustered areas and the desired value (I’ve done the mean absolute error- not sure that’s the right one?!). 

This procedure has been batched for 2 to 100 clusters. The cluster number with the lowest MAE has been plotted.

To do: Then dissolve polygons based on cluster number 
