clear
clc

cd '/Users/yan/Desktop/CS/Jacopino/code'

%addpath('.\pic_inpaint')
addpath('kdtree_example')
run ./kdtree_example/vlfeat-0.9.21/toolbox/vl_setup
%% load the images into matlab matrices
ground_truth = imread('Jacopino_E-2-1.png');
% read the image's alpha channel to get the transparency matrix
% 0 means transparent, 255 means not
[img, ~, alpha] = imread('Jacopino_E-2-1.png'); 
% whos alpha
crack = imread('Jacopino_E-2-1_crackmap_1.png');
%if crack is already 3d
%crack = crack(:,:,3);
[m,n] = size(crack);        % size of crackmap
%% only used to develop code
% crop images
%ground_truth = ground_truth(1:1340,1:1856,:);
%ground_truth = ground_truth(1:237,1:361,:);
%crack = crack(1:1340,1:1856);
%crack = crack(1:237,1:361);

SE = strel('square',3);
crack2 = ~imdilate(~crack, SE);
crack = crack2.*255;
%% change matrices to double or logical
ground_truth = im2double(ground_truth);
%select the crack region, deselect the background
%if the background is white, select crack<255
crack = crack < 255; % this crack matrix is nonzero at unknown region
crack_3d = repmat(crack,[1 1 3]);
raw = ground_truth.*~crack_3d;  % raw is the "true" input image
f = raw; % a copy of the true input for processing
%% only used to develop code
%  filling the crack region with random value
%  use gaussian noise with the mean and std determined in the known pixel
%for band = 1:3
%    temp = f(:,:,band); 
%    temp(crack & image_mask) = mean(temp(image_mask & (~crack)))+...
%        std(temp(image_mask & (~crack)))*randn(numel(temp(crack& image_mask)),1);
%    f(:,:,band) = temp;
%end
%% visual display of image, image with crackmap
figure(1); imshow(ground_truth); title('ground truth')
figure(2); imshow(raw); title('raw input')
figure(3); imshow(f); title('raw input plus random pixel inpainting')
%% extract patches
% patch size: use odd number
% this is one of the inputs that can be changed
% theoritically would produce more precise inpainting with more patches,
% but in practice the modification does not seem to make a huge difference

% Runtime increases as the patch size increases
ps = 9;                
                              
% the next line output the coloction of patches and a logical matrix
% indicating whether an entry in "patches" is crack or not
[patches, cracks] = extract_patches(f,crack_3d,ps);
newPatch = zeros(size(patches));
scale = 1;
patch_with_coor = zeros(size(patches,1)+2,size(patches,2));
patch_with_coor(end - 1,:) = repmat(1:m,1,n)*scale;
patch_with_coor(end,:) = reshape(repmat(1:n,m,1),1,[])*scale;


%fprintf('Patch size is %d.\n',ps);
%fprintf('Scale is %d.\n',scale);

%% compute distance and find neaerest neighbors 
 %number of nearest neighbors
 %this is one of the inputs can be changed
 %increase when cracks are thicker 
 %Runtime increases as numNb increases 
numNb = 200; 

%increase numNb to 150 or 200
%maxCompare usually does not need to be changed 
maxCompare = 2^10;
tic

%use knn (kd-tree function to find k (numNb) nearest neighbors
[idx,dist]=knn(patch_with_coor,numNb,maxCompare);
toc
numPatch = size(idx,2);

%% Calculate weighted average
dist(1,:) = []; % throwing away the nearest patch (itself)
idx(1,:) = [];
for ii = 1:numPatch
    if nnz(cracks(:,ii))==0 % number of non-zero
        newPatch(:,ii)= patches(:,ii);
    else
        newPatch(:,ii)= patches(:,ii);
        batch = patches(:,idx(:,ii));
        batch = batch(cracks(:,ii),:);
        weights = 1./(dist(:,ii)+1e-8).^2; % use 1/dist^2 as weights to take the mean of patches
        crack_batch = cracks(:,idx(:,ii)); 
        crack_batch = crack_batch(cracks(:,ii),:); % crack location of the batch
        total_weight = ~crack_batch*weights;
        batch(crack_batch) = 0;
        weighted_sum = batch*weights;
        newPatch(cracks(:,ii),ii) = weighted_sum./total_weight;                
    end
end

%% transform patch back into image
tic
recover = patch2image(newPatch,ps,m,n);
figure;imshow(recover);title('recover')
toc
imwrite(recover, 'inpainted_patch_3_new.png')



