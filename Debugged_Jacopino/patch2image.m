function img = patch2image(patches,ps,m,n);
% transform patches back into imgage
% m,n is the original image size

img = zeros(m+ps-1,n+ps-1,3);
weights = zeros(m+ps-1,n+ps-1,3);
count = 0;
for jj=1:n
    for ii=1:m
        count = count+1;
        img(ii:ii+ps-1,jj:jj+ps-1,:) = img(ii:ii+ps-1,jj:jj+ps-1,:)...
            +reshape(patches(:,count),ps,ps,3);
        weights(ii:ii+ps-1,jj:jj+ps-1,:)=weights(ii:ii+ps-1,jj:jj+ps-1,:)+1;
    end
end
img = img./weights;
img = img((ps+1)/2:m+(ps-1)/2,(ps+1)/2:n+(ps-1)/2,:);
        