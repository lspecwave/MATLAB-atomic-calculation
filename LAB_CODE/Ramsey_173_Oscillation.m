clear all;
close all;
colors=npg(100);
init=[ 1 0 0 0 0 0 ];
init=init';
sigmax=spinOp(5/2,'x');
sigmay=spinOp(5/2,'y');
sigmaz=spinOp(5/2,'z');
%tensor_freq=14.5;
tensor_freq=15.5;
tensor_freq=17*0;

ham_0=1*sigmax+2*sigmax^2;
ham_T=2*pi*tensor_freq/4*sigmax^2/1.0;
ham=2*pi*12.86/5*sigmax+ham_T;
%12.84
timelist=(0:0.02:(22-0.02))+0.006;

atom_number=10;
%%
for ii=1:atom_number
k=1;
for t=timelist
    randn_a=randn;
    randn_a=rand;
    %evo=(ham+0.03*(randn_a-0.5)*ham_T).*t.*1i;
    evo=(ham+0.00*(randn_a-0.5)*ham_T).*t.*1i;
    %evo_0=ham_0.*(pi/2).*1i;
    %finalstate(ii,:,k)=expm(-evo_0)*expm(-evo)*expm(-evo_0*2)*expm(-evo)*expm(-evo_0)*init;
    %finalstate(ii,:,k)=expm(-evo_0)*expm(-evo)*expm(-evo_0)*init;
    finalstate(ii,:,k)=expm(-evo)*init;
    k=k+1;
end
end

finalpop(:,:,:)=abs(finalstate(:,:,:)).^2;

figure
for ii=1:atom_number
for state=1:1
    plot(timelist,squeeze(finalpop(ii,state,:)));
    hold on;
end
ylim([0 1])
end

%%
figure
p1_average=squeeze(mean(finalpop(:,1,:),1));
p2_average=squeeze(mean(finalpop(:,2,:),1));
p5_average=squeeze(mean(finalpop(:,5,:),1));
p6_average=squeeze(mean(finalpop(:,6,:),1));
plot(timelist,(p1_average-p6_average)./(p1_average+p6_average));
figure
plot(timelist,p1_average);
load(['\\Artemis-pc\e\Data\2022-10-16\Abs-3453','\result.mat'],'relativeOD');

scatter(0.006+(0:0.02:(22-0.02)),relativeOD)


hold on 
%plot(timelist,p1_average);
plot(timelist,(p1_average-p6_average)./(p1_average+p6_average))
ylim([-1 1])
xlim([0 20])
%%
xxx=(p1_average-p6_average)./(p1_average+p6_average);
%xxx=p1_average
xxx(1:100)=[];
T = 0.02;             % Sampling period  
Fs = 1/T;            % Sampling frequency                         
L = length(xxx);             % Length of signal
t = (0:L-1)*T;        % Time vector

Y = fft(xxx);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
h0=figure
plot(f,P1,'Linewidth',1,'Color',colors(5,:)) 
hold on
plot(f,P1,'.','Color',colors(1,:),'MarkerSize',10) 
%title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('FFT arb. unit')
set(gca,'FontSize',16)
xlim([0 25])
ylim([0 1.05])

main_dir='\\Artemis-pc\e\Data\2022-10-16\Abs-3453';
load([main_dir,'\FFT.mat'],'f','P1');
f_2=f;
P_2=P1;

plot(f_2,P_2,'Linewidth',1,'Color',colors(65,:)) 
hold on
plot(f_2,P_2,'.','Color',colors(26,:),'MarkerSize',2) 

xlim([0 20])
ylim([0.003 2])
set(gca,'FontSize',10)
set(gca,'YScale','log')