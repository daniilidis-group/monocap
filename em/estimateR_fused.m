function [R,fval] = estimateR_fused(S,W,lambda,R0,tol)

F = size(S,1)/3;
P = size(S,2);
S1 = zeros(3,P,F);
W1 = zeros(2,P,F);
R1 = zeros(3,3,F);
for i = 1:F
    S1(:,:,i) = S(3*i-2:3*i,:);
    W1(:,:,i) = W(2*i-1:2*i,:);
    R1(:,:,i) = [R0(2*i-1:2*i,:);cross(R0(2*i-1,:),R0(2*i,:))];
end

[R2,fval] = updateRotations(W1,S1,lambda,R1,tol);
R = zeros(size(R0));
for i = 1:F
    R(2*i-1:2*i,:) = R2(1:2,:,i);
end

end


function [R,fval,info] = updateRotations(W,S,lambda,R0,tol)
%function R = updateRotations(W,S,lambda,R0)
%   minimize .5* sum_{i=1}^F ||W(:,:,i)-I_{23}*R(:,:,i)*S(:,:,i)||_F^2 +
%            .5*lambda * sum_{i=1}^{F-1}  ||R_i-R_{i+1}||_F^2
%  w.r.t. R in SO(3)^F
%
% F : number of frames
% P : number of points
% W : 2xPxF
% S : 3xPxF
% R0: 3x3xF
% R : 3x3xF

warning('off','manopt:getHessian:approx');
DebugMode = false;
options.verbosity = 0;
options.tolgradnorm = tol;
options.maxiter = 50;
% options.verbosity = 3;

% initialization
if nargin < 4
    X0 = repmat(eye(3),[1 1 F]);
else
    X0 = R0;
end

F = size(W,3);

% Create the problem structure.
manifold = rotationsfactory(3, F);
problem.M = manifold;
problem.cost  = @cost;
problem.egrad = @egrad;


% Cost function
function totalcost = cost(X)

    P2 = [1 0 0; 0 1 0];

    totalcost = 0;
    for i=1:F
        totalcost = totalcost + .5*norm(W(:,:,i)- P2*X(:,:,i)*S(:,:,i),'fro')^2;
        if i < F
            totalcost = totalcost + .5*lambda*norm(X(:,:,i)-X(:,:,i+1),'fro')^2;
        end
    end
end

% Euclidean gradient of the cost function
function g = egrad(X)

    P2 = [1 0 0; 0 1 0];

    g = zeros(size(X));

    for i=1:F
        g(:,:,i) =g(:,:,i)  - P2'*W(:,:,i)*S(:,:,i)' + ...
            (P2'*P2)*X(:,:,i)*S(:,:,i)*S(:,:,i)';
        if i < F
            g(:,:,i) =g(:,:,i)-lambda*X(:,:,i+1);
        end

        if i>1
            g(:,:,i) = g(:,:,i)-lambda*X(:,:,i-1);
        end
    end

end

% Numerically check gradient consistency (optional).
if DebugMode
    checkgradient(problem);
    pause(0.1)
end

% solve
[R, fval, info] = trustregions(problem,X0,options);

% Display some statistics.
if DebugMode
    figure,
    semilogy([info.iter], [info.cost], '.-');
    xlabel('Iteration number');
    ylabel('Cost');
end

end

