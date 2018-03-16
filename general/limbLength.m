function L = limbLength(S,skel,A)

if nargin < 3
    A = skel2inc(skel);
end

L = zeros(size(S,1)/3,size(A,1));
for i = 1:size(S,1)/3
    L(i,:) = sqrt(sum((S(3*i-2:3*i,:)*A').^2,1));
end

end


function A = skel2inc(skel)
A = [];
for i = 1:length(skel.tree)
    for j = skel.tree(i).children
        a = zeros(1,length(skel.tree));
        a(i) = 1;
        a(j) = -1;
        A = [A;a];
    end
end
end