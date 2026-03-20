function floquet = FloquetAlex(kappa, alpha)
period = 2*ellipticK(-1);
xspan = [0 period];
y0_1 = [1; 0];
y0_2 = [0; 1];
ode = @(x, y) AlexFunction(x, y, kappa, alpha);
sol_1 = ode45(ode, xspan, y0_1);
sol_2 = ode45(ode, xspan, y0_2);

y1 = deval(sol_1, period, 1);
y2 = deval(sol_2, period, 2);

delta = (y1 + y2) / 2;

floquet = abs(log(abs(delta + sqrt(delta.^2 - 1)))) / period;