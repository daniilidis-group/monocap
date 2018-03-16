function [X,normX] = prox_2norm(Z,lam)

[U,W,V] = svd(Z,'econ');
w = diag(W);
w = prox_inf(w,lam);
X = U*diag(w)*V';
normX = w(1);

end