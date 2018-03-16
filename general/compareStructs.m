function [dist,S2] = compareStructs(S1,S2,rot)

if nargin < 3
    rot = 0;
end

% compare two structures and align S2 to S1 with similarity transformation

T1 = mean(S1,2);
S1 = bsxfun(@minus,S1,T1);
S2 = bsxfun(@minus,S2,mean(S2,2));

[f,p] = size(S1);
f = f/3;
dist = zeros(f,p);

if rot == 0
    Y = eye(3);
else
    Y = findRotation(S1,S2);
end

for i = 1:f
    A = S1(3*i-2:3*i,:);
    B = S2(3*i-2:3*i,:);
    if rot == 1
        Y = findRotation(A,B);
    end
    % rotate B
    B = Y*B;
    % scale B
    w = trace(A'*B)/(trace(B'*B)+eps);
    B = w*B;
    % output
    dist(i,:) = sqrt(sum((A-B).^2,1)); % average distance
    S2(3*i-2:3*i,:) = B;
end

S2 = bsxfun(@plus,S2,T1);

end

function R = findRotation(S1,S2)
[F,P] = size(S1);
F = F/3;
S1 = reshape(S1,3,F*P);
S2 = reshape(S2,3,F*P);
R = S1*S2';
[U,~,V] = svd(R);
R = U*V';
% R = U*diag([1 1 det(R)])*V';
end
