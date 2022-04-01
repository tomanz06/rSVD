function [U,S,V] = rsvd(X,k,o,q)
%-------------------------------------------------------------------------------------
% random SVD
% Extremely fast computation of the truncated Singular Value Decomposition, using
% randomized algorithms as described in Halko et al. 'finding structure with randomness'
%
% usage : 
%
%  input:
%  * X : matrix whose SVD we want in R(m by n)
%  * k : target rank of X
%  * o : oversampling parameter (optional)
%  * q : # of power iterations (optional)
%
%  output:
%  * rU,rS,rV : SVD of our randomly projected matrix, truncated to the
%               target rank k
%-------------------------------------------------------------------------------------
% Thomas Anzalone and Elijah Sanderson, 2021
% Citations:    Antoine Liutkus, Inria 2014
%               Steve Brunton, 2020

[m,n] = size(X);

transpose_flag = false;
if m < n
    % Fat matrix - compute rSVD on X' and swap U and V in result
    transpose_flag = true;
    X = X';
    [~,n] = size(X);
end

switch nargin
    case 2
        o = 0; q = 0;
    case 3
        q = 0;
end

% Step 1: Random Projection Matrix P in R(n by r)
r = k;
P = randn(n,r+o);
Z = X*P;

% Perform the Power iterations - order of operations matters!
% X'*Z is much less computational than X*X'
for i = 1:q
    Z = X*(X'*Z);
end

% Step 2: Find an orthogonal basis, Q, for Z (and X) using QR decomposition
[Q,~] = qr(Z,0);

% Step 3: Project X into the orthogonal basis, Q
Y = Q'*X;
[U,S,V] = svd(Y,'econ');

U = Q*U;
U = U(:,1:r);
S = S(1:r,1:r);
V = V(:,1:r);

if transpose_flag
    U_mem = U;
    U = V;
    V = U_mem;
end

end