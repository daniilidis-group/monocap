function output = perspAdj(output,alpha)

if nargin < 2
    alpha = 0.01;
end

B = output.dict.B;
rootID = output.rootID;
nF = size(output.S_final,1)/3;
nP = size(output.S_final,2);

for i = 1:nF
    C = output.C_final(i,:);
    W = output.W_final(2*i-1:2*i,:);
    bbox = output.bbox(i,:);
    W = W*(bbox(3)-bbox(1))/output.size_heatmap(2);
    W = bsxfun(@plus,W,bbox(1:2)');
    W = output.camera.K \ [W;ones(1,nP)]; % normalized coordinate
    R = output.R_final(2*i-1:2*i,:);
    R(3,:) = cross(R(1,:),R(2,:));
    [~,~,~,St] = refine_perspective(W,B,C,R,rootID,alpha);
    S_refine{i,1} = St;
end

output.S_refine = cell2mat(S_refine);

end


function [C,R,T,St] = refine_perspective(W,B,C,R,rootID,alpha)

% \min \| K^(-1)*W - (R*S+T*ones(1,nP))./(ones(3,1)*Z) \|^2 

beta = 0;

% rescale shape
St = R*composeShape(B,C);
a = sqrt(sum(sum(bsxfun(@minus,St(1:2,:),mean(St(1:2,:),2)).^2)))/...
    sqrt(sum(sum(bsxfun(@minus,W,mean(W,2)).^2))+eps);
C = C/(a+eps);

% initialize
Z = ones(1,size(W,2));
S = composeShape(B,C);
T = mean(W*diag(Z),2) - mean(R*S,2);
St = bsxfun(@plus,R*S,T);

tol = 1e-4;
fval = inf;
for iter = 1:500
    fval_pre = fval;
    
    % update Z
    Z = sum(W.*St,1)./(sum(W.^2,1)+eps);
    Z(rootID) = 1;
    Sp = W*diag(Z);

    % update R and T 
    [~,~,transform] = procrustes(Sp',S','reflection',false,'scaling',false);
    T = transform.c(1,:)';
    R = transform.T';
    
    % update C
    [C,fval] = updateC_persp(R'*bsxfun(@minus,Sp,T),B,C,alpha,beta);
    S = composeShape(B,C);
    St = bsxfun(@plus,R*S,T);
    
    % convergent?
%     fprintf('Iter %d, fval = %f\n',iter,fval);
    if (fval_pre/(fval+eps)-1) < tol
        break
    end

end

end


function [C,fval] = updateC_persp(St,B,C,alpha,beta)

% next we work on the linear system Y = X*C
Y = reshapeS(St,'b2v');
X = reshapeS(B,'b2v');
C = C';

if alpha == 0
    C = pinv(X)*Y;
    fval = 1/2*norm(Y-X*C,'fro')^2;
else
    
    C0 = C; % C0: the previous estimate
    t = 1; % auxiliary variable for nesterov
    t0 = 1; % auxiliary variable for nesterov
    fval = inf;
    tol = 1e-4;

    nF = size(Y,2);
    XtY = X'*Y;
    XtX = X'*X;
    A = zeros(nF-1,nF);
    A(1:nF:end) = 1;
    A(nF:nF:end) = -1;
    AtA = A'*A;

    % mu should be larger than the 2-norm of the Hessian of f(C)
    mu = (norm(XtX)+beta*norm(AtA))*1.1;

    for iter = 1:500

        % Z is an auxiliary variable in nesterov method
        Z = C + (t0-1)/t*(C-C0);

        % gradient descent
        G = - XtY + XtX*Z + beta*Z*AtA;
        Z = Z - G/mu;

        % soft thresholding
        Z = sign(Z).*max(abs(Z)-alpha/mu,0);

        % update C
        C0 = C;
        C = Z;

        % update t
        t0 = t;
        t = (1+sqrt(1+4*t^2))/2;

        % function value
        fval_pre = fval;
        fval = 1/2*norm(Y-X*C,'fro')^2 + alpha*sum(abs(C)) + beta/2*norm(A*C','fro')^2;
        if fval > fval_pre
            t0 = 1; % APG with restart
            t = 1;
        end

        % check convergence
        RelChg = norm(C-C0,'fro')/(norm(C0,'fro')+eps);
    %     fprintf('Iter %d: FunVal = %f, RelChg = %f\n',iter,fval,RelChg);
        if RelChg < tol
            break
        end

    end

end

C = C';

end