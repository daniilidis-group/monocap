function [B,mu,ERR,SP] = learnPoseDict(S_train,skel,K,lam)

% Input: 
% K: size of dictionary 
% lam: regularization weight

%% normalization and alignment
S_train = normalizeS(S_train);
S_train = alignHuman(S_train,skel.torso);
[F,P] = size(S_train);
F = F/3;

%% run dictionary learning
Y = reshape(S_train',3*P,F);
[D,X] = nnscDL(Y,K,lam);

%% calculate reconstruction error
S_rec = reshape(D*X,P,3*F)';
for i=1:F
    x = lsqnonneg(D(:,X(:,i)>0),Y(:,i));
    S_rec(3*i-2:3*i,:) = reshape(D(:,X(:,i)>0)*x,P,3)';
    err(i) = sum(sqrt(sum((S_train(3*i-2:3*i,:)-S_rec(3*i-2:3*i,:)).^2)))/P;
    sp(i) = sum(x>0);
end
ERR = mean(err); % reconstruction error
SP = mean(sp); % average sparsity (tune lam to change sparsity, sp < 10 is recommended)

%% output dictionary
B = reshape(D,P,3*size(D,2))';
mu = meanShape(S_train);

fprintf('Dictionary learning is done, \n reconstr. err. = %f, average sparsity = %f \n',ERR,SP);