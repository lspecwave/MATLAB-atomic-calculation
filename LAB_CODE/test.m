clear all;
close all;
colors=npg(100); 
init=[ 1 0 0 0 0 ];

init=init';
sigmax=spinOp(2,'x');
sigmay=spinOp(2,'y');
sigmaz=spinOp(2,'z');

time_resolution=0.01;

%ham=3.3744*sigmax+0.46524*sigmay^2;
ham=1*(1*sigmax+0*sigmax^2);
%ham=2*pi*(1.0*sigmaz+0*sigmay+1*sigmaz^2);
%ham=2*pi*12.84/5*sigmaz+2*pi*7.3/2*(sigmaz^2);
%ham=2*pi*sigmax+2*pi*(sigmax^2);
%ham=0.0*sigmaz+0*sigmay+1*sigmax^2;
%ham=sigmax+1*sigmax^2+1*sigmax+0*sigmaz;
%ham=sigmax+0.2*sigmaz^2;
ham_0=10*sigmaz;
timelist=[0:time_resolution:6];

%%
k=1;
for t=timelist
    evo=ham_0.*t.*1i;
    evo_0=ham.*(pi/2).*1i;
    %finalstate(:,k)=expm(-evo_0)*expm(-evo)*expm(-evo_0*2)*expm(-evo)*expm(-evo_0)*init;
    finalstate(:,k)=expm(-evo_0)*expm(-evo)*expm(-evo_0)*init;
    %finalstate(:,k)=expm(-evo)*init;
    k=k+1;
end
%% Plot
finalpop(:,:)=abs(finalstate(:,:)).^2;
finalpop1=finalpop(1,:);
figure
for state=1:5
    plot(timelist,finalpop(state,:),'DisplayName',num2str(state));
    hold on;
end
ylim([0 1])
xlabel('Pulse length');
ylabel('Pouplation')
grid off
set(gca,'FontSize',16)
legend


xxx=(finalpop(1,:)-finalpop(5,:))./(finalpop(1,:)+finalpop(5,:));

% 
% load(['\\Artemis-pc\e\Data\2022-11-02\Abs-5434','\average.mat'],'xlist','phase_mean','phase_std');
% xxx=phase_mean;
% xxx=finalpop1;
colors=npg(10);

Fs = 100;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(xxx);             % Length of signal
t = (0:L-1)*T;        % Time vector

Y = fft(xxx);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
h0=figure
plot(f,P1,'Linewidth',2,'Color',colors(5,:)) 
hold on
plot(f,P1,'.','Color',colors(1,:),'MarkerSize',10) 


%title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('FFT arb. unit')
set(gca,'FontSize',16)
%ylim([0 1.05])
set(gca,'YScale','log')
%ylim([0.001 1])
