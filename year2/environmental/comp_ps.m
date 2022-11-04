%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Computational Problem Set, Enviro I
% Zachary Kuloszewski
%
% Last Edit Date: Nov 3, 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set directories
clear; clc;

cd '/Users/zachkuloszewski/Dropbox/My Mac (Zachs-MBP.lan)/Documents/';
cd 'GitHub/phd_psets/year2/environmental';
addpath(genpath('figures'));

%% Problem 1
% Solving the DDP by value function iteration; discrete state space.

%% part 1a - set up state space, parameters
N     = 501; 
S_tot = 1000;
r     = 0.005;

delta = 1/(1+r);
S     = linspace(0,S_tot,N);

%% part 1b - set up action space
A  = S;
nA = numel(A);

%% part 1c - define utility of extraction
% u = @(x) 2*x.^0.5;
u = @(x) 5*x-0.05*x.^2;

%% part 1d - define flow utility matrix
U = u(repmat(A,nA,1));

% def -inf upper triangular matrix
infs    = repmat(-Inf, N);
flow_UT = triu(infs,1);

% sum to get final flow utility matrix
U = U + flow_UT;

%% part 1e - identify state in next period
% init matrix w same dimension as flow utility
transition = nan(N,nA);

for i=1:N % iter through rows
    for j=1:nA % iter through columns
        if j > i % if extracting more than full stock
            transition(i,j) = 1;
        else
            transition(i,j) = i-j+1;
        end
    end
end

%% part 1f - state transition matrix

T = nan(N,N*nA);
rows = 1:501;

for k=1:nA
    inds = rows - A(k)/2;
    inds(inds<=0) = 1;
    T(:,1+(k-1)*N:k*N) = sparse(rows(inds>0),inds(inds>0),ones(numel(inds(inds>0)),1),N,nA);
end

T = sparse(T);

%% part 1g - value funciton iteration

% init parameters
error     = 1e12;
error_tol = 1e-8;

% init value and optim choice
V_hist = nan(N,1000);
C_hist = nan(N,1000);

% iteration counter
n_iter = 0;

Vold = repelem(-Inf,N);

Vnext = nan(N,nA);

while error > error_tol
    
    % count number iterations
    n_iter = n_iter + 1;

    for k=1:nA %looping thru action space
        Vnext(:,k) = T(:,1+(k-1)*N:k*N)*U(:,k);
    end

    % grab optimized value and action column
    [V, C] = max(U + delta * Vnext,[],2);

    % store values and choices
    V_hist(:,n_iter) = V;
    C_hist(:,n_iter) = C;

    error = max(abs(V-Vold));

    Vold = V;
    U    = Vnext;

end