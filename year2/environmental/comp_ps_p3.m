%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Computational Problem Set, Enviro I, Problem 3
% Zachary Kuloszewski
%
% Last Edit Date: Nov 8, 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set directories
clear; clc;

cd '/Users/zachkuloszewski/Dropbox/My Mac (Zachs-MBP.lan)/Documents/';
cd 'GitHub/phd_psets/year2/environmental';
addpath(genpath('figures'));
addpath(genpath('functions'));

%% Problem 3 
% Drilling and Real Options

%% Part 3a - Set up the state space

% init parameters
D = 3e6;
X = 100000;

r     = 0.05;
delta = 1/(1+r);

Pmin = 0;
Pmax = 80;
N    = 81;

% define state space
P = linspace(Pmin,Pmax,N);

% define profits across the state space
profit = P*X - D;

%% Part 3b - state transition matrix with uncertainty

% shock parameters ~N(P_{t-1}, 16)
mu    = 0; 
sigma = 4;

% init T
T = nan(N,N);

% bin upper bounds
P_bins_UB      = P + 0.5;
P_bins_UB(end) = inf;

for i=1:N
    Tcdf = normcdf(P_bins_UB, P(i)+mu, sigma);
    
    T(i,1) = Tcdf(1);

    for j=2:numel(Tcdf)
        T(i,j) = Tcdf(j) - Tcdf(j-1);
    end
end

%% Part 3c - value function iteration once again

% init parameters
error     = 1e12;
error_tol = 1e-8;

% init value and optim choice
V_hist = nan(N,1000);
C_hist = nan(N,1000);

% iteration counter
n_iter = 0;

V     = repelem(0,N)';
Vnext = nan(N,N);

while error > error_tol
    
    % count number iterations
    n_iter = n_iter + 1;
    Vold  = V;

    Vnext = T * V;

    % grab optimized value and action column
    V = max((P*X - D)', delta .* Vnext);
    C = (V==(P*X - D)');

    % store values and choices
    V_hist(:,n_iter) = V;
    C_hist(:,n_iter) = C;

    error = max(abs(V-Vold));

end

%% Part 3d - plot the value function

close all;
figure; 
plot(V);
xlabel('State');
ylabel('Value');
title('Converged Estimate of Value Function');

saveas(gcf,'figures/part3d.png')

