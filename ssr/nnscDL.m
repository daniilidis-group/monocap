function [D,X] = nnscDL(Y,K,lam)

% This function implements dictionary learning with nonnegative sparse
% coding: 
% min_{D,X} 1/2||Y-DX||^2 + lam ||X||_1, X > 0

% INPUT:
% Y: training data (each column vector is a sample)
% K: dictionary size
% lam: regularization parameter

% OUTPUT:
% D: dictionary
% X: sparse codes for training data

N = size(Y,2);

% Initializing D by uniformly sampling
% Other initialization scheme could be used
D = Y(:,round(linspace(1,N,K)));
nrm0 = mean(sqrt(sum(D.^2)));

% Initializing X
X = pinv(D)*Y;
X(X(:)<0) = 0;
Xp = X;


for iter = 1:10000
    
    % Update X by proximal gradient
    mu = norm(D'*D);
    for i = 1:500
        dX = D'*(Y-D*X);
        X = X + 1/mu*(dX-lam);
        X(X(:)<0) = 0;
        if norm(X-Xp,'fro')/norm(Xp,'fro') < 1e-3
            break
        end
        Xp = X;
    end
    
    % Update D
    D = D + 1/norm(X*X')*(Y-D*X)*X';
%     D = Y*pinv(X);
    for i = 1:size(D,2)
        nrm = sqrt(sum(D(:,i).^2));
        if nrm > nrm0
            D(:,i) = D(:,i)*nrm0/nrm;
        end
    end
    
    % Calculate and print objective
    obj(iter) = (0.5*sum(sum((Y-D*X).^2)) + lam*sum(sum(X)));
    fprintf('Iter %d, obj %.3f\n', iter, obj(end));
    if iter > 1 && (obj(end-1)-obj(end))/obj(end-1) < 1e-6
        break
    end
    
end


