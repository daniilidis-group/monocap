function [C,info] = estimateC_fused(W,R,B,C,alpha,beta,tol)

% assume W and B have been centralized!!!

% INPUT:
% W: 2F-by-P matrix
% R: 2F-by-3 matrix
% B: 3K-by-P matrx
% C: F-by-K vector

P = size(W,2);
F = size(W,1)/2;
K = size(B,1)/3;

% reshape R
Rdiag = zeros(2*F,3*F);
for i = 1:F
    Rdiag(2*i-1:2*i,3*i-2:3*i) = R(2*i-1:2*i,:);
end

C0 = C; % C0: the previous estimate
t = 1; % auxiliary variable for nesterov
t0 = 1; % auxiliary variable for nesterov
fval = inf;

% next we work on the linear system yi = X(Ri)*Ci
% compute gradient for each Ci
ytX = zeros(F,K);
XtX = zeros(K,K,F);
for i = 1:F
    y = W(2*i-1:2*i,:);
    y = y(:);
    X = zeros(2*P,K); % each column is a rotated Bk
    for k = 1:K
        RBk = R(2*i-1:2*i,:)*B(3*k-2:3*k,:);
        X(:,k) = RBk(:);
    end
    ytX(i,:) = y'*X;
    XtX(:,:,i) = X'*X;
end
% for fused term
A = zeros(F-1,F);
A(1:F:end) = 1;
A(F:F:end) = -1;
AtA = A'*A;

% mu should be larger than the 2-norm of the Hessian of f(C)
mu = (norm(XtX(:,:,1))+beta*norm(AtA))*2;

for iter = 1:500
    
    % Z is an auxiliary variable in nesterov method
    Z = C + (t0-1)/t*(C-C0);
    
    % gradient descent
    G = zeros(F,K);
    for i = 1:F
        G(i,:) = - ytX(i,:) + Z(i,:)*XtX(:,:,i);
    end
    G = G + beta*AtA*Z;
    Z = Z - G/mu;
    
    % nonegative thresholding
    %     Z = Z - alpha/mu;
    %     Z = max(Z,0);
    
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
    S = composeShape(B,C);
    loss = 1/2 * norm(W-Rdiag*S,'fro')^2;
    penalty = alpha * sum(abs(C(:))) ...
        + beta/2 * norm(C(1:end-1,:)-C(2:end,:),'fro')^2;
    fval = loss + penalty;
    if fval > fval_pre
        t0 = 1; % APG with restart
        t = 1;
    end
    % fprintf('Iter %d: FunVal = %f, RelChg = %f\n',iter,fval,RelChg);
    
    % check convergence
    RelChg = norm(C-C0,'fro')/(norm(C0,'fro')+eps);
    if RelChg < tol
        break
    end
    
end

info.fval = fval;
info.loss = loss;
info.penalty = penalty;

end

function S = composeShape(B,C)

f = size(C,1);
p = size(B,2);
k = size(B,1)/3;

B = reshape(B',3*p,k);
S = B*C';
S = reshape(S,p,3*f)';

end