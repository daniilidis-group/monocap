function dist = computeError3D(S1,S2)

dist = zeros(size(S1,1)/3,size(S1,2));
for i = 1:size(S1,1)/3
    dist(i,:) = sqrt(sum((S1(3*i-2:3*i,:)-S2(3*i-2:3*i,:)).^2,1));
end