function [S,info] = ssr2D3D_wrapper(W,B,method,varargin)

lam = 1;
beta = 1;
verb = false;

ivargin = 1;
while ivargin <= length(varargin)
    switch lower(varargin{ivargin})
        case 'lam'
            ivargin = ivargin + 1;
            lam = varargin{ivargin};
        case 'beta'
            ivargin = ivargin + 1;
            beta = varargin{ivargin};
        case 'verb'
            ivargin = ivargin + 1;
            verb = varargin{ivargin};
        otherwise
            fprintf('Unknown option ''%s'' is ignored !\n',varargin{ivargin});
    end
    ivargin = ivargin + 1;
end

% run solvers
switch lower(method)
    case 'convex'
        [S,info] = ssr2D3D_alm(W,B,lam,inf,'verb',verb);
    case 'convex+refine'
        [S,info] = ssr2D3D_alm(W,B,lam,inf,'refine',true,'verb',verb);
    case 'convex+robust'
        [S,info] = ssr2D3D_alm(W,B,lam,beta,'verb',verb);
    case 'convex+robust+refine'
        [S,info] = ssr2D3D_alm(W,B,lam,beta,'refine',true,'verb',verb);
    case 'altern'
        [S,info] = ssr2D3D_alt(W,B,lam,inf,'method','proj','verb',verb);
    case 'altern+robust'
        [S,info] = ssr2D3D_alt(W,B,lam,beta,'method','proj','verb',verb);
    otherwise
        error('Undefined method!');
end





