function [S,info] = ssr2D3D_alt(W,B,lam,beta,varargin)

if nargin < 4
    beta = inf;
end

% centralize data
B = bsxfun(@minus,B,mean(B,2));

% data size
k = size(B,1)/3;
p = size(B,2);

% initialize
C = zeros(1,k);
S = meanShape(B);
R = eye(3);
E = zeros(size(W));
T = mean(W,2);
tol = 1e-4;
method = 'manopt';
verb = true;

ivargin = 1;
while ivargin <= length(varargin)
    switch lower(varargin{ivargin})
        case 'tol'
            ivargin = ivargin + 1;
            tol = varargin{ivargin};
        case 's0'
            ivargin = ivargin + 1;
            S = varargin{ivargin};
        case 'r0'
            ivargin = ivargin + 1;
            R = varargin{ivargin};
        case 'e0'
            ivargin = ivargin + 1;
            E = varargin{ivargin};
        case 'method'
            ivargin = ivargin + 1;
            method = varargin{ivargin};
        case 'verb'
            ivargin = ivargin + 1;
            verb = varargin{ivargin};
        otherwise
            fprintf('Unknown option ''%s'' is ignored !\n',varargin{ivargin});
    end
    ivargin = ivargin + 1;
end

% outlier detection?
if beta > max(abs(W(:))) % too large
    flagOD = false;
else
    flagOD = true;
end

R = R(1:2,:);

fval = inf;
t0 = tic;
for iter = 1:1000
    
    % update rotation
    W2fit = W - E - T*ones(1,p);
    switch method
        case 'proj' % greedy projection
            R = estimateR_proj(S,W2fit);
        case 'manopt' % manifold optimizaiton
            R = estimateR_manopt(S,W2fit,R);
        otherwise
            error('Invalid input for option:method!');
    end
    
    % update shape
    C = estimateC(W2fit,R,B,C,lam,1e-4);
    S = kron(C,eye(3))*B;
    
    if flagOD
        
        % update outlier
        E = W - R*S - T*ones(1,p);
        E = sign(E).*max(abs(E)-beta,0);
        
        % update translation
        T = mean(W-R*S-E,2);
        
        % evaluate obj. func.
        fvaltm1 = fval;
        fval = 0.5*norm(W-R*S-E-T*ones(1,p),'fro')^2 + lam*sum(abs(C(:))) + beta*sum(abs(E(:)));
        
    else
        
        fvaltm1 = fval;
        fval = 0.5*norm(W-R*S-E-T*ones(1,p),'fro')^2 + lam*sum(abs(C(:)));
        
    end
    
    % show info
    if verb 
        fprintf('Iter: %d, fval = %f\n',iter,fval);
    end
    
    % check convergence
    if abs(fval-fvaltm1)/fvaltm1 < tol
        break
    end
    
end

R(3,:) = cross(R(1,:),R(2,:));

% output
S = R*S;
info.R = R;
info.C = C;
info.T = T;
info.E = E;
info.fval = fval;
info.time = toc(t0);
