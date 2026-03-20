fv = linspace(0, 1, 20);                                % Normalised Frequencies
a = 1./(1 + fv*2);                                      % Amplitudes Of ‘1/f’
b = firls(42, fv, a);                                   % Filter Numerator Coefficients
figure(1)
freqz(b, 1, 2^17)                                       % Filter Bode Plot
N = 1E+6;
ns = rand(1, N);
invfn = filtfilt(b, 1, ns);                             % Create ‘1/f’ Noise
figure(2)
plot([0:N-1], invfn)                                    % Plot Noise In Time Domain
grid
FTn = fft(invfn-mean(invfn))/N;                         % Fourier Transform
figure(3)
plot([0:N/2], abs(FTn(1:N/2+1))*2)                      % Plot Fourier Transform Of Noise
grid