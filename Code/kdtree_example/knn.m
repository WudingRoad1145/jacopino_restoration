function [idx,dist]=knn(data,numNb,maxCompare)
% KNN find the k nearest neighbor of the input data matrix
% data is the input data matrix
% size(data) = [m,n], where m is the data dimension
% n is the number of data (i.e. number of patches)
% numNb is the number of nearest neighbor you want to find
% maxCompare is the max number of comparison, 2^10 should be ok
% idx is the output matrix storing the index of the nearest neighbors
% size(idx) = [numNb, n]
% dist stores distance between nearest neighbors
% size(dist) = [numNb,n]

kdtree = vl_kdtreebuild(data);
[idx, dist] = vl_kdtreequery(kdtree, data, data, 'NumNeighbors', numNb,...
    'MaxComparisons', maxCompare);