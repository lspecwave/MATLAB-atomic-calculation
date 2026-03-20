function dydx = AlexFunction(x,y,kappa,alpha)
% y_xx + (A - 2q * cos(2x)) y = 0

% y^{\prime\prime} + (A - 2q * cos(2x)) y = 0
% y_1 = y
% y_2 = y^{\prime}

% dy_1/dt = y_2
% dy_2/dt = - (A - 2q * cos(2x)) y

dydx = [y(2); - (kappa^2 - 120 * alpha.^2 * (jacobiSN(x,-1).^2 - 4 * jacobiSN(x,-1).^6 + 4 * jacobiSN(x,-1).^10) ).* y(1)];