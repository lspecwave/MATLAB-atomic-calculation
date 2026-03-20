% y_xx + (A - q * jacobiSN(x,-1)^2 * (3 - 5 * jacobiSN(x,-1)^4) ) y = 0
clear;
tic

kappa_max = 1.8;
kappa_min = 0;
kappa_number = 200;
alpha_max = 0.7;
alpha_min = 0;
alpha_number = 200;

kappa = linspace(kappa_min, kappa_max, kappa_number);
alpha = linspace(alpha_min, alpha_max, alpha_number);
[alpha_matrix, kappa_matrix] = meshgrid(alpha, kappa);

u = nan(size(kappa_matrix));

%%%%%%%%%%%%%%%%%%%%%%%% Calculate floquet number %%%%%%%%%%%%%%%%%%%%%%%%

parfor ii = 1:numel(kappa_matrix)
    u(ii) = FloquetAlex(kappa_matrix(ii), alpha_matrix(ii));
end

%%%%%%%%%%%%%%%%%%%%%%%%% Calculate the boundary %%%%%%%%%%%%%%%%%%%%%%%%%

N = 42;
period_1 = 2*ellipticK(-1);
L_1 = period_1/2;
period_2 = 4*ellipticK(-1);
L_2 = period_2/2;

% h = 2*pi/N; x = h*(1:N);
h_1= 2*L_1/N; x_1 = h_1*(1:N);
h_2= 2*L_2/N; x_2 = h_2*(1:N);

% toeplitz(a) 是把a作为首行，展开成一个常对角矩阵
D2_1 = (pi/L_1)^2 ...
    * toeplitz([-N^2/12-1/6 -.5*(-1).^(1:N-1)./sin(pi*(1:N-1)/N).^2]);

D2_2 = (pi/L_2)^2 ...
    * toeplitz([-N^2/12-1/6 -.5*(-1).^(1:N-1)./sin(pi*(1:N-1)/N).^2]);

% qmax = 30;
% qq = 0:0.1:qmax; % 行矢量
kappa_boundary_1 = [];
kappa_boundary_2 = [];

for alpha_series = alpha
    left_matrix_1  = D2_1 - alpha_series * diag(jacobiSN(x_1,-1).^2.*(3-5*jacobiSN(x_1,-1).^4));
    right_matrix_1 = - (1 + alpha_series * diag(1 - jacobiSN(x_1,-1).^4));
%     right_matrix_1 = - eye(N);
    e_1 = sort(eig(left_matrix_1, right_matrix_1))';
%     e_1 = sort(eig(-D2_1 - 2 * qq * diag(cos(x_1))))'; % 行矢量
    kappa_boundary_1 = [kappa_boundary_1; e_1(1:8)]; % 取e(1:11)，放在下一行
    left_matrix_2  = D2_2 - alpha_series * diag(jacobiSN(x_2,-1).^2.*(3-5*jacobiSN(x_2,-1).^4));
    right_matrix_2 = - (1 + alpha_series * diag(1 - jacobiSN(x_2,-1).^4));
%     right_matrix_2 = - eye(N);
    e_2 = sort(eig(left_matrix_2, right_matrix_2))';
%     e_2 = sort(eig(-D2_2 - 2 * qq * diag(cos(x_2))))'; % 行矢量
    kappa_boundary_2 = [kappa_boundary_2; e_2(1:2)]; % 取e(1:11)，放在下一行
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig1 = figure(1);
clf;
ax1 = axes(fig1);

f1 = pcolor(alpha_matrix, kappa_matrix, u);
colormap gray
colorbar

shading flat;
f1.FaceColor = 'interp';

hold on

plot(ax1, alpha, kappa_boundary_1, 'linewidth', .8, 'Color', [1 1 1])
% plot(q, A_boundary_1, 'linewidth', .8, 'Color', [0 0 1])
xlabel(ax1, '$\alpha$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(ax1, '$\kappa$', 'Interpreter', 'latex', 'FontSize', 20);
% title(ax1, '$y_{xx}+(A+2q\cos(2x))y = 0,\qquad \mathrm{Differential~matrix~period} = 2\pi$', 'Interpreter', 'latex', 'FontSize', 20)
axis(ax1, [alpha_min alpha_max kappa_min kappa_max])

fig2 = figure(2);
clf;
ax2 = axes(fig2);
f2 = pcolor(alpha_matrix, kappa_matrix, u);
colormap gray
colorbar

shading flat;
f2.FaceColor = 'interp';

hold on

plot(ax2, alpha, kappa_boundary_2, 'linewidth', .8, 'Color', [1 1 1])
xlabel(ax2, '$\alpha$', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(ax2, '$\kappa$', 'Interpreter', 'latex', 'FontSize', 20);
% title(ax2, '$y_{xx}+(A+2q\cos(2x))y = 0,\qquad \mathrm{Differential~matrix~period} = \pi$', 'Interpreter', 'latex', 'FontSize', 20)
axis(ax2, [alpha_min alpha_max kappa_min kappa_max])

toc