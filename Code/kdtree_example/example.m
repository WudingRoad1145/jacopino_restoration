% find the nearest neighbor of a random matrix
run vlfeat-0.9.21/toolbox/vl_setup
m = 10; n = 1000;
data=rand(m,n);
numNb = 10;
maxCompare = 2^10;
[idx,dist]=knn(data,numNb,maxCompare);