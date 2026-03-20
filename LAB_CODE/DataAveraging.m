length=270;
repeat=14;

%xaxis=[1:1:270];
%xaxis=[[1:30],[1:30]+50,[1:30]+100,[1:30]+150,[1:30]+200,[1:30]+250,[1:30]+300,[1:30]+350,[1:30]+400];
xaxis=[1:1:270];
for i=1:length
    phase_0=relativeOD(i:length:end);
    phase_0(phase_0>1.5)=[];
    phase_0(phase_0<-1.5)=[];
    OD_1=ODsum1(i:length:end);
    OD_2=ODsum2(i:length:end);
    
    %phase_0=ODsum1(i:length:end);
    phaseaverage(i)=mean(phase_0);
    phaseerr(i)=std(phase_0)./sqrt(repeat);
    
    OD1average(i)=mean(OD_1);
    OD1err(i)=std(OD_1)./sqrt(repeat);
    
    OD2average(i)=mean(OD_2);
    OD2err(i)=std(OD_2)./sqrt(repeat);
end
figure
errorbar(xaxis,phaseaverage,phaseerr,'.k','Capsize',0.5,'LineWidth',1.0,'MarkerSize',10)
xlim([0 270])
ylim([-1 1])
xlabel('Rabi Oscillation time us')
ylabel('S_{z}')
%hold on;
%plot([2:2:50],phaseaverage,'.','Markersize',10,'Color',[0 98 132]./255.0)
set(gca,'FontSize',20,'fontname','times new roman');
legend off;


figure
errorbar(xaxis,OD1average,OD1err,'.','Capsize',0.5,'LineWidth',1.0,'MarkerSize',10)
hold on
errorbar(xaxis,OD2average,OD2err,'.','Capsize',0.5,'LineWidth',1.0,'MarkerSize',10)

xlim([0 1500])
ylim([0 15])
xlabel('Rabi Oscillation time us')
ylabel('N arb. unit')
%hold on;
%plot([2:2:50],phaseaverage,'.','Markersize',10,'Color',[0 98 132]./255.0)
set(gca,'FontSize',20);
legend({'N +5/2','N -5/2'})
%legend off;

figure
errorbar(xaxis,OD1average+OD2average,(OD1err+OD2err)./sqrt(2),'.','Capsize',0.5,'LineWidth',1.0,'MarkerSize',10)
xlim([0 1500])
ylim([0 15])
xlabel('Rabi Oscillation time us')
ylabel('N arb. unit')
%hold on;
%plot([2:2:50],phaseaverage,'.','Markersize',10,'Color',[0 98 132]./255.0)
set(gca,'FontSize',20);
