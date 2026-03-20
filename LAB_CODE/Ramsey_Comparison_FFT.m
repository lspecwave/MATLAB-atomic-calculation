clear all
close all
colors=npg(100); 
%% Load experimental data
% cat state
load(['\\Artemis-pc\e\Data\2022-10-18\Abs-9887','\result.mat'],'relativeOD','ODsum1','ODsum2');
phase_1=relativeOD;
OD_1=ODsum1+ODsum2;
% coherent state
load(['\\Artemis-pc\e\Data\2022-10-16\Abs-3453','\result.mat'],'relativeOD','ODsum1','ODsum2');
phase_2=relativeOD;
OD_2=ODsum1+ODsum2;
%% Plot experimental data

time_list=0.006+(0:0.02:22-0.02);
figure('Name','Ramsey fringes')
t = tiledlayout(2,1,'TileSpacing','tight','Padding','tight');

nexttile(1)
h2=plot(time_list,phase_1,'.');
xlim([0 22])
ylim([-1 1])
set(gca,'FontSize',16)
%xlabel('Interrogation time (s)')
ylabel('$\mathcal{P}$','Interpreter','latex')
h2.Color=colors(31,:);


nexttile(2)
h2=plot(time_list,phase_2,'.');
xlim([0 22])
ylim([-1 1])
set(gca,'FontSize',16)
xlabel('Interrogation time (s)')
ylabel('$\mathcal{P}$','Interpreter','latex')
h2.Color=colors(26,:);


figure('Name','Population decay')
t = tiledlayout(2,1,'TileSpacing','tight','Padding','tight');

nexttile(1)
h2=plot(time_list,OD_1./max(OD_1),'.');
xlim([0 22])
ylim([0 1])
set(gca,'FontSize',16)
%xlabel('Interrogation time (s)')
ylabel('Number of atoms (arb.)')
%ylabel('$\mathcal{P}$','Interpreter','latex')
%set(gca,'YScale','log')
h2.Color=colors(31,:);


nexttile(2)
h2=plot(time_list,OD_2./max(OD_2),'.');
xlim([0 22])
ylim([0 1])
set(gca,'FontSize',16)
xlabel('Interrogation time (s)')
ylabel('Number of atoms (arb.)')
%ylabel('$\mathcal{P}$','Interpreter','latex')
%set(gca,'YScale','log')
h2.Color=colors(26,:);

bin_n=50;

time_list_binned=reshape(time_list,bin_n,length(time_list)./bin_n);
OD_2_binned=reshape(OD_2,bin_n,length(OD_2)./bin_n);

time_list_mean=mean(time_list_binned);
OD_2_mean=max(OD_2_binned);
OD_2_std=std(OD_2_binned);

OD_max=max(OD_2_mean);

OD_2_mean=OD_2_mean./OD_max.*exp(1*time_list_mean./71);
OD_2_std=OD_2_std./OD_max;

hold on
h2=errorbar(time_list_mean,OD_2_mean,OD_2_std,'o');
xlim([0 22])
ylim([0 1])
set(gca,'FontSize',16)
xlabel('Interrogation time (s)')
ylabel('Number of atoms (arb.)')
%ylabel('$\mathcal{P}$','Interpreter','latex')
%set(gca,'YScale','log')
h2.Color=colors(26,:);

save(['\\Artemis-pc\e\Data\2022-10-16\Abs-3453','\RamseyDecay.mat'])

%% numerical simulation - parameters

init=[ 1 0 0 0 0 0 ];
init=init';
sigmax=spinOp(5/2,'x');
sigmay=spinOp(5/2,'y');
sigmaz=spinOp(5/2,'z');

tensor_freq=3.7;

omega_173_2_v=2*pi*0.25*1000;
omega_173_2_t=2*omega_173_2_v;
ham_4=omega_173_2_v*sigmax+omega_173_2_t*sigmax^2; % control H

ham_0=ham_4; % driving hamiltonian

ham=1*2*pi*12.965/5*sigmaz+2*pi*tensor_freq*(sigmaz^2)-0*2*pi*12.965/500*sigmax+0.00*2*pi*tensor_freq*(sigmax^2); % Zeeman H + lattice H


timelist=(0:0.02:182)+0.006; % tau, not 2 tau

atom_number=100; % number of atoms for simulation

%% simulation - evolution
finalstate=zeros(atom_number,length(init),length(timelist));
finalpop=zeros(atom_number,length(init),length(timelist));

tic
for ii=1:atom_number
    parfor k=1:length(timelist) % parfor, parallel computing
        randn_a=((randn-5)^2*1-26)/15;%distribution
        %randn_a=randn;%distribution
        %randn_a=(randi(2)-1)*randn_a;
        evo=(ham+0.01*(randn_a)*2*pi*tensor_freq*sigmaz^2).*timelist(k).*1i;
        evo_0=ham_0.*0.00094.*1i;
        %evo_0=ham_0.*0.00090.*1i;
        %evo_0=(ham_0+ham+0.04*(randn_a)*2*pi*tensor_freq/4*sigmaz^2).*0.00088.*1i; % 考虑 pulse 过程中的tensor 演化
        finalstate(ii,:,k)=expm(-evo_0)*expm(-evo)*expm(-evo_0)*init;
    end
end
finalpop(:,:,:)=abs(finalstate(:,:,:)).^2;
toc

% %% State population
% figure
% title('Population on +5/2')
% for ii=1:atom_number
% for state=1:1
%     plot(timelist,squeeze(finalpop(ii,state,:)));
%     hold on;
% end
% xlim([0 10])
% ylim([0 1])
% end
% set(gca,'FontSize',16)
% xlabel('Interrogation time (s)')
% ylabel('$+5/2\ Population$','Interpreter','latex')
% 
% figure
% title('Population on +3/2')
% for ii=1:atom_number
% for state=2:2
%     plot(timelist,squeeze(finalpop(ii,state,:)));
%     hold on;
% end
% xlim([0 10])
% ylim([0 1])
% end
% set(gca,'FontSize',16)
% xlabel('Interrogation time (s)')
% ylabel('$+3/2\ Population$','Interpreter','latex')



%% State popultion

p1_average=squeeze(mean(finalpop(:,1,:),1));
p2_average=squeeze(mean(finalpop(:,2,:),1));
p3_average=squeeze(mean(finalpop(:,3,:),1));
p4_average=squeeze(mean(finalpop(:,4,:),1));
p5_average=squeeze(mean(finalpop(:,5,:),1));
p6_average=squeeze(mean(finalpop(:,6,:),1));

t = tiledlayout(2,3,'TileSpacing','tight','Padding','tight');


nexttile(1);
%figure('Name','Population on +5/2')
plot(timelist,p1_average);
xlim([0 max(timelist)])
ylim([0 1])
ylabel('Population on +5/2')


nexttile(4);
%figure('Name','Population on +5/2')
plot(timelist,p6_average);
xlim([0 max(timelist)])
ylim([0 1])
ylabel('Population on -5/2')

nexttile(2);
%figure('Name','Population on +3/2')
plot(timelist,p2_average);
xlim([0 max(timelist)])
ylim([0 1])
ylabel('Population on +3/2')

nexttile(5);
%figure('Name','Population on -3/2')
plot(timelist,p5_average);
xlim([0 max(timelist)])
ylim([0 1])
ylabel('Population on -3/2')

nexttile(3);
%figure('Name','Population on +1/2')
plot(timelist,p3_average);
xlim([0 max(timelist)])
ylim([0 1])
ylabel('Population on +1/2')

nexttile(6);
%figure('Name','Population on -1/2')
plot(timelist,p4_average);
xlim([0 max(timelist)])
ylim([0 1])
ylabel('Population on -1/2')



%%
t = tiledlayout(3,3,'TileSpacing','tight','Padding','tight');

nexttile(1);
plot(timelist,p1_average+p6_average);
xlim([0 max(timelist)])
ylim([0 1])
ylabel('Population on +-5/2')

nexttile(2);
plot(timelist,p2_average+p5_average);
xlim([0 max(timelist)])
ylim([0 1])
ylabel('Population on +-3/2')

nexttile(3);
plot(timelist,p3_average+p4_average);
xlim([0 max(timelist)])
ylim([0 1])
ylabel('Population on +-1/2')

nexttile(4);
plot(timelist,p1_average-p6_average);
xlim([0 max(timelist)])
ylim([-1 1])
ylabel('Population diff on +-5/2')

nexttile(5);
plot(timelist,p2_average-p5_average);
xlim([0 max(timelist)])
ylim([-1 1])
ylabel('Population diff on +-3/2')

nexttile(6);
plot(timelist,p3_average-p4_average);
xlim([0 max(timelist)])
ylim([-1 1])
ylabel('Population diff on +-1/2')

nexttile(7);
plot(timelist,(p1_average-p6_average)./(p1_average+p6_average));
xlim([0 max(timelist)])
ylim([-1 1])
ylabel('Norm. diff on +-5/2')

nexttile(8);
plot(timelist,(p2_average-p5_average)./(p2_average+p5_average));
xlim([0 max(timelist)])
ylim([-1 1])
ylabel('Norm. diff on +-3/2')

nexttile(9);
plot(timelist,(p3_average-p4_average)./(p3_average+p4_average));
xlim([0 max(timelist)])
ylim([-1 1])
ylabel('Norm. diff on +-1/2')


Sz16=(p1_average-p6_average)./(p1_average+p6_average);
P16=(p1_average+p6_average);

%%

xxx=Sz16(3000:end);
% 
% load(['\\Artemis-pc\e\Data\2022-11-02\Abs-5434','\average.mat'],'xlist','phase_mean','phase_std');
% xxx=phase_mean;
% xxx=finalpop1;
colors=npg(10);

Fs = 50;            % Sampling frequency                    
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
ylim([0 1.05])
set(gca,'YScale','linear')
ylim([0.001 1])
%% mixed detection
figure
ratio=0.0;
plot(timelist,((p1_average+ratio*p2_average)-(ratio*p5_average+p6_average))./((p1_average+ratio*p2_average)+(ratio*p5_average+p6_average)))
hold on
plot(time_list,phase_2,'.');
xlim([0 max(timelist)])
ylim([-1 1])
set(gca,'FontSize',16)
xlabel('Interrogation time (s)')
ylabel('$\mathcal{P}$','Interpreter','latex')
%%
%save('\\Artemis-pc\e\Data\Simulation\ramsey173.mat')
figure
scatter(timelist,Sz16,'.')
figure
scatter(timelist,P16,'.')

Sz16_reshaped=reshape(Sz16(1:9100),100,91);
timelist_reshaped=reshape(timelist(1:9100),100,91);
P16_reshaped=reshape(P16(1:9100),100,91);

timelist_reshaped_mean=mean(timelist_reshaped);
P16_reshaped_mean=mean(P16_reshaped);

% fitting
eqn='a1*cos(2*pi*b1*x+c1)+a3*cos(2*pi*b1*3*x+c3)+a5*cos(2*pi*b1*5*x+c5)+d';
startpoints=[0.6 0.2 0.01 2.58 0 0 0 0];
lower=[0 0 0 2 -3.142*2 -3.142*4 -3.142*6 -1];
upper=[1 1 1 3  3.142*2  3.142*4  3.142*6  1];

chilist=[];

chilist=[];
chilist_reduced=[];

for i=1:91
    fi=fit(timelist_reshaped(:,i),Sz16_reshaped(:,i),eqn,'Start',startpoints,'Lower',lower,'Upper',upper);
    fi_result{i}=fi;
%     fi
%     h=figure;
     plot(timelist_reshaped(:,i),fi(timelist_reshaped(:,i)),'LineWidth',1.5,'Color',colors(5,:));
     hold on
     scatter(timelist_reshaped(:,i),Sz16_reshaped(:,i));

    amp_1(i)=fi.a1;
    amp_3(i)=fi.a3;
    amp_5(i)=fi.a5;
    temp = confint(fi);
    amp_err_1(i) = (temp(2)-temp(1))./4;
    amp_err_3(i) = (temp(4)-temp(3))./4;
    amp_err_5(i) = (temp(6)-temp(5))./4;
    title([num2str(timelist_reshaped_mean(i)),' s']);
    ylim([-1 1]);
    ylabel('S_z');
    xlabel('Precession time s');
    set(gca,'FontSize',16);
end

%%
f_amp=figure;
hold on;

amp_all=amp_1+amp_3+amp_5;
amp_all_err=sqrt(amp_err_1.^2+amp_err_3.^2+amp_err_5.^2);
f_amp_h_all=errorbar(timelist_reshaped_mean,amp_all,amp_all_err,'o');
f_amp_h1=errorbar(timelist_reshaped_mean,amp_1,amp_err_1,'o');
f_amp_h3=errorbar(timelist_reshaped_mean,amp_3,amp_err_5,'o');
f_amp_h5=errorbar(timelist_reshaped_mean,amp_5,amp_err_5,'o');


ylabel('Contrast');
xlabel('Precession time s');
set(gca,'FontSize',20);
xlim([0 200])
ylim([0 1])

%%
precess_1_list_plot=(0:0.001:2);

for i = 1:91
    [d1] = differentiate(fi_result{i},precess_1_list_plot);
    slope_max(i)=max(d1);
    slope_min(i)=-min(d1);
end

amp_all=amp_1+3*amp_3+5*amp_5;
amp_all_err=sqrt(amp_err_1.^2+9*amp_err_3.^2+25*amp_err_5.^2);

amp_all_err(isnan(amp_all_err))=sqrt(1/10)*amp_all(isnan(amp_all_err));


sensitivity=1./timelist_reshaped_mean./slope_max*12.5*100/sqrt(0.5);
sensitivity_error=amp_all_err./amp_all.*sensitivity/sqrt(0.5);
sensitivity_decay=figure;
%scatter(precess_2_list_sensitivity,sensitivity)
hold on
errorbar(timelist_reshaped_mean,sensitivity,sensitivity_error,'o')
set(gca,'XScale','log')
set(gca,'YScale','log')
xlim([0.1 200])
ylim([1e-2 100])
hold on
HL=plot(0.001:0.1:500,1./(0.001:0.1:500)/(5)/(1.298e-2))
SQL=plot(0.001:0.1:500,1./(0.001:0.1:500)/(sqrt(5))/(1.298e-2))
mixed=plot(0.001:0.1:500,1./(0.001:0.1:500)/(5/sqrt(16))/(1.298e-2))

figure

scatter(timelist_reshaped_mean,slope_max)