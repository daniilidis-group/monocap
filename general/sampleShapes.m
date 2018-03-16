function SS = sampleShapes(S,ind,nd)

if nargin < 3
    nd = 3;
end

SS = [];
for j = ind
    SS = [SS;S((j-1)*nd+1:j*nd,:)];
end