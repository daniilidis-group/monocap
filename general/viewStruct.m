function viewStruct(S1,S2,align,vp)

if nargin < 2
    S2 = [];
end

if nargin < 3
   align = true;
end

if nargin < 4
    vp = [0,0];
end

F = size(S1,1)/3;

if ~isempty(S2)
    S1 = bsxfun(@minus,S1,mean(S1,2));
    S2 = bsxfun(@minus,S2,mean(S2,2));
    if align
        for i = 1:F
            Y = findRotation(S1(3*i-2:3*i,:),S2(3*i-2:3*i,:));  % Procrust Alignment
            S2(3*i-2:3*i,:) = Y*S2(3*i-2:3*i,:);
            w = trace(S1(3*i-2:3*i,:)'*S2(3*i-2:3*i,:))/trace(S2(3*i-2:3*i,:)'*S2(3*i-2:3*i,:));
            S2(3*i-2:3*i,:) = w*S2(3*i-2:3*i,:);
        end
    end
end

h = figure;
for i = 1:F
    figure(h);
    title(sprintf('Frame %d',i));
    plot3(S1(3*i-2, :), S1(3*i, :), S1(3*i-1, :), 'bo');
    hold on
    if ~isempty(S2)
        plot3(S2(3*i-2, :), S2(3*i, :), S2(3*i-1, :), 'r.');
    end
    hold off
    axis vis3d equal
    view(vp(1),vp(2));
    title(i);
    grid on
    pause;
end;

end


function R = findRotation(S1,S2)

[F,P] = size(S1);
F = F/3;

S1 = reshape(S1,3,F*P);
S2 = reshape(S2,3,F*P);

R = S1*S2';
[U,~,V] = svd(R);
R = U*V';

end