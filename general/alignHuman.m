function S = alignHuman(S,torso)

F = size(S,1)/3;
S = bsxfun(@minus,S,mean(S,2));

St = S(:,torso);
for i = 2:F
    % Procrust Alignment of Torso
    Y = findRotation(St(1:3,:),St(3*i-2:3*i,:)); 
    S(3*i-2:3*i,:) = Y*S(3*i-2:3*i,:);
end
