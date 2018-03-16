function W = proj22D(S,cam)

if isstruct(cam)
    % perspective
    for i = 1:size(S,1)/3
        Y = cam.K * bsxfun(@plus, cam.R * S(3*i-2:3*i,:), cam.T);
        W(2*i-1:2*i,:) = bsxfun(@rdivide,Y(1:2,:),Y(3,:));
    end
    
else
    % weak perspective
    for i = 1:size(S,1)/3
        W(2*i-1:2*i,:) = cam * [S(3*i-2:3*i,:);ones(1,size(S,2))];
    end
    
end
    