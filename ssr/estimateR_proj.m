function R = estimateR_proj(S,W)

R = W/S;
[U,~,V] = svd(R,'econ');
R = U*V';

