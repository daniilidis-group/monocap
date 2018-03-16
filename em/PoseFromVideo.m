function output = PoseFromVideo(varargin)

heatmap = [];
W_gt = [];
S_gt = [];
dict = [];
alpha = 0.5;
beta = 20;
gamma = 2;
sigma = 0.5;
tol = 1e-4;
MaxIterEM = 10;
MaxIterAltern = 10;
InitialMethod = 'convex+robust+refine'; % choose 'altern' to speed up
FilterRotation = false;
filterSize = 5;
th_vis = 0;
verb = false;

ivargin = 1;
while ivargin <= length(varargin)
    switch lower(varargin{ivargin})
        case 'heatmap'
            ivargin = ivargin + 1;
            heatmap = varargin{ivargin};
        case 'w_gt'
            ivargin = ivargin + 1;
            W_gt = varargin{ivargin};
        case 'dict'
            ivargin = ivargin + 1;
            dict = varargin{ivargin};
        case 'alpha'
            ivargin = ivargin + 1;
            alpha = varargin{ivargin};
        case 'beta'
            ivargin = ivargin + 1;
            beta = varargin{ivargin};
        case 'gamma'
            ivargin = ivargin + 1;
            gamma = varargin{ivargin};
        case 'sigma'
            ivargin = ivargin + 1;
            sigma = varargin{ivargin};
        case 'th_vis'
            ivargin = ivargin + 1;
            th_vis = varargin{ivargin};
        case 'filtersize'
            ivargin = ivargin + 1;
            filterSize = varargin{ivargin};
        case 'tol'
            ivargin = ivargin + 1;
            tol = varargin{ivargin};
        case 'initialmethod'
            ivargin = ivargin + 1;
            InitialMethod = varargin{ivargin};
        case 'filterrotation'
            ivargin = ivargin + 1;
            FilterRotation = varargin{ivargin};
        case 'maxiterem'
            ivargin = ivargin + 1;
            MaxIterEM = varargin{ivargin};
        case 'maxiteraltern'
            ivargin = ivargin + 1;
            MaxIterAltern = varargin{ivargin};
        case 's_gt'
            ivargin = ivargin + 1;
            S_gt = varargin{ivargin};
        case 'init'
            ivargin = ivargin + 1;
            init = varargin{ivargin};
        case 'verb'
            ivargin = ivargin + 1;
            verb = varargin{ivargin};
        otherwise
            fprintf('Unknown option ''%s'' is ignored !!!\n',...
                varargin{ivargin});
    end
    ivargin = ivargin + 1;
end

if exist('init','var') && ~isempty(init)
    output = init;
else
    output = struct('S_init',[],...
        'R_init',[],...
        'C_init',[],...
        'T_init',[],...
        'S_final',[],...
        'R_final',[],...
        'C_final',[],...
        'T_final',[]);
end

if isempty(W_gt) && ~isempty(heatmap)
    EM = true;
    heatmap(heatmap<0) = 0;
    size_heatmap = size(heatmap);
    [X,Y] = meshgrid(1:size_heatmap(2),1:size_heatmap(1));
    xy = [X(:),Y(:)]';
    W_init = findWmax(heatmap);
    % normalize data scale for convenience of paramter setting
    size_metric = 6;
    scale = size_heatmap(1)/size_metric;
    xy = xy / scale;
    W_init = W_init / scale;
elseif ~isempty(W_gt)
    EM = false;
    W_init = W_gt;
    % normalize data scale for convenience of paramter setting
    scale = mean(std(W_gt,1,2));
    size_heatmap = [64 64];
    size_metric = size_heatmap(1)/scale;
    W_init = W_init / scale;
else
    fprintf('No input data!\n');
    return
end

nFrame = size(W_init,1)/2;
nJoint = size(W_init,2);
B = dict.B;

%% single frame initialization
if isempty(output.R_init)
    for i = 1:nFrame
        fprintf('Single frame initialization, frame %d\n',i);
        if EM % ignore very uncertain joints in initialization
            visible = squeeze(max(max(heatmap(:,:,:,i)))) > th_vis;
        else
            visible = true(nJoint,1);
        end
        [~,info] = ssr2D3D_wrapper(W_init(2*i-1:2*i,visible),B(:,visible),InitialMethod,'lam',alpha);
        S_init{i,1} = rotateS(composeShape(B,info.C),info.R);
        C_init{i,1} = info.C;
        R_init{i,1} = info.R(1:2,:);
        T_init{i,1} = info.T;
    end
    S_init = cell2mat(S_init);
    C_init = cell2mat(C_init);
    R_init = cell2mat(R_init);
    T_init = cell2mat(T_init);
else
    % read values from input
    S_init = output.S_init(1:3*nFrame,:);
    C_init = output.C_init(1:nFrame,:);
    R_init = output.R_init(1:2*nFrame,:);
    T_init = output.T_init(1:2*nFrame,:);
end

S = S_init;
C = C_init;
R = R_init;
T = T_init;
W = W_init;

if FilterRotation
    fprintf('Median filtering of rotations ... \n');
    R = medfiltRotations(R,filterSize);
end

if ~isempty(S_gt)
    e = mean(mean(compareStructs(S_gt,S,1)));
    fprintf('Initialization error = %.2f\n',e);
end

%%
fprintf('Optimization begins ... \n');
t_w = 0;
t_c = 0;
t_r = 0;

for outerIter = 1:MaxIterEM
    
    if EM
        % update W by computing mean
        t0 = tic;
        for i = 1:nFrame
            pts = bsxfun(@plus,S(3*i-2:3*i-1,:),T(2*i-1:2*i));
            for j = 1:nJoint
                sqDist = sum(bsxfun(@minus,xy,pts(:,j)).^2,1)';
                likelihood = exp(-sqDist/(2*sigma^2));
                pr = (likelihood+eps) .* ...
                    reshape(heatmap(:,:,j,i)+eps,size(likelihood));
                pr = pr / sum(pr);
                W(2*i-1:2*i,j) = xy*pr;
            end
        end
        t_w = t_w + toc(t0);
    end
    
    % update T
    T = mean(W,2);
    
    % update shape and rotation
    Wc = bsxfun(@minus,W,T);
    C_pre = C;
    fval_pre = inf;
    for innerIter = 1:MaxIterAltern
        t0 = tic;
        [C,info_C] = estimateC_fused(Wc,R,B,C,alpha,beta,1e-4);
        t_c = t_c + toc(t0);
        S = composeShape(B,C);
        t0 = tic;
        [R,fval] = estimateR_fused(S,Wc,gamma,R,1e-4);
        t_r = t_r + toc(t0);
        fval = fval + info_C.penalty;
        if verb
            fprintf('Inner iter %d, fval = %f, [t_c,t_r] = [%.2f,%.2f] \n',...
                innerIter,fval,t_c,t_r);
        end
        if fval_pre/fval-1 < 1e-4
            break
        else
            fval_pre = fval;
        end
    end
    
    % output S is in camera frame
    S = rotateS(S,R);
    if ~isempty(S_gt)
        e = compareStructs(S_gt,S,1);
        e = mean(e(:));
    else
        e = NaN;
    end
    
    % check convergence
    RelChg = norm(C_pre(:)-C(:))/norm(C_pre);
    fprintf('Outer iter %d, RelChg = %f, #InnerIter = %d, error = %f \n',...
        outerIter,RelChg,innerIter,e);
    if ~EM || RelChg < tol
        break
    end

end

W_proj = S;
W_proj(3:3:end,:) = [];
W_proj = bsxfun(@plus,W_proj,T);

%%
output.S_init = S_init;
output.R_init = R_init;
output.C_init = C_init;
output.T_init = T_init;
output.S_final = S;
output.R_final = R;
output.C_final = C;
output.T_final = T;
output.W_init = W_init*scale;
output.W_proj = W_proj*scale;
output.W_final = W*scale;
output.size_metric = size_metric;
output.size_heatmap = size_heatmap;
output.time = t_w + t_c + t_r;

%%
if EM
    var = zeros(nFrame,nJoint);
    for i = 1:nFrame
        pts = bsxfun(@plus,S(3*i-2:3*i-1,:),T(2*i-1:2*i));
        for j = 1:nJoint
            sqDist = sum(bsxfun(@minus,xy,pts(:,j)).^2,1)';
            likelihood = exp(-sqDist/(2*sigma^2));
            pr = (likelihood+eps) .* ...
                reshape(heatmap(:,:,j,i)+eps,size(likelihood));
            pr = pr / sum(pr);
            mu = xy*pr;
            xy_c = bsxfun(@minus,xy,mu);
            var(i,j) = trace(xy_c*bsxfun(@times,(xy_c'),pr));
        end
    end
    output.W_var = var*(scale^2);
end
