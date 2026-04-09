close all
clear all
colors=npg(10); % Ten basic colors

%% Input Area

maindir=['\\ARTEMIS-PC\Data\2026-04-09' ...
    '\'];%数据来源路径

plotnumber = 1; %是否画原子数
plotradius = 0; %是否画原子团半径
plotODsum = 1; %是否画OD求和
plotSNRGain = 0; %是否画SNR Gain
plotnoise_FR = 0; %是否画Fringe removal后的noise OD
plotcountperpixel = 0; %是否画countperpixel
plotprecession = 0; %是否画进动
plot2D = 0; %二维形式比较数据，常用于二维扫描
plotCatRatio = 0; %是否画cat state占比，并计算平均值

rabi = 0; %是否为Rabi曲线
ramsey = 0; %是否为Ramsey曲线
dual_species = 0; %是否有两种同位素
normalized_detection = 0; %是否归一化探测，默认OD_2/OD_1
differential_detection = 1; %是否差分探测

first = 200; %第一个文件夹序号
last = 250; %最后一个文件夹序号

%设置横坐标公式为: xaxis=(first-1:last-1)*coeff+intercept;
intercept = -0.5; %第一组数据的自变量`
coeff = 0.01; %各组数据自变量间隔


if rabi == 1
    setXlabel='ROT Pulse us';%横坐标label
elseif ramsey == 1
    setXlabel='Precession Time ms';%横坐标label
else
    % setXlabel='BusODT Hold s';%横坐标label
    % setXlabel='MOT Hold s';%横坐标label
    % setXlabel='MOT Lold s';%横坐标label
    % setXlabel='Ramsey Interrogation Time ms';%横坐标label
    % setXlabel='556 AM V';%横坐标label
    % setXlabel='556 FM V';%横坐标label
    % setXlabel='556 Freq kHz';%横坐标label
    setXlabel='399 FM V';%横坐标label
    % setXlabel='399 Freq MHz';%横坐标label
    % setXlabel='MOT Ramp s';%横坐标label
    % setXlabel='Spin echo time s';%横坐标label
    % setXlabel='Polar Pulse us';%横坐标label
    % setXlabel='Probe Pulse us';%横坐标label
    % setXlabel='Hold Time s';%横坐标label
    % setXlabel='Ramp Time s';%横坐标label
    % setXlabel='TOF s';%横坐标label
    % setXlabel='Current V';%横坐标label
    % setXlabel='power exponent';%横坐标label
    % setXlabel='Shim V';%横坐标label
    % setXlabel='Lattice AM V';%横坐标label
    % setXlabel='MOT Freq (V)';%横坐标label
    % setXlabel='No.';%横坐标label
    % setXlabel='173 Polar Pulse us';%横坐标label
end


%% read data
datalength=last-first+1;
xaxis=(0:last-first)*coeff+intercept;
%xaxis=xaxis.*(320); % 399 Scan (+320MHz/V)
%xaxis=[0.18:0.01:0.26, 0.32:0.01:0.42];
%xaxis=[0.01 0.03 0.05 0.1 0.3 0.5 0.7 1 2 3 5 7 10]*1e3;
%xaxis=[0.1 0.5 1:1:20];
%xaxis=floor(10.^(1.0:0.2:5));
%xaxis= [0.1:0.1:0.5 0.7 0.9 1 1.1 1.3:0.2:1.9 2.0 2.2 2.5 3.0];


% Preallocation
numberofatoms1=zeros(datalength,1);
noise_OD=zeros(datalength,1);
countperpixel=zeros(datalength,1);

ODsum1=zeros(datalength,1);
ODsum2=zeros(datalength,1);
ODsum3=zeros(datalength,1);
ODsum4=zeros(datalength,1);
ODsum5=zeros(datalength,1);
ODsum6=zeros(datalength,1);

ODsum1_mod=zeros(datalength,1);
ODsum2_mod=zeros(datalength,1);
ODsum3_mod=zeros(datalength,1);
ODsum4_mod=zeros(datalength,1);
ODsum5_mod=zeros(datalength,1);
ODsum6_mod=zeros(datalength,1);

numberofatoms3=zeros(datalength,1);
numberofatoms4=zeros(datalength,1);
numberofatoms5=zeros(datalength,1);
numberofatoms6=zeros(datalength,1);


numberofatoms2=zeros(datalength,1);
radius=zeros(datalength,1);
noise_FR=zeros(datalength,1);
SNRGain=zeros(datalength,1);
Timelist=datetime(zeros(datalength,6));

tic
parfor i=1:datalength % parallel computing
    filestr=[maindir,'Abs-',num2str(i+first-1),'\Output.txt'];
    filestr;
    datafile=fopen(filestr);
    data_out=textscan(datafile,'%f');
    totaldata=data_out{1};
    fclose(datafile);

    filestr_time=[maindir,'Abs-',num2str(i+first-1),'\time.txt'];
    time_hd=fopen(filestr_time);
    data_time=textscan(time_hd,'%s %s');
    Timelist(i)=datetime([cell2mat(data_time{1,1}),' ',cell2mat(data_time{1,2})],'InputFormat','yyyy-MM-dd HH:mm:ss'); %转成时间序列
    fclose(time_hd);


    numberofatoms1(i)=totaldata(8);
    ODsum1_mod(i)=totaldata(9);
    countperpixel(i)=totaldata(10);
    radius(i)=totaldata(11);
    ODsum1(i)=totaldata(12);
    noise_FR(i)=totaldata(13);
    SNRGain(i)=totaldata(14);

    %只拍摄了一张原子照片时注释掉
    try
        numberofatoms2(i)=totaldata(15);
        ODsum2_mod(i)=totaldata(16);
        ODsum2(i)=totaldata(19);
    catch

    end

    try
        numberofatoms3(i)=totaldata(22);
        ODsum3(i)=totaldata(26);
        ODsum3_mod(i)=totaldata(23);

        numberofatoms4(i)=totaldata(29);
        ODsum4(i)=totaldata(33);
        ODsum4_mod(i)=totaldata(30);

        numberofatoms5(i)=totaldata(36);
        ODsum5(i)=totaldata(40);
        ODsum5_mod(i)=totaldata(37);

        numberofatoms6(i)=totaldata(43);
        ODsum6(i)=totaldata(47);
        ODsum6_mod(i)=totaldata(44);
    catch

    end


    %     % 用于处理 2022 0814 之前的的数据
    %     numberofatoms1(i+1-first)=totaldata(1);
    %     noise_OD(i+1-first)=totaldata(2);
    %     countperpixel(i+1-first)=totaldata(3);
    %     radius(i+1-first)=totaldata(4);
    %     ODsum1(i+1-first)=totaldata(5);
    %     noise_FR(i+1-first)=totaldata(6);
    %     SNRGain(i+1-first)=totaldata(7);
    %
    %     %只拍摄了一张原子照片时注释掉
    %     numberofatoms2(i+1-first)=totaldata(8);
    %     ODsum2(i+1-first)=totaldata(12);

end
toc

s1=ODsum1_mod;
s2=ODsum2_mod;
s3=ODsum3_mod;
s4=ODsum4_mod;
s5=ODsum5_mod;
s6=ODsum6_mod;

n1=numberofatoms1;
n2=numberofatoms2;
n3=numberofatoms3;
n4=numberofatoms4;
n5=numberofatoms5;
n6=numberofatoms6;


%% plot number of atoms
if plotnumber==1

    n1 = numberofatoms1;
    n2 = numberofatoms2;

    h1=figure('Name','Number of Atoms');
    plot(xaxis,numberofatoms1,'.','Color',colors(3,:),'MarkerSize',20);
    hold on;
    plot(xaxis,numberofatoms2,'.','Color',colors(4,:),'MarkerSize',20);
    legend('Atom_1','Atom_2','Location','best');
    axis([min(xaxis) max(xaxis) 0 max( max(numberofatoms1)*1.1 , 1)]);
    %axis([min(xaxis) max(xaxis) min(numberofatoms1)*0.9 max(numberofatoms1)*1.1])
    title('Number of Atoms','FontName','Arial','FontWeight','bold');
    xlabel(setXlabel);
    grid on;
    box on;

    if dual_species == 1

        plot(xaxis,numberofatoms3,'.','Color',colors(5,:),'MarkerSize',20);
        hold on;
        plot(xaxis,numberofatoms4,'.','Color',colors(6,:),'MarkerSize',20);
        legend('Atom_1','Atom_2','Atom_3','Atom_4','Location','best');

        n3 = numberofatoms3;
        n4 = numberofatoms4;

    end

    set(gca,'FontSize',16,'FontName','Arial','FontWeight','bold');
    saveas(h1,[maindir,'Abs-',num2str(last),'\Numberofatoms.png']);
end


%% plot ODsum
if plotODsum==1
    h2=figure('Name','OD Sum');
    plot(xaxis,ODsum1_mod,'.','Color',colors(1,:),'MarkerSize',20);
    hold on
    plot(xaxis,ODsum2_mod,'.','Color',colors(2,:),'MarkerSize',20);
    axis([min(xaxis) max(xaxis) min([0 min(ODsum1_mod)]) max( [1.1*max(ODsum1_mod),1.1*max(ODsum2_mod),1] ) ]);
    title('OD Sum Modified','FontName','Arial','FontWeight','bold');
    xlabel(setXlabel);
    legend('OD_1','OD_2','Location','best');
    %legend('Yb-173','Yb-171','Location','best');
    grid on;
    set(gca,'FontSize',16,'FontName','Arial','FontWeight','bold');

    if dual_species == 1

        plot(xaxis,ODsum3_mod,'.','Color',colors(3,:),'MarkerSize',20);
        plot(xaxis,ODsum4_mod,'.','Color',colors(4,:),'MarkerSize',20);
        axis([min(xaxis) max(xaxis) 0 1.1*max([ max(ODsum1_mod) , max(ODsum2_mod) , max(ODsum3_mod) , max(ODsum4_mod) ]) ]);
        legend('OD_1','OD_2','OD_3','OD_4','Location','best');

    end

    %set(gca,'XScale','log');
    %set(gca,'YScale','log');
    saveas(h2,[maindir,'Abs-',num2str(last),'\ODsum.png'])
    saveas(h2,[maindir,'Abs-',num2str(last),'\ODsum.fig'])

    h2_0=figure('Name','OD Sum 1+2');
    ODsum12_mod=ODsum1_mod+ODsum2_mod;
    plot(xaxis,ODsum12_mod,'.','Color',colors(1,:),'MarkerSize',20);
    hold on
    axis([min(xaxis) max(xaxis) min([0 min(ODsum12_mod)]) max([ODsum12_mod*1.1 ; 1])])
    title('OD Sum','FontName','Arial','FontWeight','bold');
    xlabel(setXlabel);
    grid on;
    box on;

    if dual_species == 1
        ODsum34_mod=ODsum3_mod+ODsum4_mod;
        plot(xaxis,ODsum34_mod,'.','Color',colors(2,:),'MarkerSize',20);
        legend('Yb-173','Yb-171','Location','best');
        axis([min(xaxis) max(xaxis) 0 max(max(ODsum12_mod),max(ODsum34_mod))*1.1]);
    end

    set(gca,'XScale','linear');
    %set(gca,'YScale','log');

    set(gca,'FontSize',16,'FontName','Arial','FontWeight','bold');
    saveas(h2_0,[maindir,'Abs-',num2str(last),'\ODsum12.png'])

    %% Plot time
    figure
    h3_0=plot(Timelist,ODsum1,'.','Color',colors(1,:),'MarkerSize',20);
    grid off
    set(gca,'FontSize',16)
    saveas(h3_0,[maindir,'Abs-',num2str(last),'\time.png'])

end
%% plot radius
if plotradius==1
    h3=figure('Name','Radius');
    plot(xaxis,radius,'.','Color',[0 98 132]./255.0,'MarkerSize',20);
    axis([min(xaxis) max(xaxis) min(radius)*0.9 max(radius)*1.1])
    title('Radius');
    xlabel(setXlabel);
    grid off
    set(gca,'FontSize',16)
end
%% plot SNRGain
if plotSNRGain==1
    h4=figure('Name','SNRGain');
    plot(xaxis,SNRGain,'.','Color',[0 98 132]./255.0,'MarkerSize',20);
    axis([min(xaxis) max(xaxis) min(SNRGain)*0.9 max(SNRGain)*1.1])
    title('SNR Gain');
    xlabel(setXlabel);
    grid off
    set(gca,'FontSize',16)
end
%% plot noise_FR
if plotnoise_FR==1
    h5=figure('Name','Noise_FR');
    plot(xaxis,noise_FR,'.','Color',[0 98 132]./255.0,'MarkerSize',20);
    axis([min(xaxis) max(xaxis) min(noise_FR)*0.9 max(noise_FR)*1.1]);
    title('Noise FR');
    xlabel(setXlabel);
    grid off;
    set(gca,'FontSize',16);
end

%% plot countperpixel
if plotcountperpixel==1
    h55=figure('Name','count per pixel');
    plot(xaxis,countperpixel,'.','Color',[0 98 132]./255.0,'MarkerSize',20);
    axis([min(xaxis) max(xaxis) min(countperpixel)*0.9 max(countperpixel)*1.1]);
    title('count per pixel');
    xlabel(setXlabel);
    grid off;
    set(gca,'FontSize',16);

    saveas(h55,[maindir,'Abs-',num2str(last),'\CountPerPixel.png']);

end

%% plot precession
if plotprecession==1

    h6=figure('Name','Precession');

    % OD2/OD1 %
    if normalized_detection == 1 && differential_detection == 0

        relativeOD=ODsum2_mod./ODsum1_mod;
        %relativeOD=ODsum1_mod./ODsum2_mod;
        
        plot(xaxis,relativeOD,'.','Color',colors(8,:),'MarkerSize',16);

        %plot(xaxis,relativeOD./relativeOD(1),'.-','Color',colors(8,:),'MarkerSize',16);


        axis([min(xaxis) max(xaxis) 0 1]);
        %axis([min(xaxis) max(xaxis) 0.01 0.45]);

        ylabel('OD_2/OD_1');
        %ylabel('OD_1/OD_2');
        %title('Lattice AM 1V','FontName','Arial','FontWeight','bold');

        %set(gca,'XScale','log','YScale','log');


    % 差分探测 %
    elseif differential_detection == 1 && normalized_detection == 0

        relativeOD=(ODsum1_mod-ODsum2_mod)./(ODsum1_mod+ODsum2_mod);
        plot(xaxis,relativeOD,'.','Color',colors(8,:),'MarkerSize',16);
        ylabel('S_z');
        axis([min(xaxis) max(xaxis) -1 1]);

    
    % 其它情况 %
    else

        relativeOD=ODsum1_mod./ODsum2_mod;
        %relativeOD=ODsum1_mod;
        %relativeOD=ODsum3./ODsum2;
        %relativeOD=ODsum3_mod./(ODsum3_mod+ODsum4_mod);
        %relativeOD=(ODsum1_mod)./ODsum4_mod;

        %s1=(ODsum1+ODsum3+ODsum5)./3;
        %s2=(ODsum2+ODsum4+ODsum6)./3;
        %relativeOD=(s1-s2)./(s1+s2);

        plot(xaxis,relativeOD,'.','Color',colors(8,:),'MarkerSize',16);
        ylabel('OD_1/OD_2');
        %ylabel('OD_1');
        %ylabel('Ratio of +5/2');

        %axis([min(xaxis) max(xaxis) 0 max(relativeOD)*1.05]);
        axis([min(xaxis) max(xaxis) 0.03 0.3]);
        %axis([0.14 0.56 0 max(relativeOD)]);

        set(gca,'XScale','log','YScale','log');

    end


    xlabel(setXlabel);


    grid on;
    box on;
    set(gca,'FontSize',16,'FontName','Arial','FontWeight','bold');
    %set(gca,'XScale','log');
    %set(gca,'YScale','log');


    if differential_detection == 1 && normalized_detection == 0 && dual_species == 1

        relativeOD2=(ODsum3_mod-ODsum4_mod)./(ODsum3_mod+ODsum4_mod);
        s3=ODsum3_mod;
        s4=ODsum4_mod;

        hold on;
        plot(xaxis,relativeOD2,'.','Color',colors(2,:),'MarkerSize',16);
        xlim([min(xaxis) max(xaxis)]);
        ylim([-1 1]);
        ylabel('S_z');
        legend('Yb-173','Yb-171','Location','best');

    end


    %axis([min(xaxis) max(xaxis) (min(relativeOD)-0.1) max(relativeOD)+0.1])
    %axis([min(xaxis) max(xaxis) 0 max(relativeOD)+0.1])
    %axis([min(xaxis) max(xaxis) min(relativeOD)*0.9 max(relativeOD)*1.1])


    saveas(h6,[maindir,'Abs-',num2str(last),'\precession.png']);
    saveas(h6,[maindir,'Abs-',num2str(last),'\precession.fig']);



    relativeOD_2=ODsum2./ODsum1;
    %relativeOD_2=ODsum1./ODsum2;
    %relativeOD=(ODsum1-ODsum2)./(ODsum1+ODsum2);
    
    h7=figure('Name','ODsum2 versus OD sum1');
    plot(xaxis,relativeOD_2,'.','Color',colors(8,:),'MarkerSize',16);
    axis([min(xaxis) max(xaxis) 0.6 1.2])
    title(' ');
    xlabel(setXlabel);
    ylabel('S_z')
    grid off
    set(gca,'FontSize',16)
    saveas(h7,[maindir,'Abs-',num2str(last),'\population.png'])



end


%% plot population
%
% try
%     population=(ODsum1+ODsum2)./ODsum3;
%     h8=figure('Name','Population_All');
%     plot(xaxis,population,'.','Color',colors(8,:),'MarkerSize',16);
%     axis([min(xaxis) max(xaxis) 0 1])
%     title(' ');
%     xlabel(setXlabel);
%     ylabel('Population')
%     grid off
%     set(gca,'FontSize',16)
%     saveas(h8,[maindir,'Abs-',num2str(last),'\population_all.png'])
%
%     relativeOD_3=ODsum3./ODsum2;
%     %relativeOD=ODsum1./ODsum2;
%     %relativeOD=(ODsum1-ODsum2)./(ODsum1+ODsum2);
%     h9=figure('Name','ODsum3 versus OD sum2');
%     plot(xaxis,relativeOD_3,'.','Color',colors(8,:),'MarkerSize',16);
%     axis([min(xaxis) max(xaxis) 0.6 1.2])
%     title(' ');
%     xlabel(setXlabel);
%     ylabel('S_z')
%     grid off
%     set(gca,'FontSize',16)
%     saveas(h9,[maindir,'Abs-',num2str(last),'\population_loss.png'])
%
%     relativeOD_4=ODsum3./(ODsum2+ODsum1).*2;
%     %relativeOD=ODsum1./ODsum2;
%     %relativeOD=(ODsum1-ODsum2)./(ODsum1+ODsum2);
%     h9=figure('Name','ODsum3 versus ODsum2+ODsum1');
%     plot(xaxis,relativeOD_4,'.','Color',colors(8,:),'MarkerSize',16);
%     axis([min(xaxis) max(xaxis) 0.6 1.2])
%     title(' ');
%     xlabel(setXlabel);
%     ylabel('S_z')
%     grid off
%     set(gca,'FontSize',16)
%     saveas(h9,[maindir,'Abs-',num2str(last),'\population_loss.png'])
%
% catch
%     disp('Failed to plot population')
% end
%

%% Plot 2D
if plot2D==1
    first_para = [-0.35:0.02:-0.25];
    second_para = [0.1 0.09 0.07 0.05 0.03 0.02 0.01 0];
    xlabel_2D= 'GMOT\_173\_ODT\_F (V)'; % first_para
    %xlabel_2D= 'MOT\_556\_Freq (V)'; % first_para
    ylabel_2D='ShimC\_ODT (V)'; % second_para

    data_2D=reshape(numberofatoms1,length(second_para),length(first_para));% 数据竖列重排

    fig2d=figure;
    b = bar3(data_2D,1);
    colorbar
    for k = 1:length(b)
        zdata = b(k).ZData;
        b(k).CData = zdata;
        b(k).FaceColor = 'interp';
    end
    axis([]);
    xlim([1-0.5,length(first_para)+0.5]);
    ylim([1-0.5,length(second_para)+0.5]);
    xticks([1:length(first_para)]);
    yticks([1:length(second_para)]);
    set(gca,'XTickLabel',first_para,'FontName','Arial','FontWeight','bold');
    set(gca,'YTickLabel',second_para,'FontName','Arial','FontWeight','bold');
    xlabel(xlabel_2D);
    ylabel(ylabel_2D);
    view([0 90]);
    saveas(fig2d,[maindir,'Abs-',num2str(last),'\Compare2D.fig']);
    saveas(fig2d,[maindir,'Abs-',num2str(last),'\Compare2D.png']);
end

%% Plot Cat State Ratio
if plotCatRatio == 1 && dual_species == 0

    s3 = ODsum3_mod;

    h10 = figure();
    ratio = (ODsum1_mod+ODsum2_mod)./ODsum3_mod;
    ratio_mean = mean(ratio);
    ratio_std = std(ratio);
    plot(xaxis,ratio,'.','Color',colors(1,:),'MarkerSize',20);
    axis([min(xaxis) max(xaxis) 0 1.5])
    title('Cat Ratio','FontName','Arial','FontWeight','bold');
    xlabel(setXlabel);
    ylabel('Ratio of Stretched States');
    grid on;
    set(gca,'FontSize',16,'FontName','Arial','FontWeight','bold');
%     legend(['mean = ',num2str(roundn(ratio_mean,-4)),...
%         newline 'std = ',num2str(roundn(ratio_std,-4))],...
%         'Location','best');

    saveas(h10,[maindir,'Abs-',num2str(last),'\ratio.png']);
    save([maindir,'Abs-',num2str(last),'\ratio.mat'],'ratio_mean','ratio_std');

elseif plotCatRatio == 1 && dual_species == 1

    n5 = numberofatoms5;
    s5 = ODsum5_mod;
    h10 = figure();
    ratio = (ODsum1_mod+ODsum2_mod)./ODsum5_mod;
    ratio_mean = mean(ratio);
    ratio_std = std(ratio);
    plot(xaxis,ratio,'.','Color',colors(1,:),'MarkerSize',20);
    axis([min(xaxis) max(xaxis) 0 min(1.5,max(ratio))]);
    title('Cat Ratio','FontName','Arial','FontWeight','bold');
    xlabel(setXlabel);
    ylabel('Ratio of Stretched States');
    grid on;
    set(gca,'FontSize',16,'FontName','Arial','FontWeight','bold');
%     legend(['mean = ',num2str(roundn(ratio_mean,-4)),...
%         newline 'std = ',num2str(roundn(ratio_std,-4))],...
%         'Location','best');

    saveas(h10,[maindir,'Abs-',num2str(last),'\ratio.png']);
    save([maindir,'Abs-',num2str(last),'\ratio.mat'],'ratio_mean','ratio_std');

end

%% Save results

clear main_dir_0
save([maindir,'Abs-',num2str(last),'\result.mat'])
save([maindir,'Abs-',num2str(last),'\population.mat'],'s1','s2','s3','s4','s5','n1','n2','n3','n4','n5');
clear Timelist
