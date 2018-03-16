function [S,info] = ssr2D3D_alm(W,B,lam,beta,varargin)

tol = 1e-3;
refine = false;
verb = true;
if nargin < 4
    beta = inf;
end

ivargin = 1;
while ivargin <= length(varargin)
    switch lower(varargin{ivargin})
        case 'tol'
            ivargin = ivargin + 1;
            tol = varargin{ivargin};
        case 'refine'
            ivargin = ivargin + 1;
            refine = varargin{ivargin};
        case 'verb'
            ivargin = ivargin + 1;
            verb = varargin{ivargin};
        otherwise
            fprintf('Unknown option ''%s'' is ignored !\n',varargin{ivargin});
    end
    ivargin = ivargin + 1;
end

% centralize basis
B = bsxfun(@minus,B,mean(B,2));

% data size
[k,p] = size(B);
k = k/3;

% initialization
M = zeros(2,3*k); 
C = zeros(1,k); % norm of each Xi
E = zeros(size(W));
T = mean(W,2);
% auxiliary variables for ADMM
Z = M;
Y = M;
mu = 1/mean(abs(W(:)));
% pre-computing
BBt = B*B';

% flagOD detection?
if beta > max(abs(W(:))) % too large
    flagOD = false;
else
    flagOD = true;
end

t0 = tic;

for iter = 1:1000
    
    % update motion matrix Z
    Z0 = Z;
    Z = ((W-E-T*ones(1,p))*B'+mu*M+Y)/(BBt+mu*eye(3*k));
    
    % update motion matrix M
    Q = Z - Y/mu;
    for i = 1:k
        [M(:,3*i-2:3*i),C(i)] = prox_2norm(Q(:,3*i-2:3*i),lam/mu);
    end
    
    if flagOD
        
        % update flagOD term
        E = W - Z*B - T*ones(1,p);
        E = sign(E).*max(abs(E)-beta,0);

        % update translation
        T = mean(W-Z*B-E,2);
        
    end
    
    % update dual variable
    Y = Y + mu*(M-Z);
    
    PrimRes = norm(M-Z,'fro')/norm(Z0,'fro');
    DualRes = mu*norm(Z-Z0,'fro')/norm(Z0,'fro');
    
    % show info
    if verb && mod(iter,10) == 0
        fprintf('Iter %d: PrimRes = %f, DualRes = %f, mu = %f\n',...
            iter,PrimRes,DualRes,mu);
    end
    
    % Convergent? 
    if  PrimRes < tol && DualRes < tol
        break
    else
        if PrimRes>10*DualRes
            mu = 2*mu;
        elseif DualRes>10*PrimRes
            mu = mu/2;
        else
        end
    end

end

info.time = toc(t0);

if refine
    [R,C] = syncRot(M);
    S = R*composeShape(B,C);
    [S,info1] = ssr2D3D_alt(W,B,lam,beta,'S0',R'*S,'R0',R,'E0',E,...
        'method','manopt','verb',verb);
    info.M = M;
    info.R = info1.R;
    info.C = info1.C;
    info.T = info1.T;
    info.E = info1.E;
    info.fval = info1.fval;
    info.timeAlt = info1.time;
else
    R = zeros(3,3*k);
    C(C<1e-6) = 0;
    for i = find(C>0)
        R(1:2,3*i-2:3*i) = M(:,3*i-2:3*i)/C(i);
        R(3,3*i-2:3*i) = cross(R(1,3*i-2:3*i),R(2,3*i-2:3*i));
    end
    S = R*kron(diag(C),eye(3))*B;
    info.M = M;
    info.R = R;
    info.C = C;
    info.T = T;
    info.E = E;
    info.fval = 0;
end

end

function [X,normX] = prox_2norm(Z,lam)
% X is a 3-by-2 matrix
[U,W,V] = svd(Z,'econ');
w = diag(W);
if sum(w) <= lam
    w = [0,0];
elseif w(1)-w(2) <= lam
    w(1) = (sum(w)-lam)/2;
    w(2) = w(1);
else
    w(1) = w(1) - lam;
    w(2) = w(2);
end
X = U*diag(w)*V';
normX = w(1);
end