function S = rotateS(S,R)

nFrame = size(S,1)/3;
T = mean(S,2);
S = bsxfun(@minus,S,T);

for i = 1:nFrame
    Ri = [R(2*i-1:2*i,:);cross(R(2*i-1,:),R(2*i,:))];
    S(3*i-2:3*i,:) = Ri * S(3*i-2:3*i,:);
end

S = bsxfun(@plus,S,T);
