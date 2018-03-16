function label = computeErrorPCK(W1,W2,th)

dist = zeros(size(W1,1)/2,size(W1,2));
for i = 1:size(W1,1)/2
    dist(i,:) = sqrt(sum((W1(2*i-1:2*i,:)-W2(2*i-1:2*i,:)).^2,1));
end

label = dist<th;
