# polygonaggregator_MC

Aggregate smaller polygons to bigger area based on desired attribute value.

Briefly, take the centroid of each datazone, add the attribute data, then do a k-means clustering. 

Generate an error based on the difference between the summed attribute of your new clustered areas and your desired value (I’ve done the mean absolute error- not sure that’s the right one?!). 

Batch this for different number of clusters and choose the one with the lowest MAE.

Output the result

To do: Then dissolve polygons based on cluster number 
